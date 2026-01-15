"""
SmartCart AI - User Patterns Data Model

Tracks user shopping behavior for personalized recommendations
"""

from datetime import datetime

class UserPattern:
    """
    Model for storing user shopping patterns
    
    In production, this would be a SQLAlchemy or similar ORM model
    """
    
    def __init__(self, user_id, item_name, category, purchase_count=1):
        self.user_id = user_id
        self.item_name = item_name
        self.category = category
        self.purchase_count = purchase_count
        self.last_purchased = datetime.now()
        self.created_at = datetime.now()
    
    def increment_purchase(self):
        """Increment purchase count and update timestamp"""
        self.purchase_count += 1
        self.last_purchased = datetime.now()
    
    def to_dict(self):
        """Convert to dictionary for JSON serialization"""
        return {
            'user_id': self.user_id,
            'item_name': self.item_name,
            'category': self.category,
            'purchase_count': self.purchase_count,
            'last_purchased': self.last_purchased.isoformat(),
            'created_at': self.created_at.isoformat()
        }
    
    @staticmethod
    def from_dict(data):
        """Create instance from dictionary"""
        pattern = UserPattern(
            user_id=data['user_id'],
            item_name=data['item_name'],
            category=data['category'],
            purchase_count=data.get('purchase_count', 1)
        )
        return pattern


class ShoppingList:
    """
    Model for storing shopping lists
    """
    
    def __init__(self, user_id, list_id, items=None):
        self.user_id = user_id
        self.list_id = list_id
        self.items = items or []
        self.created_at = datetime.now()
        self.completed_at = None
        self.is_completed = False
    
    def add_item(self, item):
        """Add item to shopping list"""
        self.items.append(item)
    
    def complete_list(self):
        """Mark list as completed"""
        self.is_completed = True
        self.completed_at = datetime.now()
    
    def to_dict(self):
        """Convert to dictionary"""
        return {
            'user_id': self.user_id,
            'list_id': self.list_id,
            'items': self.items,
            'created_at': self.created_at.isoformat(),
            'completed_at': self.completed_at.isoformat() if self.completed_at else None,
            'is_completed': self.is_completed
        }
