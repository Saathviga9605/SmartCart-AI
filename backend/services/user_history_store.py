import json
import time
from pathlib import Path
from threading import Lock
from typing import Any, Dict, Optional


class UserHistoryStore:
    def __init__(self) -> None:
        repo_root = Path(__file__).resolve().parents[2]
        self._data_dir = repo_root / "backend" / "data"
        self._data_dir.mkdir(parents=True, exist_ok=True)
        self._path = self._data_dir / "user_history.jsonl"
        self._lock = Lock()

    def append_event(self, user_id: Optional[str], event_type: str, payload: Dict[str, Any]) -> None:
        record = {
            "ts": int(time.time()),
            "user_id": user_id,
            "event_type": event_type,
            "payload": payload or {},
        }
        line = json.dumps(record, ensure_ascii=False)
        with self._lock:
            with open(self._path, "a", encoding="utf-8") as f:
                f.write(line + "\n")

