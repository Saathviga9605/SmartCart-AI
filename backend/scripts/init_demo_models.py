import os
import torch
import torch.nn as nn
import sys

# Add parent directory to path to import models
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from models.set_transformer import SetTransformer
from models.autoencoder import RecipeAutoencoder

def init_demo_models():
    print("Initializing DEMO models for SmartCart AI...")
    
    checkpoint_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'models', 'checkpoints')
    os.makedirs(checkpoint_dir, exist_ok=True)

    # 1. Initialize Set Transformer (SKIP if already trained)
    print("1. Creating Set Transformer (Ingredient Matcher)...")
    st_path = os.path.join(checkpoint_dir, 'set_transformer.pth')
    if os.path.exists(st_path):
        print(f"   SKIPPED - Already exists at {st_path}")
    else:
        model_st = SetTransformer(dim_input=100, num_outputs=1, dim_output=1, num_inds=32, dim_hidden=128, num_heads=4, ln=False)
        torch.save(model_st.state_dict(), st_path)
        print(f"   Saved to {st_path}")

    # 2. Initialize Autoencoder
    print("2. Creating Recipe Autoencoder (Suggester)...")
    # Vocab size 2000 (assumed for demo), dim 128
    model_ae = RecipeAutoencoder(vocab_size=2000, embed_dim=128, num_heads=4, hidden_dim=256)
    torch.save(model_ae.state_dict(), os.path.join(checkpoint_dir, 'autoencoder.pth'))
    print(f"   Saved to {os.path.join(checkpoint_dir, 'autoencoder.pth')}")

    # 3. Create Dummy LightGBM Ranker
    print("3. Creating Dummy LightGBM Ranker...")
    try:
        import lightgbm as lgb
        import numpy as np
        
        # Create dummy data for a binary classification task
        X = np.random.rand(10, 4)  # 10 samples, 4 features (matches recipe_intelligence.py)
        y = np.random.randint(0, 2, 10)  # Binary target
        train_data = lgb.Dataset(X, label=y)
        
        # Train a tiny model
        params = {'objective': 'binary', 'verbosity': -1}
        bst = lgb.train(params, train_data, num_boost_round=1)
        
        lgbm_path = os.path.join(checkpoint_dir, 'lgbm_ranker.txt')
        bst.save_model(lgbm_path)
        print(f"   Saved to {lgbm_path}")
    except ImportError:
        print("   LightGBM not installed, skipping ranker creation.")
        # Fallback to text file if lib not found (which caused the error, but better than nothing?)
        # actually, the error "doesn't specify number of classes" implies the text file was too empty.
        # We'll just leave it skipped if import fails, but it should succeed.

    print("\nSUCCESS: All ML models are initialized for DEMO mode!")
    print("You can now run 'python app.py' and the ML services will load these models.")

if __name__ == "__main__":
    init_demo_models()
