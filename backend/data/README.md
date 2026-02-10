# SmartCart AI - Data Management

This directory contains all datasets and processed files required for the Recipe Intelligence pipeline.

## 📂 Directory Structure & Required Datasets

Please download the following datasets and place them in the corresponding directories.

### 1. Food.com Recipes & Interactions
**Source**: [Kaggle - Food.com Recipes and Interactions](https://www.kaggle.com/datasets/shuyangli94/food-com-recipes-and-user-interactions)
**Used For**: Training Set Transformer, Autoencoder, and LightGBM Ranker.

-   **Place `RAW_recipes.csv`** here:
    `backend/data/raw/RAW_recipes.csv`
-   **Place `RAW_interactions.csv`** here (optional):
    `backend/data/raw/RAW_interactions.csv`

### 2. USDA FoodData Central
**Source**: [USDA FoodData Central](https://fdc.nal.usda.gov/download-datasets.html) (Download "Branded Foods" CSV)
**Used For**: Ingredient categorization and nutritional info.

-   **Place `food.csv`** (or extraction) here:
    `backend/data/raw/usda/food.csv`

### 3. Pre-trained Weights (If available)
If you have trained models, place them here:
-   `backend/models/checkpoints/set_transformer.pth`
-   `backend/models/checkpoints/autoencoder.pth`
-   `backend/models/checkpoints/lgbm_ranker.txt`

## 🔄 Automatic Processing

When you run the backend server (`python app.py`), the `RecipeIntelligence` service will:
1.  Check `backend/data/processed/` for cached embeddings.
2.  If missing, it will attempt to load from `backend/data/raw/` and generate them (this make take time on first run).
