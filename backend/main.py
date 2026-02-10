import base64
import os
import tempfile
from typing import Any, Dict, List, Optional

from fastapi import FastAPI, File, HTTPException, Request, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

from services.category_classifier import CategoryClassifier
from services.feedback_store import FeedbackStore
from services.recipe_intelligence import RecipeIntelligence
from services.user_history_store import UserHistoryStore
from services.voice_pipeline import VoicePipeline


app = FastAPI(title="SmartPantry API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class VoiceToIngredientsResponse(BaseModel):
    ingredients: List[str]
    categories: Dict[str, str]


class GetRecipesRequest(BaseModel):
    ingredients: List[str] = Field(default_factory=list)


class RecipeResult(BaseModel):
    name: str
    match: str
    missing: List[str]
    score: float


class GetRecipesResponse(BaseModel):
    top_5: List[RecipeResult]


class RecommendMoreRequest(BaseModel):
    ingredients: List[str] = Field(default_factory=list)
    missing: List[str] = Field(default_factory=list)


class RecommendMoreResponse(BaseModel):
    substitutes: Dict[str, List[str]]
    extra_suggestions: List[str]
    explanations: Dict[str, str] = Field(default_factory=dict)


class FeedbackRequest(BaseModel):
    user_id: Optional[str] = None
    recipe_name: str
    action: str
    context: Dict[str, Any] = Field(default_factory=dict)


class FeedbackResponse(BaseModel):
    status: str


def _ensure_services() -> Dict[str, Any]:
    if not hasattr(app.state, "services"):
        category_classifier = CategoryClassifier()
        app.state.services = {
            "category_classifier": category_classifier,
            "voice_pipeline": VoicePipeline(category_classifier=category_classifier),
            "recipe_intelligence": RecipeIntelligence(),
            "feedback_store": FeedbackStore(),
            "user_history_store": UserHistoryStore(),
        }
    return app.state.services


@app.get("/health")
def health() -> Dict[str, str]:
    return {"status": "healthy"}


@app.post("/api/voice-to-ingredients", response_model=VoiceToIngredientsResponse)
async def voice_to_ingredients(
    request: Request,
    audio: Optional[UploadFile] = File(default=None),
) -> VoiceToIngredientsResponse:
    services = _ensure_services()
    voice_pipeline: VoicePipeline = services["voice_pipeline"]

    audio_bytes: Optional[bytes] = None
    if audio is not None:
        audio_bytes = await audio.read()
    else:
        payload: Optional[Dict[str, Any]] = None
        content_type = (request.headers.get("content-type") or "").lower()
        if "application/json" in content_type:
            try:
                maybe = await request.json()
                if isinstance(maybe, dict):
                    payload = maybe
            except Exception:
                payload = None

        b64 = (payload or {}).get("audio_base64") or (payload or {}).get("audio")
        if isinstance(b64, str) and b64.strip():
            try:
                audio_bytes = base64.b64decode(b64, validate=False)
            except Exception as e:
                raise HTTPException(status_code=400, detail=f"Invalid base64 audio: {e}") from e

    if not audio_bytes:
        raise HTTPException(status_code=400, detail="Provide audio as multipart file or base64 in JSON.")

    with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as tmp:
        tmp.write(audio_bytes)
        tmp_path = tmp.name

    try:
        result = voice_pipeline.process_audio_file(tmp_path)
        return VoiceToIngredientsResponse(**result)
    finally:
        try:
            os.remove(tmp_path)
        except Exception:
            pass


@app.post("/api/get-recipes", response_model=GetRecipesResponse)
def get_recipes(req: GetRecipesRequest) -> GetRecipesResponse:
    services = _ensure_services()
    recipe_intelligence: RecipeIntelligence = services["recipe_intelligence"]
    top_5 = recipe_intelligence.get_top_recipes(req.ingredients, k=5)
    return GetRecipesResponse(top_5=[RecipeResult(**r) for r in top_5])


@app.post("/api/recommend-more", response_model=RecommendMoreResponse)
def recommend_more(req: RecommendMoreRequest) -> RecommendMoreResponse:
    services = _ensure_services()
    recipe_intelligence: RecipeIntelligence = services["recipe_intelligence"]
    result = recipe_intelligence.recommend_more(req.ingredients, req.missing)
    return RecommendMoreResponse(**result)


@app.post("/api/feedback", response_model=FeedbackResponse)
def feedback(req: FeedbackRequest) -> FeedbackResponse:
    services = _ensure_services()
    store: FeedbackStore = services["feedback_store"]
    history: UserHistoryStore = services["user_history_store"]
    action = (req.action or "").strip().lower()
    if action not in {"liked", "disliked"}:
        raise HTTPException(status_code=400, detail="action must be 'liked' or 'disliked'")
    store.append_feedback(
        user_id=req.user_id,
        recipe_name=req.recipe_name,
        action=action,
        context=req.context,
    )
    history.append_event(
        user_id=req.user_id,
        event_type="recipe_feedback",
        payload={"recipe_name": req.recipe_name, "action": action, "context": req.context},
    )
    return FeedbackResponse(status="ok")

