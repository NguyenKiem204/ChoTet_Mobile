import 'package:flutter/material.dart';
import '../../../domain/entities/shopping_list.dart';
import '../../../themes/design_system.dart';
import '../atoms/tet_progress_bar.dart';
import '../../../utils/currency_formatter.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeListItem extends StatelessWidget {
  final ShoppingList list;
  final VoidCallback onTap;

  const HomeListItem({
    super.key,
    required this.list,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.tetRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      list.imageUrl ?? 'https://picsum.photos/seed/tet_market/200/200',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_basket, color: AppColors.tetRed),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        list.name,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoal,
                        ),
                      ),
                      if (list.totalActual > list.budget)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'VƯỢT NGÂN SÁCH',
                                style: GoogleFonts.outfit(
                                  color: AppColors.danger,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: AppSpacing.m),
                      Text(
                        'Đã chi tiêu',
                        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.midGrey),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormatter.format(list.totalActual),
                            style: GoogleFonts.outfit(
                              color: AppColors.tetRed,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            '${(list.progress * 100).toInt()}%',
                            style: GoogleFonts.outfit(
                              color: AppColors.midGrey,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TetProgressBar(
                        progress: list.progress,
                        isOverBudget: list.isOverBudget,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hạn mức ngân sách: ${CurrencyFormatter.format(list.budget)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: AppColors.midGrey.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
