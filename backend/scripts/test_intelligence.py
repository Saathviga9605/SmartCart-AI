
import sys
import os

# Add paths for robust importing
current_dir = os.path.dirname(os.path.abspath(__file__)) # backend/scripts
backend_dir = os.path.dirname(current_dir) # backend
root_dir = os.path.dirname(backend_dir) # SmartCart-AI-main

sys.path.append(backend_dir)
sys.path.append(root_dir)

from services.recipe_intelligence import RecipeIntelligence

def test_models():
    print("Initializing RecipeIntelligence (loading models)...")
    ri = RecipeIntelligence()
    
    print("\n[TEST 1] Set Transformer / Embedding Check")
    if ri._set_transformer:
        print("[OK] Set Transformer Loaded")
        print(f"   Model: {ri._set_transformer}")
    else:
        print("[FAIL] Set Transformer NOT Loaded (or file missing)")

    print("\n[TEST 2] LightGBM Ranker Check")
    if ri._ranker:
        print("[OK] LightGBM Ranker Loaded")
        print(f"   Model: {ri._ranker}")
    else:
        print("[WARN] LightGBM Ranker NOT Loaded (currently disabled in code or missing file)")

    print("\n[TEST 3] Recommendation Logic")
    user_ingredients = ["milk", "eggs", "flour"]
    print(f"   Input: {user_ingredients}")
    results = ri.get_top_recipes(user_ingredients)
    print(f"   Output ({len(results)} recipes):")
    for r in results:
        print(f"     - {r['name']} (Score: {r['score']:.4f}, Match: {r['match']})")

    if len(results) > 0:
        print("\n[OK] Intelligence Pipeline is FUNCTIONAL (producing scores).")
    else:
        print("\n[FAIL] Intelligence Pipeline produced NO results.")

    print("\n[TEST 4] Item Associations (Smart Suggestions)")
    test_item = "salt"
    print(f"   Input Item: {test_item}")
    # Using internal helper for direct verification or via recommend_more
    suggestions = ri.recommend_more([test_item], missing=[])
    print(f"   Output Suggestions: {suggestions['extra_suggestions']}")
    if "pepper" in suggestions['extra_suggestions']:
        print("[OK] Association Logic works (Salt -> Pepper)")
    else:
        print("[FAIL] Association Logic did not suggest expected items")

if __name__ == "__main__":
    test_models()
