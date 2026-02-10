import os
import pickle
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Tuple


@dataclass(frozen=True)
class CategoryPrediction:
    category: str
    confidence: float


class CategoryClassifier:
    def __init__(self) -> None:
        self._model = None
        self._vectorizer = None
        self._labels: Optional[List[str]] = None
        self._artifacts_dir = Path(__file__).resolve().parents[1] / "artifacts"
        self._artifacts_dir.mkdir(parents=True, exist_ok=True)
        self._model_path = self._artifacts_dir / "category_classifier.pkl"
        self._vectorizer_path = self._artifacts_dir / "category_vectorizer.pkl"
        self._load_or_train()

    def predict(self, item_name: str) -> CategoryPrediction:
        item = self._preprocess_text(item_name)
        if not item:
            return CategoryPrediction(category="other", confidence=0.0)
        if self._model is None or self._vectorizer is None:
            return CategoryPrediction(category="other", confidence=0.0)
        X = self._vectorizer.transform([item])
        category = self._model.predict(X)[0]
        confidence = 1.0
        if hasattr(self._model, "predict_proba"):
            probabilities = self._model.predict_proba(X)[0]
            confidence = float(max(probabilities))
        return CategoryPrediction(category=str(category), confidence=float(confidence))

    def predict_map(self, items: List[str]) -> Dict[str, str]:
        return {item: self.predict(item).category for item in items}

    def get_known_items(self) -> List[str]:
        """Returns a list of all item names from the grocery dataset."""
        try:
            import pandas as pd
            repo_root = Path(__file__).resolve().parents[2]
            dataset_path = repo_root / "ml" / "data" / "grocery_dataset.csv"
            if not dataset_path.exists():
                return []
            df = pd.read_csv(dataset_path)
            if "item_name" not in df.columns:
                return []
            return [str(x).strip() for x in df["item_name"].tolist()]
        except Exception:
            return []

    def _load_or_train(self) -> None:
        if self._model_path.exists() and self._vectorizer_path.exists():
            try:
                with open(self._model_path, "rb") as f:
                    self._model = pickle.load(f)
                with open(self._vectorizer_path, "rb") as f:
                    self._vectorizer = pickle.load(f)
                return
            except Exception:
                self._model = None
                self._vectorizer = None

        self._train_from_repo_dataset()
        if self._model is not None and self._vectorizer is not None:
            with open(self._model_path, "wb") as f:
                pickle.dump(self._model, f)
            with open(self._vectorizer_path, "wb") as f:
                pickle.dump(self._vectorizer, f)

    def _train_from_repo_dataset(self) -> None:
        try:
            import pandas as pd
            from sklearn.feature_extraction.text import TfidfVectorizer
            from sklearn.linear_model import LogisticRegression
        except Exception:
            self._model = None
            self._vectorizer = None
            return

        repo_root = Path(__file__).resolve().parents[2]
        dataset_path = repo_root / "ml" / "data" / "grocery_dataset.csv"
        if not dataset_path.exists():
            self._model = None
            self._vectorizer = None
            return

        df = pd.read_csv(dataset_path)
        if "item_name" not in df.columns or "category" not in df.columns:
            self._model = None
            self._vectorizer = None
            return

        texts = [self._preprocess_text(str(x)) for x in df["item_name"].tolist()]
        labels = [str(x).strip().lower() for x in df["category"].tolist()]
        pairs: List[Tuple[str, str]] = [(t, l) for t, l in zip(texts, labels) if t and l]
        if not pairs:
            self._model = None
            self._vectorizer = None
            return

        texts = [p[0] for p in pairs]
        labels = [p[1] for p in pairs]

        vectorizer = TfidfVectorizer(ngram_range=(1, 2), min_df=1)
        X = vectorizer.fit_transform(texts)

        model = LogisticRegression(max_iter=2000, n_jobs=1)
        model.fit(X, labels)

        self._model = model
        self._vectorizer = vectorizer
        self._labels = sorted(set(labels))

    @staticmethod
    def _preprocess_text(text: str) -> str:
        t = (text or "").lower().strip()
        t = "".join(ch for ch in t if ch.isalnum() or ch.isspace())
        t = " ".join(t.split())
        return t

