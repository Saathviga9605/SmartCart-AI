import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/grocery_item_model.dart';
import '../../data/models/category_model.dart';
import '../providers/grocery_provider.dart';
import 'package:provider/provider.dart';
import 'animated_checkbox.dart';

/// Animated grocery item card with swipe and long-press gestures
/// Provides rich interactions for item management
class AnimatedGroceryItem extends StatefulWidget {
  final GroceryItemModel item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const AnimatedGroceryItem({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<AnimatedGroceryItem> createState() => _AnimatedGroceryItemState();
}

class _AnimatedGroceryItemState extends State<AnimatedGroceryItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleLongPress() {
    HapticFeedback.mediumImpact();
    _showOptionsBottomSheet();
  }

  void _showOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundMedium,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.accentMain),
              title: Text(
                'Edit Item',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                widget.onEdit();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: Text(
                'Delete Item',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                widget.onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete,
          color: AppColors.error,
        ),
      ),
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        widget.onDelete();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTapDown: (_) {
            _controller.forward();
          },
          onTapUp: (_) {
            _controller.reverse();
          },
          onTapCancel: () {
            _controller.reverse();
          },
          onLongPress: _handleLongPress,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.item.isDone
                  ? AppColors.surfaceDark.withValues(alpha: 0.5)
                  : AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.glassBorder.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Checkbox
                AnimatedCheckbox(
                  value: widget.item.isDone,
                  onChanged: (_) => widget.onToggle(),
                  activeColor: widget.item.category.color,
                ),
                const SizedBox(width: 12),
                
                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.name,
                        style: AppTextStyles.itemName.copyWith(
                          color: widget.item.isDone
                              ? AppColors.textTertiary
                              : AppColors.textPrimary,
                          decoration: widget.item.isDone
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (widget.item.notes != null &&
                          widget.item.notes!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.item.notes!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Quantity Controls
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        if (widget.item.quantity > 1) {
                          context.read<GroceryProvider>().updateItemQuantity(
                                widget.item.id,
                                widget.item.quantity - 1,
                              );
                        }
                      },
                      icon: Icon(
                        Icons.remove_circle_outline,
                        size: 20,
                        color: widget.item.isDone
                            ? AppColors.textDisabled
                            : AppColors.textSecondary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.item.category.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${widget.item.quantity}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: widget.item.category.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        context.read<GroceryProvider>().updateItemQuantity(
                              widget.item.id,
                              widget.item.quantity + 1,
                            );
                      },
                      icon: Icon(
                        Icons.add_circle_outline,
                        size: 20,
                        color: widget.item.isDone
                            ? AppColors.textDisabled
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
