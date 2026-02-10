import os
from functools import lru_cache
from typing import Any, Optional


class ModelRegistry:
    def __init__(self) -> None:
        self._disabled = os.environ.get("SMARTPANTRY_DISABLE_MODELS", "").strip().lower() in {"1", "true", "yes"}

    @lru_cache(maxsize=1)
    def get_asr_pipeline(self) -> Optional[Any]:
        if self._disabled:
            return None
        try:
            from transformers import pipeline
        except Exception:
            return None
        model_name = os.environ.get("SMARTPANTRY_WHISPER_MODEL", "openai/whisper-tiny")
        try:
            return pipeline("automatic-speech-recognition", model=model_name)
        except Exception:
            return None

    @lru_cache(maxsize=1)
    def get_text2text_pipeline(self) -> Optional[Any]:
        if self._disabled:
            return None
        model_name = os.environ.get("SMARTPANTRY_T5_MODEL", "t5-small")
        try:
            from transformers import pipeline

            # Try loading with default settings (downloads if needed)
            # If offline, this will fail after retries.
            return pipeline("text2text-generation", model=model_name)
        except Exception as e:
            # print(f"Failed to load pipeline: {e}")
            pass

        try:
            import torch
            from transformers import AutoModelForSeq2SeqLM, AutoTokenizer
        except Exception:
            return None

        try:
            tokenizer = AutoTokenizer.from_pretrained(model_name)
            model = AutoModelForSeq2SeqLM.from_pretrained(model_name)
        except Exception:
            return None

        class _Seq2SeqWrapper:
            def __call__(self, text: str, max_new_tokens: int = 64, **kwargs: Any) -> Any:
                t = (text or "").strip()
                if not t:
                    return [{"generated_text": ""}]
                inputs = tokenizer(t, return_tensors="pt")
                with torch.no_grad():
                    output_ids = model.generate(
                        **inputs,
                        max_new_tokens=int(max_new_tokens),
                    )
                out = tokenizer.decode(output_ids[0], skip_special_tokens=True)
                return [{"generated_text": out}]

        return _Seq2SeqWrapper()

    @lru_cache(maxsize=1)
    def get_ner_pipeline(self) -> Optional[Any]:
        if self._disabled:
            return None
        try:
            from transformers import pipeline
        except Exception:
            return None
        model_name = os.environ.get("SMARTPANTRY_NER_MODEL", "elastic/distilbert-base-uncased-finetuned-conll03-english")
        try:
            return pipeline("token-classification", model=model_name, aggregation_strategy="simple")
        except Exception:
            return None

