"""
Set Transformer Training Script for SmartCart AI

This script trains the Set Transformer model on a recipe dataset.
The model learns to encode ingredient sets into embeddings that can be used
to find similar recipes.

Dataset Required: Food.com Recipes (Kaggle)
Download from: https://www.kaggle.com/datasets/shuyangli94/food-com-recipes-and-user-interactions

Place the downloaded files in:
    backend/data/raw/RAW_recipes.csv

Usage:
    python backend/scripts/train_set_transformer.py
"""

import sys
import os
import json
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
import numpy as np
from pathlib import Path
from collections import Counter

# Add backend to path
current_dir = os.path.dirname(os.path.abspath(__file__))
backend_dir = os.path.dirname(current_dir)
sys.path.append(backend_dir)

from models.set_transformer import SetTransformer

# === Configuration ===
CONFIG = {
    "data_path": os.path.join(backend_dir, "data", "raw", "RAW_recipes.csv"),
    "checkpoint_dir": os.path.join(backend_dir, "models", "checkpoints"),
    "vocab_size": 5000,       # Top N ingredients to use
    "embed_dim": 100,         # Ingredient embedding dimension
    "hidden_dim": 128,        # Set Transformer hidden dimension
    "output_dim": 128,        # Output embedding dimension
    "num_heads": 4,
    "num_inds": 32,           # Inducing points for ISAB
    "batch_size": 64,
    "epochs": 1,
    "learning_rate": 1e-3,
    "max_ingredients": 20,    # Max ingredients per recipe
}

# === Dataset ===
class RecipeDataset(Dataset):
    """
    Dataset for training Set Transformer on recipe ingredients.
    Uses contrastive learning: similar recipes should have similar embeddings.
    """
    def __init__(self, recipes, ingredient_to_idx, max_len=20):
        self.recipes = recipes
        self.ingredient_to_idx = ingredient_to_idx
        self.max_len = max_len
        self.vocab_size = len(ingredient_to_idx)
    
    def __len__(self):
        return len(self.recipes)
    
    def __getitem__(self, idx):
        ingredients = self.recipes[idx]["ingredients"]
        # Convert to indices
        indices = [self.ingredient_to_idx.get(ing, 0) for ing in ingredients[:self.max_len]]
        # Pad
        while len(indices) < self.max_len:
            indices.append(0)  # Padding index
        return torch.tensor(indices, dtype=torch.long), len(ingredients)

