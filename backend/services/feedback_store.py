import json
import os
import time
from pathlib import Path
from threading import Lock
from typing import Any, Dict, Optional


class FeedbackStore:
    def __init__(self) -> None:
        repo_root = Path(__file__).resolve().parents[2]
        self._data_dir = repo_root / "backend" / "data"
        self._data_dir.mkdir(parents=True, exist_ok=True)
        self._path = self._data_dir / "feedback.jsonl"
        self._lock = Lock()

    def append_feedback(
        self,
        user_id: Optional[str],
        recipe_name: str,
        action: str,
        context: Dict[str, Any],
    ) -> None:
        record = {
            "ts": int(time.time()),
            "user_id": user_id,
            "recipe_name": recipe_name,
            "action": action,
            "context": context or {},
        }
        line = json.dumps(record, ensure_ascii=False)
        with self._lock:
            with open(self._path, "a", encoding="utf-8") as f:
                f.write(line + "\n")

