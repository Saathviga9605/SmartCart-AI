import os


def main() -> None:
    os.environ.setdefault("HF_HUB_DISABLE_TELEMETRY", "1")

    try:
        from transformers import AutoModelForSeq2SeqLM, AutoTokenizer, pipeline
    except Exception as e:
        raise SystemExit(f"transformers is required: {e}")

    whisper_model = os.environ.get("SMARTPANTRY_WHISPER_MODEL", "openai/whisper-tiny")
    ner_model = os.environ.get("SMARTPANTRY_NER_MODEL", "elastic/distilbert-base-uncased-finetuned-conll03-english")
    t5_model = os.environ.get("SMARTPANTRY_T5_MODEL", "t5-small")

    pipeline("automatic-speech-recognition", model=whisper_model)
    pipeline("token-classification", model=ner_model, aggregation_strategy="simple")
    AutoTokenizer.from_pretrained(t5_model)
    AutoModelForSeq2SeqLM.from_pretrained(t5_model)

    print("Downloaded/initialized models:")
    print(f"- ASR: {whisper_model}")
    print(f"- NER: {ner_model}")
    print(f"- T5:  {t5_model}")


if __name__ == "__main__":
    main()

