import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/datasources/hive_service.dart';
import 'package:intl/intl.dart';
import '../providers/grocery_provider.dart';
import '../../data/models/category_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload history whenever screen becomes visible
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (!mounted) return;
    
    try {
      setState(() => _isLoading = true);
      final hive = context.read<HiveService>();
      final history = hive.getHistory();
      
      if (mounted) {
        setState(() {
          _history = history.reversed.toList(); // Newest first
          _isLoading = false;
        });
        debugPrint('History loaded: ${_history.length} records');
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
      if (mounted) {
        setState(() {
          _history = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping History'),
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _confirmClearHistory,
              tooltip: 'Clear all history',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _history.isEmpty
                ? _buildEmptyState()
                : _buildHistoryList(),
      ),
    );
  }

  Future<void> _confirmClearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear all shopping history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final hive = context.read<HiveService>();
      await hive.clearHistory();
      _loadHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('History cleared')),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'No history yet',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Your completed lists will appear here',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final record = _history[index];
        final DateTime date = DateTime.parse(record['timestamp']);
        final List items = record['items'] ?? [];
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder.withOpacity(0.1)),
          ),
          child: ExpansionTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryMain.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_bag, color: AppColors.primaryMain, size: 20),
            ),
            title: Text(
              DateFormat('MMM d, yyyy • h:mm a').format(date),
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${items.length} items purchased',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
            ),
            childrenPadding: const EdgeInsets.all(16),
            children: [
              ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${item['quantity']}x ${item['name']}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              )).toList(),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () async {
                  final grocery = context.read<GroceryProvider>();
                  int count = 0;
                  for (final itemData in items) {
                    try {
                      await grocery.addItem(
                        name: itemData['name'],
                        category: GroceryCategory.values.firstWhere(
                          (c) => c.name == itemData['category'],
                          orElse: () => GroceryCategory.other,
                        ),
                        quantity: itemData['quantity'] ?? 1,
                        notes: itemData['notes'],
                      );
                      count++;
                    } catch (e) {
                      debugPrint('Error re-adding item: $e');
                    }
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Re-added $count items to your list')),
                    );
                  }
                },
                icon: const Icon(Icons.add_shopping_cart, size: 18),
                label: const Text('Re-add to list'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primaryMain),
              ),
            ],
          ),
        );
      },
    );
  }
}
