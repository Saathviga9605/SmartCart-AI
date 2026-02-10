from flask import Blueprint, request, jsonify
from services.voice_pipeline import VoicePipeline
from services.category_classifier import CategoryClassifier
from services.recipe_intelligence import RecipeIntelligence

ingredients_bp = Blueprint('ingredients', __name__)

# Initialize services (Lazy load to speed up start if models not present)
# In production, these should be initialized globally or via a factory
classifier = CategoryClassifier()
voice_pipeline = VoicePipeline(classifier)
recipe_service = RecipeIntelligence()

@ingredients_bp.route('/extract', methods=['POST'])
def extract_ingredients():
    """
    Extract ingredients from text using NLP pipeline.
    Request Body:
        {
            "text": "I need milk, eggs, and bread"
        }
    """
    try:
        data = request.json
        text = data.get('text', '')
        
        if not text:
            return jsonify({'error': 'No text provided'}), 400
            
        # We re-use logic from VoicePipeline but bypass audio transcription if text is provided directly
        # VoicePipeline.process_audio_file takes a path, so we use internal methods here
        
        normalized = voice_pipeline._normalize_text(text)
        ingredients = voice_pipeline._extract_ingredients(normalized)
        categories = classifier.predict_map(ingredients)
        
        return jsonify({
            "original_text": text,
            "normalized_text": normalized,
            "ingredients": ingredients,
            "categories": categories
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@ingredients_bp.route('/search', methods=['GET'])
def search_ingredients():
    """
    Search for ingredients/products in the catalog.
    Query Parameters:
        q: Search query string
    """
    try:
        query = request.args.get('q', '').lower()
        if not query:
            return jsonify({'results': []})

        # Get unique ingredients from both recipes and the expanded dataset
        all_ings = set()
        for recipe in recipe_service._recipes:
            for ing in recipe.ingredients:
                all_ings.add(ing.lower())
        
        # Add items from the larger grocery dataset
        all_ings.update([item.lower() for item in classifier.get_known_items()])
        
        # Filter matches
        matches = [ing for ing in all_ings if query in ing]
        
        # Sort by relevance (startsWith first)
        matches.sort(key=lambda x: (not x.startswith(query), x))
        
        results = []
        for match in matches[:20]: # Limit to top 20
            prediction = classifier.predict(match)
            results.append({
                'name': match.title(),
                'category': prediction.category,
                'confidence': prediction.confidence
            })
            
        return jsonify({'results': results})
    except Exception as e:
        return jsonify({'error': str(e)}), 500
