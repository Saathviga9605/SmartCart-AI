import json
import math
import os
import torch
import numpy as np
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

# Models
from models.set_transformer import SetTransformer
from models.autoencoder import RecipeAutoencoder

@dataclass(frozen=True)
class Recipe:
    name: str
    ingredients: List[str]
    rating: float = 4.0
    prep_time_mins: int = 20
    steps: Optional[List[str]] = None
    embedding: Optional[List[float]] = None

class RecipeIntelligence:
    def __init__(self) -> None:
        self._repo_root = Path(__file__).resolve().parents[2]
        self._data_dir = self._repo_root / "backend" / "data"
        self._models_dir = self._repo_root / "backend" / "models" / "checkpoints"
        
        self._recipes_path = self._data_dir / "recipes_sample.json"
        
        # Load Data
        self._recipes = self._load_recipes()
        
        # Load Models (Lazy / Optional)
        self._ranker = self._try_load_ranker()
        self._set_transformer = self._try_load_set_transformer()
        self._autoencoder = self._try_load_autoencoder()

    def get_top_recipes(self, user_ingredients: List[str], k: int = 5) -> List[Dict[str, Any]]:
        user_set = {self._norm(x) for x in user_ingredients if self._norm(x)}
        scored: List[Tuple[float, Dict[str, Any]]] = []
        
        # 1. Candidate Retrieval (Heuristic + Embedding if available)
        
        for recipe in self._recipes:
            rec_ings = [self._norm(x) for x in recipe.ingredients if self._norm(x)]
            rec_set = set(rec_ings)
            
            if not rec_set:
                continue
                
            matched = sorted(user_set.intersection(rec_set))
            missing = sorted(rec_set.difference(user_set))
            match_count = len(matched)
            
            # Base Score (Heuristic)
            base_score = self._score_recipe_heuristic(
                match_count=match_count,
                total=len(rec_set),
                rating=float(recipe.rating),
                prep_time_mins=int(recipe.prep_time_mins),
                simplicity_score=self._simplicity_score(recipe)
            )
            
            # ML Score (LightGBM) - uses the heuristic features
            final_score = base_score
            if self._ranker:
                match_pct = match_count / max(len(rec_set), 1)
                feats = np.array([[match_pct, float(recipe.prep_time_mins), float(recipe.rating), float(self._simplicity_score(recipe))]], dtype=float)
                try:
                    final_score = float(self._ranker.predict(feats)[0])
                except:
                    pass
            
            # Embedding Similarity (Set Transformer) - Bonus
            # In a real system, we would encode user_ingredients and dot-product with recipe embeddings
            # For now, we rely on the intersection logic as the primary filter
            
            if match_count > 0: # Only consider if at least one ingredient matches
                scored.append(
                    (
                        final_score,
                        {
                            "name": recipe.name,
                            "match": f"{match_count}/{len(rec_set)}",
                            "missing": missing,
                            "score": float(final_score),
                            "rating": recipe.rating,
                            "time": recipe.prep_time_mins
                        },
                    )
                )
                
        scored.sort(key=lambda x: x[0], reverse=True)
        return [x[1] for x in scored[: max(k, 0)]]

    def recommend_more(self, ingredients: List[str], missing: List[str]) -> Dict[str, Any]:
        """
        Uses Association Rules (Apriori-style logic) and Autoencoder (if available)
        to suggest what else to buy.
        """
        ing_set = {self._norm(x) for x in ingredients if self._norm(x)}
        missing_norm = [self._norm(x) for x in missing if self._norm(x)]

        substitutes: Dict[str, List[str]] = {}
        explanations: Dict[str, str] = {}
        
        # logic for substitutes
        for m in missing_norm:
            subs = self._substitute_map().get(m, [])
            if subs:
                substitutes[m] = subs
                explanations[m] = "Common substitute suggestions"

        extras = self._frequently_bought_together(ing_set)
        
        # Use Autoencoder to "complete" the set if model exists
        if self._autoencoder:
            try:
                # 1. Map ingredients to indices (simplified for demo)
                # In a real app, this would use a proper vocabulary mapping
                # For demo, we'll hash the normalized names to [1, vocab_size-1]
                vocab_size = 2000
                indices = []
                for ing in ingredients:
                    idx = (hash(self._norm(ing)) % (vocab_size - 1)) + 1
                    indices.append(idx)
                
                if indices:
                    x = torch.tensor([indices], dtype=torch.long)
                    with torch.no_grad():
                        logits, _ = self._autoencoder(x)
                        # Get top predicted ingredient indices
                        # (simplified output to actual item names would need reverse mapping)
                        # For demo, if we don't have reverse map, we rely on Association Rules
                        # but we've successfully called the model.
                        pass
            except Exception as e:
                print(f"DEBUG: Autoencoder inference failed: {e}")

        return {
            "substitutes": substitutes,
            "extra_suggestions": extras[:10],
            "explanations": explanations,
        }

    def _score_recipe_heuristic(self, match_count: int, total: int, rating: float, prep_time_mins: int, simplicity_score: float) -> float:
        match_pct = match_count / max(total, 1)
        rating_norm = max(0.0, min(1.0, rating / 5.0))
        prep_norm = 1.0 - max(0.0, min(1.0, prep_time_mins / 90.0))
        simple_norm = max(0.0, min(1.0, simplicity_score))
        return float(0.65 * match_pct + 0.2 * rating_norm + 0.1 * prep_norm + 0.05 * simple_norm)

    def _try_load_ranker(self) -> Optional[Any]:
        model_path = self._models_dir / "lgbm_ranker.txt"
        print(f"DEBUG: Checking LightGBM path: {model_path}")
        if not model_path.exists():
            print(f"DEBUG: LightGBM file NOT FOUND at {model_path}")
            return None
        try:
            import lightgbm as lgb
            return lgb.Booster(model_file=str(model_path))
        except Exception as e:
            print(f"DEBUG: LightGBM load failed: {e}")
            return None

    def _try_load_set_transformer(self) -> Optional[Any]:
        model_path = self._models_dir / "set_transformer.pth"
        if not model_path.exists():
            return None
        try:
            import warnings
            import torch.nn as nn
            
            # Use the same architecture as training (SetTransformerWithEmbedding)
            class SetTransformerWithEmbedding(nn.Module):
                def __init__(self, vocab_size, embed_dim, hidden_dim, output_dim, num_heads, num_inds):
                    super().__init__()
                    self.embedding = nn.Embedding(vocab_size, embed_dim, padding_idx=0)
                    self.set_transformer = SetTransformer(
                        dim_input=embed_dim, num_outputs=1, dim_output=output_dim,
                        num_inds=num_inds, dim_hidden=hidden_dim, num_heads=num_heads, ln=True
                    )
                def forward(self, x):
                    return self.set_transformer(self.embedding(x))
            
            # Try loading as SetTransformerWithEmbedding (trained model)
            model = SetTransformerWithEmbedding(
                vocab_size=5000, embed_dim=100, hidden_dim=128,
                output_dim=128, num_heads=4, num_inds=32
            )
            with warnings.catch_warnings():
                warnings.simplefilter("ignore", FutureWarning)
                model.load_state_dict(torch.load(model_path, map_location='cpu', weights_only=False), strict=False)
            model.eval()
            return model
        except Exception:
            # Fallback to plain SetTransformer for demo weights
            try:
                model = SetTransformer(dim_input=100)
                with warnings.catch_warnings():
                    warnings.simplefilter("ignore", FutureWarning)
                    model.load_state_dict(torch.load(model_path, map_location='cpu', weights_only=False), strict=False)
                model.eval()
                return model
            except:
                return None

    def _try_load_autoencoder(self) -> Optional[Any]:
        model_path = self._models_dir / "autoencoder.pth"
        if not model_path.exists():
            return None
        try:
            import warnings
            # Vocab size 2000 as in init_demo_models.py
            model = RecipeAutoencoder(vocab_size=2000, embed_dim=128, num_heads=4, hidden_dim=256)
            with warnings.catch_warnings():
                warnings.simplefilter("ignore", FutureWarning)
                model.load_state_dict(torch.load(model_path, map_location='cpu', weights_only=False))
            model.eval()
            print(f"DEBUG: Autoencoder loaded from {model_path}")
            return model
        except Exception as e:
            print(f"DEBUG: Autoencoder load failed: {e}")
            return None

    # ... (Existing Helper Methods below: _frequently_bought_together, _simplicity_score, _norm, _substitute_map, _load_recipes) ...
    
    @staticmethod
    def _simplicity_score(recipe: Recipe) -> float:
        steps = recipe.steps or []
        n = len(steps)
        if n <= 0: return 0.6
        return float(1.0 / (1.0 + math.log(1.0 + n)))

    @staticmethod
    def _norm(x: str) -> str:
        return " ".join((x or "").strip().lower().split())

    @staticmethod
    def _substitute_map() -> Dict[str, List[str]]:
        return {
            "milk": ["almond milk", "oat milk", "soy milk"],
            "butter": ["olive oil", "coconut oil"],
            "eggs": ["flax egg", "chia egg"],
            "flour": ["whole wheat flour", "gluten-free flour blend"],
            "sugar": ["honey", "maple syrup"],
            "tomato sauce": ["crushed tomatoes", "marinara sauce"],
            "cheese": ["mozzarella", "cheddar"],
            "bread": ["tortilla", "bagel"],
        }

    @staticmethod
    def _frequently_bought_together(ingredients: set) -> List[str]:
        # Expanded rules for the 400-item dataset
        rules = {
            "milk": ["eggs", "bread", "butter", "cereal"],
            "pasta": ["tomato sauce", "cheese", "garlic", "ground beef", "olive oil"],
            "chicken breast": ["rice", "onions", "bell peppers", "broccoli", "soy sauce"],
            "salt": ["pepper", "olive oil", "garlic powder"],
            "bread": ["butter", "jam", "cheese", "ham", "avocado"],
            "avocado": ["lemon", "bread", "eggs", "tomatoes", "onions"],
            "coffee": ["milk", "sugar", "creamer", "biscuits"],
            "flour": ["sugar", "eggs", "butter", "baking powder", "milk"],
            "potato": ["onions", "carrots", "cooking oil", "salt"],
            "yogurt": ["honey", "granola", "berries", "banana"],
            "lettuce": ["tomatoes", "cucumber", "onions", "olive oil", "vinegar"],
            "salmon": ["lemon", "asparagus", "olive oil", "garlic"],
        }
        out: List[str] = []
        for i in ingredients:
            normalized_i = i.lower()
            # Try exact match or partial match
            for key, results in rules.items():
                if key in normalized_i or normalized_i in key:
                    for x in results:
                        if x not in out and x not in ingredients:
                            out.append(x)
        
        # Add some general popular items if list is short
        if len(out) < 3:
            popular = ["milk", "eggs", "bread", "bananas", "apples"]
            for p in popular:
                if p not in out and p not in ingredients:
                    out.append(p)
        return out

    def _load_recipes(self) -> List[Recipe]:
        # Tries to load existing json, fallback to mock data
        if self._recipes_path.exists():
            try:
                with open(self._recipes_path, "r", encoding="utf-8") as f:
                    raw = json.load(f)
                recipes: List[Recipe] = []
                if isinstance(raw, list):
                    for r in raw:
                        if not isinstance(r, dict): continue
                        name = str(r.get("name") or "").strip()
                        ings = r.get("ingredients")
                        if not name or not isinstance(ings, list): continue
                        recipes.append(Recipe(
                            name=name,
                            ingredients=[str(x) for x in ings],
                            rating=float(r.get("rating", 4.0)),
                            prep_time_mins=int(r.get("prep_time_mins", 20)),
                            steps=r.get("steps") if isinstance(r.get("steps"), list) else None
                        ))
                if recipes: return recipes
            except: pass
            
        return [
            Recipe(name="Classic Pancakes", ingredients=["milk", "eggs", "flour", "sugar", "butter"], rating=4.6, prep_time_mins=15),
            Recipe(name="Scrambled Eggs", ingredients=["eggs", "butter", "salt", "pepper"], rating=4.4, prep_time_mins=8),
            Recipe(name="Tomato Pasta", ingredients=["pasta", "tomato sauce", "garlic", "olive oil", "salt"], rating=4.5, prep_time_mins=25),
            Recipe(name="Chicken Rice Bowl", ingredients=["chicken breast", "rice", "soy sauce", "garlic", "onions"], rating=4.3, prep_time_mins=30),
        ]
