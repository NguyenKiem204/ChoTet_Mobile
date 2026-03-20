import 'package:flutter/material.dart';
import '../../../domain/entities/shopping_item.dart';
import '../../../themes/design_system.dart';
import '../../../utils/currency_formatter.dart';

class ShoppingItemTile extends StatelessWidget {
  final ShoppingItem item;
  final String? listName;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const ShoppingItemTile({
    super.key,
    required this.item,
    this.listName,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Row(
                children: [
                  // Item Image
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.tetRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: item.imageUrl != null
                          ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                          : const Icon(Icons.shopping_basket, color: AppColors.tetRed, size: 30),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  // Item Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: item.isPurchased ? const Color(0xFFAFA8A0) : AppColors.charcoal,
                          ),
                        ),
                        Text(
                          'Số lượng: ${item.quantity} ${item.unit}',
                          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.midGrey),
                        ),
                        if (item.isPurchased && item.purchasedBy != null)
                          Text(
                            'Đã mua bởi: ${item.purchasedBy!.displayName}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: item.isPurchased ? const Color(0xFFAFA8A0) : AppColors.success,
                              fontStyle: FontStyle.italic,
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Price and Action
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.format(item.isPurchased ? (item.actualPrice ?? item.estimatedPrice) : item.estimatedPrice),
                        style: TextStyle(
                          color: item.isPurchased ? const Color(0xFFAFA8A0) : AppColors.tetRed,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          // Prevent triggering the card's onTap
                          onToggle();
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: item.isPurchased ? AppColors.tetRed : AppColors.lightGrey,
                              width: 2,
                            ),
                            color: item.isPurchased ? AppColors.tetRed : Colors.transparent,
                          ),
                          child: item.isPurchased
                              ? const Icon(Icons.check, color: Colors.white, size: 18)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
