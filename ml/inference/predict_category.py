"""
SmartCart AI - Category Prediction Inference Script

This script demonstrates how to use the trained model for inference.
In production, this would be replaced by on-device TFLite inference in Flutter.

USAGE:
    python predict_category.py "milk"
    python predict_category.py "chicken breast"
"""

import pickle
import sys

MODEL_PATH = '../export/category_classifier.pkl'
VECTORIZER_PATH = '../export/vectorizer.pkl'

def load_model():
    """Load trained model and vectorizer"""
    with open(MODEL_PATH, 'rb') as f:
        model = pickle.load(f)
    
    with open(VECTORIZER_PATH, 'rb') as f:
        vectorizer = pickle.load(f)
    
    return model, vectorizer

def preprocess_text(text):
    """Clean and preprocess item name"""
    text = text.lower().strip()
    text = ''.join(char for char in text if char.isalnum() or char.isspace())
    return text

def predict_category(item_name, model, vectorizer):
    """
    Predict category for a grocery item
    
    Returns:
        category: Predicted category name
        confidence: Prediction confidence (0-1)
    """
    # Preprocess
    item_clean = preprocess_text(item_name)
    
    # Vectorize
    X = vectorizer.transform([item_clean])
    
    # Predict
    category = model.predict(X)[0]
    
    # Get confidence (probability)
    if hasattr(model, 'predict_proba'):
        probabilities = model.predict_proba(X)[0]
        confidence = max(probabilities)
    else:
        confidence = 1.0  # Default for models without probability
    
    return category, confidence

def main():
    """Main inference function"""
    if len(sys.argv) < 2:
        print("Usage: python predict_category.py <item_name>")
        print("Example: python predict_category.py 'milk'")
        return
    
    item_name = ' '.join(sys.argv[1:])
    
    print(f"Loading model...")
    model, vectorizer = load_model()
    
    print(f"\nPredicting category for: '{item_name}'")
    category, confidence = predict_category(item_name, model, vectorizer)
    
    print(f"\nPredicted Category: {category}")
    print(f"Confidence: {confidence:.2%}")

if __name__ == "__main__":
    main()
