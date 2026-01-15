import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/grocery_item_model.dart';
import '../../data/models/category_model.dart';
import '../providers/grocery_provider.dart';
import '../providers/ml_inference_provider.dart';

/// Add/Edit Item Screen - Manual item entry with smart suggestions
/// Provides fallback for voice input with category selection
class AddEditItemScreen extends StatefulWidget {
  final GroceryItemModel? item;

  const AddEditItemScreen({super.key, this.item});

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  
  GroceryCategory _selectedCategory = GroceryCategory.other;
  int _quantity = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _notesController.text = widget.item!.notes ?? '';
      _selectedCategory = widget.item!.category;
      _quantity = widget.item!.quantity;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _predictCategory() async {
    if (_nameController.text.isEmpty) return;

    setState(() => _isLoading = true);

    final mlProvider = context.read<MLInferenceProvider>();
    final category = await mlProvider.predictCategory(_nameController.text);

    setState(() {
      _selectedCategory = category;
      _isLoading = false;
    });
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    final groceryProvider = context.read<GroceryProvider>();

    if (widget.item == null) {
      // Add new item
      await groceryProvider.addItem(
        name: _nameController.text.trim(),
        category: _selectedCategory,
        quantity: _quantity,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
    } else {
      // Update existing item
      final updatedItem = widget.item!.copyWith(
        name: _nameController.text.trim(),
        category: _selectedCategory,
        quantity: _quantity,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      await groceryProvider.updateItem(updatedItem);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.item == null ? 'Add Item' : 'Edit Item',
          style: AppTextStyles.titleLarge,
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          children: [
            // Item Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Item Name',
                hintText: 'e.g., Milk, Bread, Apples',
                prefixIcon: const Icon(Icons.shopping_basket),
                suffixIcon: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
              style: AppTextStyles.bodyLarge,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an item name';
                }
                return null;
              },
              onChanged: (value) {
                // Auto-predict category after typing
                if (value.length > 2) {
                  _predictCategory();
                }
              },
            ),
            
            const SizedBox(height: 24),
            
            // Category Selection
            Text(
              'Category',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: GroceryCategory.values.map((category) {
                final isSelected = _selectedCategory == category;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category.icon,
                        size: 18,
                        color: isSelected ? Colors.white : category.color,
                      ),
                      const SizedBox(width: 6),
                      Text(category.displayName),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  selectedColor: category.color,
                  backgroundColor: category.color.withValues(alpha: 0.1),
                  labelStyle: AppTextStyles.chipText.copyWith(
                    color: isSelected ? Colors.white : category.color,
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Quantity
            Text(
              'Quantity',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                IconButton(
                  onPressed: _quantity > 1
                      ? () => setState(() => _quantity--)
                      : null,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _quantity > 1
                          ? AppColors.primaryMain.withValues(alpha: 0.2)
                          : AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.remove,
                      color: _quantity > 1
                          ? AppColors.primaryMain
                          : AppColors.textDisabled,
                    ),
                  ),
                ),
                
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: Text(
                      _quantity.toString(),
                      style: AppTextStyles.displaySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                
                IconButton(
                  onPressed: () => setState(() => _quantity++),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMain.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: AppColors.primaryMain,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'e.g., Organic, 2% fat',
                prefixIcon: Icon(Icons.note),
              ),
              style: AppTextStyles.bodyLarge,
              maxLines: 3,
            ),
            
            const SizedBox(height: 32),
            
            // Save Button
            ElevatedButton(
              onPressed: _saveItem,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: Text(
                widget.item == null ? 'Add Item' : 'Save Changes',
                style: AppTextStyles.buttonText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
