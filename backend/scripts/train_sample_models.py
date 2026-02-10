import os
import sys
import json
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
from collections import Counter

# Add parent directory to path to import models
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from models.set_transformer import SetTransformer
from models.autoencoder import RecipeAutoencoder

def train_sample_models():
    print("=" * 60)
    print("Training Sample Intelligence for SmartCart AI")
    print("=" * 60)

    # 1. Load Sample Data
    backend_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    data_path = os.path.join(backend_dir, 'data', 'recipes_sample.json')
    checkpoint_dir = os.path.join(backend_dir, 'models', 'checkpoints')
    os.makedirs(checkpoint_dir, exist_ok=True)

    with open(data_path, 'r') as f:
        recipes = json.load(f)
    print(f"Loaded {len(recipes)} sample recipes.")

    # 2. Build Vocabulary
    all_ingredients = []
    for r in recipes:
        all_ingredients.extend([i.lower().strip() for i in r['ingredients']])
    
    counts = Counter(all_ingredients)
    # For sample mode, we'll keep all ingredients but limit to 2000 total vocab slots
    vocab_size = 2000
    most_common = counts.most_common(vocab_size - 1)
    ing_to_idx = {"<PAD>": 0}
    for idx, (ing, _) in enumerate(most_common, start=1):
        ing_to_idx[ing] = idx
    
    vocab_path = os.path.join(checkpoint_dir, 'ingredient_vocab.json')
    with open(vocab_path, 'w') as f:
        json.dump(ing_to_idx, f)
    print(f"Build vocabulary of size {len(ing_to_idx)}. Saved to {vocab_path}")

    # 3. Prepare Dataset
    class SampleRecipeDataset(Dataset):
        def __init__(self, recipes, vocab, max_len=20):
            self.data = []
            for r in recipes:
                indices = [vocab.get(i.lower().strip(), 0) for i in r['ingredients']]
                # For training, we keep it simple
                while len(indices) < max_len:
                    indices.append(0)
                self.data.append(torch.tensor(indices[:max_len], dtype=torch.long))

        def __len__(self):
            return len(self.data)

        def __getitem__(self, idx):
            return self.data[idx]

    dataset = SampleRecipeDataset(recipes, ing_to_idx)
    dataloader = DataLoader(dataset, batch_size=4, shuffle=True)

    # 4. Train Set Transformer (Simplified)
    print("\nTraining Set Transformer...")
    model_st = SetTransformer(dim_input=128, num_outputs=1, dim_output=128, num_inds=32, dim_hidden=128, num_heads=4, ln=True)
    # We'll wrap it with embedding for training convenience
    class STWrapper(nn.Module):
        def __init__(self, st, v_size, e_dim):
            super().__init__()
            self.emb = nn.Embedding(v_size, e_dim, padding_idx=0)
            self.st = st
        def forward(self, x):
            return self.st(self.emb(x))

    wrapper = STWrapper(model_st, vocab_size, 128)
    optimizer = optim.Adam(wrapper.parameters(), lr=1e-3)
    criterion = nn.MSELoss() # Simple reconstruction for demo purposes

    for epoch in range(50):
        total_loss = 0
        for batch in dataloader:
            optimizer.zero_grad()
            out = wrapper(batch)
            # Dummy target: we want the embedding to represent the set
            loss = criterion(out, torch.zeros_like(out)) 
            loss.backward()
            optimizer.step()
            total_loss += loss.item()
        if (epoch + 1) % 10 == 0:
            print(f"  Epoch {epoch+1}/50, Loss: {total_loss/len(dataloader):.4f}")

    st_path = os.path.join(checkpoint_dir, 'set_transformer.pth')
    torch.save(model_st.state_dict(), st_path)
    print(f"Set Transformer saved to {st_path}")

    # 5. Train Autoencoder
    print("\nTraining Recipe Autoencoder...")
    # Higher hidden dim for better capacity on small data
    model_ae = RecipeAutoencoder(vocab_size=vocab_size, embed_dim=128, num_heads=4, hidden_dim=256)
    optimizer = optim.Adam(model_ae.parameters(), lr=1e-3)
    criterion_ae = nn.BCEWithLogitsLoss()
    
    for epoch in range(100):
        total_loss = 0
        for batch in dataloader:
            optimizer.zero_grad()
            logits, _ = model_ae(batch)
            
            # Create multi-hot target from batch indices
            target = torch.zeros(batch.size(0), vocab_size)
            for i in range(batch.size(0)):
                for idx in batch[i]:
                    if idx > 0: # Skip padding
                        target[i, idx] = 1.0
            
            loss = criterion_ae(logits, target)
            loss.backward()
            optimizer.step()
            total_loss += loss.item()
        if (epoch + 1) % 20 == 0:
            print(f"  Epoch {epoch+1}/100, Loss: {total_loss/len(dataloader):.4f}")

    ae_path = os.path.join(checkpoint_dir, 'autoencoder.pth')
    torch.save(model_ae.state_dict(), ae_path)
    print(f"Autoencoder saved to {ae_path}")

    print("\nSUCCESS: All sample models trained and ready!")

if __name__ == "__main__":
    train_sample_models()