def load_foodcom_data(csv_path):
    """
    Load Food.com dataset (RAW_recipes.csv).
    Expected columns: name, id, ingredients (as string list)
    """
    import csv
    import ast
    
    recipes = []
    print(f"Loading data from {csv_path}...")
    
    with open(csv_path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            try:
                # ingredients column is a string representation of a list
                ingredients = ast.literal_eval(row.get("ingredients", "[]"))
                if isinstance(ingredients, list) and len(ingredients) >= 2:
                    recipes.append({
                        "name": row.get("name", "Unknown"),
                        "ingredients": [str(i).lower().strip() for i in ingredients]
                    })
            except:
                continue
    
    print(f"Loaded {len(recipes)} recipes with 2+ ingredients.")
    return recipes

def build_vocab(recipes, vocab_size=5000):
    """Build ingredient vocabulary from recipes."""
    counter = Counter()
    for recipe in recipes:
        for ing in recipe["ingredients"]:
            counter[ing] += 1
    
    # Most common ingredients
    most_common = counter.most_common(vocab_size - 1)  # -1 for PAD token
    ingredient_to_idx = {"<PAD>": 0}
    for idx, (ing, _) in enumerate(most_common, start=1):
        ingredient_to_idx[ing] = idx
    
    print(f"Vocabulary size: {len(ingredient_to_idx)}")
    return ingredient_to_idx

# === Model Wrapper with Embedding ===
class SetTransformerWithEmbedding(nn.Module):
    """Wraps SetTransformer with an embedding layer for ingredient indices."""
    def __init__(self, vocab_size, embed_dim, hidden_dim, output_dim, num_heads, num_inds):
        super().__init__()
        self.embedding = nn.Embedding(vocab_size, embed_dim, padding_idx=0)
        self.set_transformer = SetTransformer(
            dim_input=embed_dim,
            num_outputs=1,
            dim_output=output_dim,
            num_inds=num_inds,
            dim_hidden=hidden_dim,
            num_heads=num_heads,
            ln=True
        )
    
    def forward(self, x):
        # x: (batch, seq_len) -> (batch, seq_len, embed_dim)
        embedded = self.embedding(x)
        # (batch, output_dim)
        return self.set_transformer(embedded)

# === Training Loop ===
def train_model(model, dataloader, optimizer, device, epochs):
    """
    Train using a simple contrastive-style loss.
    For simplicity, we use MSE between embeddings of the same recipe (positive pair)
    and push apart embeddings of different recipes (negative pair).
    """
    model.train()
    criterion = nn.TripletMarginLoss(margin=1.0)
    
    for epoch in range(epochs):
        total_loss = 0.0
        for batch_idx, (ingredients, lengths) in enumerate(dataloader):
            ingredients = ingredients.to(device)
            
            # Get embeddings
            embeddings = model(ingredients)  # (batch, output_dim)
            
            # Simple triplet loss: anchor, positive (same), negative (random other)
            # For training, we use batch shuffling as negatives
            anchor = embeddings
            positive = embeddings  # In real scenario, use augmented version
            negative = embeddings[torch.randperm(embeddings.size(0))]
            
            loss = criterion(anchor, positive, negative)
            
            optimizer.zero_grad()
            loss.backward()
            optimizer.step()
            
            total_loss += loss.item()
            
            if batch_idx % 100 == 0:
                print(f"  Batch {batch_idx}/{len(dataloader)}, Loss: {loss.item():.4f}")
        
        avg_loss = total_loss / len(dataloader)
        print(f"Epoch {epoch+1}/{epochs}, Avg Loss: {avg_loss:.4f}")
    
    return model

def main():
    print("=" * 60)
    print("Set Transformer Training for SmartCart AI")
    print("=" * 60)
    
    # Check if dataset exists
    data_path = CONFIG["data_path"]
    if not os.path.exists(data_path):
        print(f"\n[ERROR] Dataset not found at: {data_path}")
        print("\nPlease download the Food.com dataset from Kaggle:")
        print("  https://www.kaggle.com/datasets/shuyangli94/food-com-recipes-and-user-interactions")
        print("\nThen place 'RAW_recipes.csv' in:")
        print(f"  {os.path.dirname(data_path)}")
        return
    
    # Load data
    recipes = load_foodcom_data(data_path)
    if len(recipes) < 100:
        print("[ERROR] Not enough recipes loaded. Check the dataset file.")
        return
    
    # Build vocabulary
    ingredient_to_idx = build_vocab(recipes, CONFIG["vocab_size"])
    
    # Save vocabulary for inference
    vocab_path = os.path.join(CONFIG["checkpoint_dir"], "ingredient_vocab.json")
    os.makedirs(CONFIG["checkpoint_dir"], exist_ok=True)
    with open(vocab_path, "w") as f:
        json.dump(ingredient_to_idx, f)
    print(f"Saved vocabulary to {vocab_path}")
    
    # Create dataset and dataloader
    dataset = RecipeDataset(recipes, ingredient_to_idx, CONFIG["max_ingredients"])
    dataloader = DataLoader(dataset, batch_size=CONFIG["batch_size"], shuffle=True, num_workers=0)
    
    # Initialize model
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Using device: {device}")
    
    model = SetTransformerWithEmbedding(
        vocab_size=len(ingredient_to_idx),
        embed_dim=CONFIG["embed_dim"],
        hidden_dim=CONFIG["hidden_dim"],
        output_dim=CONFIG["output_dim"],
        num_heads=CONFIG["num_heads"],
        num_inds=CONFIG["num_inds"]
    ).to(device)
    
    optimizer = optim.Adam(model.parameters(), lr=CONFIG["learning_rate"])
    
    # Train
    print("\nStarting training...")
    model = train_model(model, dataloader, optimizer, device, CONFIG["epochs"])
    
    # Save model
    model_path = os.path.join(CONFIG["checkpoint_dir"], "set_transformer.pth")
    torch.save(model.state_dict(), model_path)
    print(f"\n[SUCCESS] Model saved to {model_path}")
    
    print("\nTraining complete! You can now run test_intelligence.py to verify.")

if __name__ == "__main__":
    main()
