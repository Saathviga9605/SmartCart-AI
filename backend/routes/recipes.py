from flask import Blueprint, request, jsonify
from services.recipe_intelligence import RecipeIntelligence

recipes_bp = Blueprint('recipes', __name__)
recipe_service = RecipeIntelligence()

@recipes_bp.route('/recommend', methods=['POST'])
def recommend_recipes():
    """
    Get recipe recommendations based on ingredients.
    Request Body:
        {
            "ingredients": ["milk", "eggs", "flour"],
            "limit": 5
        }
    """
    try:
        data = request.json
        ingredients = data.get('ingredients', [])
        limit = data.get('limit', 5)
        
        # If no ingredients, provide popular recipes as fallback
        if not ingredients:
            recommendations = recipe_service.get_top_recipes(['milk', 'eggs'], k=limit)
        else:
            recommendations = recipe_service.get_top_recipes(ingredients, k=limit)
            
        # Analyze missing ingredients for the top match to provide "Smart Suggestions"
        extras = {}
        if recommendations:
            top_rec = recommendations[0]
            missing = top_rec.get('missing', [])
            extras = recipe_service.recommend_more(ingredients, missing)
            
        # Unified response for both ApiService and SmartPantryApi
        return jsonify({
            'recommendations': recommendations,
            'top_5': recommendations,  # Alias for SmartPantryApi
            'smart_suggestions': extras,
            'substitutes': extras.get('substitutes', {}), # Alias for SmartPantryApi
            'extra_suggestions': extras.get('extra_suggestions', []) # Alias for SmartPantryApi
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500
