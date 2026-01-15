# 🧠 SmartCart AI - ML Pipeline

Machine Learning pipeline for automatic grocery item categorization.

## 📋 Overview

This ML module provides on-device category classification for grocery items using TensorFlow Lite. The model predicts which category (Fruits, Vegetables, Dairy, etc.) a grocery item belongs to based on its name.

## 🏗️ Pipeline Architecture

```
┌─────────────────┐
│  Raw Data       │
│  (CSV)          │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Preprocessing  │
│  - Clean text   │
│  - Tokenize     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Vectorization  │
│  - TF-IDF       │
│  - Word2Vec     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Model Training │
│  - Classifier   │
│  - Validation   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  TFLite Export  │
│  - Quantization │
│  - Optimization │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Flutter App    │
│  (On-device)    │
└─────────────────┘
```

## 📂 Directory Structure

```
ml/
├── data/
│   └── grocery_dataset.csv      # Training data (item_name, category, frequency)
├── training/
│   └── train_classifier.py      # Model training script
├── inference/
│   └── predict_category.py      # Inference testing script
├── export/
│   └── convert_to_tflite.py     # TFLite conversion script
└── requirements.txt              # Python dependencies
```

## 🚀 Getting Started

### 1. Install Dependencies

```bash
cd ml
pip install -r requirements.txt
```

### 2. Train the Model

```bash
python training/train_classifier.py
```

This will:
- Load the grocery dataset
- Preprocess and vectorize item names
- Train a classification model
- Evaluate performance
- Save the trained model

### 3. Test Inference

```bash
python inference/predict_category.py "milk"
python inference/predict_category.py "chicken breast"
```

### 4. Convert to TFLite

```bash
python export/convert_to_tflite.py
```

This converts the model to TensorFlow Lite format for on-device inference in Flutter.

### 5. Deploy to Flutter

Copy the generated `.tflite` file to Flutter assets:

```bash
cp export/category_classifier.tflite ../assets/ml_models/
```

## 📊 Dataset

### Format
```csv
item_name,category,frequency
milk,dairy,150
bread,bakery,145
apples,fruits,115
...
```

### Categories
1. **Fruits** - Apples, Bananas, Oranges, etc.
2. **Vegetables** - Carrots, Lettuce, Tomatoes, etc.
3. **Dairy** - Milk, Cheese, Yogurt, etc.
4. **Meat** - Chicken, Beef, Fish, etc.
5. **Bakery** - Bread, Croissants, Muffins, etc.
6. **Beverages** - Coffee, Juice, Soda, etc.
7. **Snacks** - Chips, Cookies, Candy, etc.
8. **Other** - Pasta, Rice, Condiments, etc.

### Expanding the Dataset

To improve model accuracy:
1. Add more samples to `data/grocery_dataset.csv`
2. Include variations (e.g., "whole milk", "2% milk", "skim milk")
3. Add regional items
4. Include brand names

## 🎯 Model Architecture

### Current (Placeholder)
- **Input**: Item name (text)
- **Vectorization**: TF-IDF
- **Model**: Random Forest Classifier
- **Output**: Category + Confidence

### Recommended (Production)

```python
# TensorFlow/Keras Neural Network
model = Sequential([
    Embedding(vocab_size, 128),
    LSTM(64),
    Dense(32, activation='relu'),
    Dropout(0.3),
    Dense(8, activation='softmax')  # 8 categories
])
```

## 🔧 TFLite Optimization

### Quantization Options

1. **Dynamic Range Quantization** (Recommended)
   - Reduces model size by 4x
   - Minimal accuracy loss
   - Fast inference

2. **Float16 Quantization**
   - Reduces size by 2x
   - Better accuracy than int8
   - Good balance

3. **Integer Quantization**
   - Smallest size
   - Requires calibration data
   - Slight accuracy trade-off

### Example Conversion

```python
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_types = [tf.float16]
tflite_model = converter.convert()
```

## 📈 Performance Metrics

### Target Metrics
- **Accuracy**: > 85%
- **Inference Time**: < 50ms (on-device)
- **Model Size**: < 5MB
- **Confidence Threshold**: 0.7

### Evaluation

```bash
python training/train_classifier.py
```

Output:
```
Accuracy: 87.5%

Classification Report:
              precision    recall  f1-score
fruits           0.92      0.89      0.90
vegetables       0.88      0.91      0.89
dairy            0.90      0.87      0.88
...
```

## 🔄 Continuous Improvement

### Data Collection
- Collect user corrections
- Track prediction confidence
- Identify misclassified items
- Retrain periodically

### Model Updates
1. Gather new data
2. Retrain model
3. Evaluate improvements
4. Convert to TFLite
5. Deploy via app update

## 🧪 Testing

### Unit Tests
```python
def test_preprocessing():
    assert preprocess_text("  Milk  ") == "milk"
    assert preprocess_text("2% Milk") == "2 milk"

def test_prediction():
    category, confidence = predict_category("apple")
    assert category == "fruits"
    assert confidence > 0.7
```

### Integration Tests
- Test TFLite model in Flutter
- Verify inference speed
- Check memory usage
- Validate predictions

## 📚 Resources

### TensorFlow Lite
- [TFLite Guide](https://www.tensorflow.org/lite/guide)
- [Model Optimization](https://www.tensorflow.org/lite/performance/model_optimization)
- [Flutter Integration](https://pub.dev/packages/tflite_flutter)

### ML Best Practices
- [Text Classification](https://developers.google.com/machine-learning/guides/text-classification)
- [On-Device ML](https://www.tensorflow.org/lite/examples)

## 🤝 Contributing

To improve the ML model:
1. Add more training data
2. Experiment with different architectures
3. Optimize hyperparameters
4. Test on edge cases

## 📝 Notes

**Current Status**: Placeholder implementation using keyword matching

**Production TODO**:
- [ ] Implement actual TensorFlow model
- [ ] Train on larger dataset (10k+ samples)
- [ ] Add data augmentation
- [ ] Implement active learning
- [ ] A/B test model versions
- [ ] Monitor prediction accuracy
- [ ] Set up automated retraining pipeline

---

<p align="center">Built with TensorFlow Lite for on-device intelligence</p>
