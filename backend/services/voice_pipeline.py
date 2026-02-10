import re
from dataclasses import dataclass
from typing import Any, Dict, List, Optional, Sequence

from services.category_classifier import CategoryClassifier
from services.model_registry import ModelRegistry


_STOPWORDS = {
    "a",
    "an",
    "and",
    "the",
    "some",
    "please",
    "add",
    "buy",
    "get",
    "need",
    "want",
    "to",
    "of",
    "for",
    "with",
}


@dataclass(frozen=True)
class VoicePipelineResult:
    ingredients: List[str]
    categories: Dict[str, str]
    transcript: str
    normalized_text: str


class VoicePipeline:
    def __init__(self, category_classifier: CategoryClassifier) -> None:
        self._models = ModelRegistry()
        self._category_classifier = category_classifier

    def process_audio_file(self, audio_path: str) -> Dict[str, Any]:
        transcript = self._transcribe(audio_path)
        normalized = self._normalize_text(transcript)
        ingredients = self._extract_ingredients(normalized)
        categories = self._category_classifier.predict_map(ingredients)
        return {
            "ingredients": ingredients,
            "categories": categories,
            "transcript": transcript,
            "normalized_text": normalized,
        }

    def _transcribe(self, audio_path: str) -> str:
        asr = self._models.get_asr_pipeline()
        if asr is None:
            return ""
        try:
            out = asr(audio_path)
            if isinstance(out, dict) and isinstance(out.get("text"), str):
                return out["text"].strip()
            if isinstance(out, str):
                return out.strip()
            return ""
        except Exception:
            return ""

    def _normalize_text(self, text: str) -> str:
        t = (text or "").strip()
        t = re.sub(r"[\r\n]+", " ", t)
        t = re.sub(r"\s+", " ", t).strip()
        if not t:
            return ""
        t5 = self._models.get_text2text_pipeline()
        if t5 is None:
            return t.lower()
        try:
            # Simple prompt for T5-small
            prompt = f"summarize: {t}" 
            out = t5(prompt, max_new_tokens=64)
            if isinstance(out, list) and out and isinstance(out[0], dict) and isinstance(out[0].get("generated_text"), str):
                candidate = out[0]["generated_text"].strip().lower()
                # Sanity check: If model hallucinates the prompt or task name
                if candidate and "normalize" not in candidate and "summarize" not in candidate and len(candidate) < len(t) * 2:
                    return candidate
        except Exception:
            pass
        return t.lower()

    def _extract_ingredients(self, normalized_text: str) -> List[str]:
        text = (normalized_text or "").strip().lower()
        if not text:
            return []

        text = re.sub(r"[;|/]+", ",", text)
        text = re.sub(r"\s+(and|plus)\s+", ", ", text)
        text = re.sub(r"\s+", " ", text).strip()

        chunks = [c.strip() for c in re.split(r",|\n", text) if c.strip()]
        candidates: List[str] = []
        for c in chunks:
            c = re.sub(r"[^a-z0-9\s-]", " ", c)
            c = " ".join(c.split())
            if not c:
                continue
            tokens = [t for t in c.split() if t not in _STOPWORDS]
            if not tokens:
                continue
            candidate = " ".join(tokens).strip()
            if candidate:
                candidates.append(candidate)

        ner = self._models.get_ner_pipeline()
        if ner is None:
            return self._dedupe_preserve_order(candidates)

        merged = list(candidates)
        try:
            entities = ner(text)
            phrases = self._merge_ner_phrases(entities, text)
            merged.extend(phrases)
        except Exception:
            pass
        cleaned = [self._clean_item(x) for x in merged]
        cleaned = [x for x in cleaned if x]
        return self._dedupe_preserve_order(cleaned)

    @staticmethod
    def _merge_ner_phrases(entities: Any, text: str) -> List[str]:
        if not isinstance(entities, list):
            return []
        spans = []
        for e in entities:
            if not isinstance(e, dict):
                continue
            start = e.get("start")
            end = e.get("end")
            if isinstance(start, int) and isinstance(end, int) and 0 <= start < end <= len(text):
                spans.append((start, end))
        spans.sort()
        merged = []
        last_end = -1
        for start, end in spans:
            if start <= last_end:
                last_end = max(last_end, end)
                continue
            phrase = text[start:end].strip()
            if phrase:
                merged.append(phrase)
            last_end = end
        return merged

    @staticmethod
    def _clean_item(item: str) -> str:
        t = (item or "").strip().lower()
        t = re.sub(r"[^a-z0-9\s-]", " ", t)
        t = re.sub(r"\s+", " ", t).strip()
        t = t.strip("-").strip()
        return t

    @staticmethod
    def _dedupe_preserve_order(items: Sequence[str]) -> List[str]:
        out: List[str] = []
        seen = set()
        for x in items:
            key = x.strip().lower()
            if not key or key in seen:
                continue
            seen.add(key)
            out.append(x)
        return out

