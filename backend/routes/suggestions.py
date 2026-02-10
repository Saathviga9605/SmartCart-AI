"""
SmartCart AI - Suggestions API Routes

Provides smart grocery suggestions based on:
- User purchase history
- Collaborative filtering
- Seasonal trends
- Item associations
"""

from flask import Blueprint, jsonify, request
from services.recipe_intelligence import RecipeIntelligence
from services.category_classifier import CategoryClassifier

suggestions_bp = Blueprint('suggestions', __name__)
recipe_service = RecipeIntelligence()
category_service = CategoryClassifier()

@suggestions_bp.route('/', methods=['GET'])
def get_suggestions():
    """
    Get smart suggestions for the user
    
    Query Parameters:
        user_id: User identifier
        current_items: Comma-separated list of current items
    
    Returns:
        List of suggested items with confidence scores
    """
    user_id = request.args.get('user_id')
    current_items_str = request.args.get('current_items', '')
    current_items = [i.strip() for i in current_items_str.split(',') if i.strip()]
    
    # 1. Get smart suggestions from RecipeIntelligence (Association Rules + Autoencoder)
    intelligence_results = recipe_service.recommend_more(current_items, missing=[])
    raw_suggestions = intelligence_results.get('extra_suggestions', [])
    
    suggestions = []
    for item in raw_suggestions:
        # 2. Automatically classify each suggestion
        prediction = category_service.predict(item)
        suggestions.append({
            'item_name': item.title(),
            'category': prediction.category,
            'confidence': prediction.confidence,
            'reason': 'Frequently bought together',
            'related_items': current_items[:2] # Showing some context
        })
    
    # Fallback to defaults if no suggestions found
    if not suggestions and not current_items:
        defaults = ['Milk', 'Bread', 'Eggs']
        for item in defaults:
            prediction = category_service.predict(item)
            suggestions.append({
                'item_name': item,
                'category': prediction.category,
                'confidence': 1.0,
                'reason': 'Popular item',
                'related_items': []
            })

    return jsonify({
        'suggestions': suggestions,
        'count': len(suggestions)
    })

@suggestions_bp.route('/collaborative', methods=['POST'])
def collaborative_filtering():
    """
    Get suggestions using collaborative filtering
    
    Analyzes patterns from similar users to suggest items
    
    Request Body:
        {
            "user_id": "string",
            "purchase_history": ["item1", "item2", ...]
        }
    """
    data = request.json
    
    # In production:
    # 1. Find similar users based on purchase history
    # 2. Identify items they bought that current user hasn't
    # 3. Rank by relevance and confidence
    
    return jsonify({
        'suggestions': [
            {
                'item_name': 'Avocado',
                'category': 'fruits',
                'confidence': 0.82,
                'reason': 'Users with similar tastes also buy this'
            }
        ]
    })

@suggestions_bp.route('/seasonal', methods=['GET'])
def seasonal_suggestions():
    """
    Get seasonal item suggestions
    
    Suggests items based on current season and trends
    """
    # Placeholder seasonal suggestions
    import datetime
    month = datetime.datetime.now().month
    
    if month in [12, 1, 2]:  # Winter
        suggestions = ['Hot Chocolate', 'Soup', 'Root Vegetables']
    elif month in [3, 4, 5]:  # Spring
        suggestions = ['Strawberries', 'Asparagus', 'Fresh Herbs']
    elif month in [6, 7, 8]:  # Summer
        suggestions = ['Watermelon', 'Ice Cream', 'Berries']
    else:  # Fall
        suggestions = ['Pumpkin', 'Apples', 'Squash']
    
    return jsonify({
        'season': 'current',
        'suggestions': suggestions
    })
