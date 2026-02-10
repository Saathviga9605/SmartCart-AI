import torch
import torch.nn as nn
import torch.nn.functional as F

class RecipeAutoencoder(nn.Module):
    """
    Bidirectional Sparse Attention Autoencoder for Recipes.
    Learns to reconstruct ingredient sets (denoising/completion).
    """
    def __init__(self, vocab_size, embed_dim=128, num_heads=4, hidden_dim=256, dropout=0.1):
        super(RecipeAutoencoder, self).__init__()
        self.embedding = nn.Embedding(vocab_size, embed_dim, padding_idx=0)
        
        # Encoder (Transformer Encoder)
        encoder_layer = nn.TransformerEncoderLayer(d_model=embed_dim, nhead=num_heads, 
                                                   dim_feedforward=hidden_dim, dropout=dropout,
                                                   batch_first=True)
        self.encoder = nn.TransformerEncoder(encoder_layer, num_layers=2)
        
        # Bottleneck / Latent representation
        self.fc_mu = nn.Linear(embed_dim, embed_dim)
        
        # Decoder (MLP for set prediction - simplistic approach for sets)
        # In a full sequence model, we'd use a TransformerDecoder
        self.decoder_head = nn.Sequential(
            nn.Linear(embed_dim, hidden_dim),
            nn.ReLU(),
            nn.Linear(hidden_dim, vocab_size)
        )

    def forward(self, x, mask=None):
        # x: (Batch, Num_Ingredients) indices
        # mask: (Batch, Num_Ingredients) boolean mask (True for padding)
        
        emb = self.embedding(x) # (B, N, E)
        
        # Transformer encoding
        # src_key_padding_mask expects True for padding
        encoded = self.encoder(emb, src_key_padding_mask=mask) 
        
        # Pooling (Mean pooling over set elements, ignoring padding)
        if mask is not None:
            mask_expanded = mask.unsqueeze(-1) # (B, N, 1)
            emb_masked = encoded.masked_fill(mask_expanded, 0.0)
            sum_emb = emb_masked.sum(dim=1)
            count = (~mask).sum(dim=1, keepdim=True).float()
            pooled = sum_emb / (count + 1e-9)
        else:
            pooled = encoded.mean(dim=1)
            
        latent = self.fc_mu(pooled)
        
        # Predict probability of each ingredient in the vocabulary being present
        # Multi-label classification logic
        logits = self.decoder_head(latent) 
        return logits, latent

if __name__ == "__main__":
    vocab = 1000
    model = RecipeAutoencoder(vocab_size=vocab)
    x = torch.randint(0, vocab, (2, 8)) # Batch 2, 8 ingredients
    logits, _ = model(x)
    print("Logits shape:", logits.shape)
