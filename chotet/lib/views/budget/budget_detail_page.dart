import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../themes/design_system.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../widgets/atoms/tet_card.dart';
import '../widgets/atoms/tet_progress_bar.dart';
import '../widgets/atoms/tet_button.dart';
import '../summary/trip_summary_page.dart';
import '../history/shopping_history_page.dart';
import '../../utils/currency_formatter.dart';

class BudgetDetailPage extends StatelessWidget {
  const BudgetDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ngân sách chi tiết'),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          final stats = viewModel.categoryStats;
          final isUnderBudget = viewModel.totalRemaining >= 0;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.m),
            children: [
              // Main Budget Card
              TetCard(
                color: AppColors.tetRed,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Số dư còn lại', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(AppRadius.m),
                          ),
                          child: Text(
                            DateFormat('MMMM, y').format(DateTime.now()), 
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: CurrencyFormatter.format(viewModel.totalRemaining),
                            style: theme.textTheme.displayLarge?.copyWith(color: Colors.white, fontSize: 32),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildBudgetStat(context, 'TỔNG NGÂN SÁCH', CurrencyFormatter.format(viewModel.totalBudget)),
                        _buildBudgetStat(context, 'THỰC CHI', CurrencyFormatter.format(viewModel.totalActual)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.m),

              // Status Alert
              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: (isUnderBudget ? Colors.green : Colors.red).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.l),
                  border: Border.all(color: (isUnderBudget ? Colors.green : Colors.red).withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isUnderBudget ? Icons.trending_down : Icons.trending_up, 
                        color: isUnderBudget ? Colors.green : Colors.red, 
                        size: 20
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isUnderBudget 
                                ? 'Bạn đang chi tiêu dưới mức ngân sách ${CurrencyFormatter.format(viewModel.totalRemaining)}'
                                : 'Bạn đã chi quá ngân sách ${CurrencyFormatter.format(viewModel.totalRemaining.abs())}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold, 
                              color: isUnderBudget ? Colors.green.shade800 : Colors.red.shade800
                            ),
                          ),
                          Text(
                            isUnderBudget 
                                ? 'Tốt lắm! Chi tiêu của bạn đang được kiểm soát hiệu quả.'
                                : 'Hãy cân nhắc cắt giảm chi tiêu ở một số hạng mục.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isUnderBudget ? Colors.green.shade700 : Colors.red.shade700
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.l),

              Text('Phân bổ theo hạng mục', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.m),

              if (stats.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text('Chưa có dữ liệu chi tiêu.', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.midGrey)),
                  ),
                )
              else
                ...stats.entries.map((entry) {
                  final category = entry.key;
                  final categoryData = entry.value;
                  final progress = categoryData.estimated == 0 ? 0.0 : categoryData.actual / categoryData.estimated;
                  
                  return _buildCategoryProgress(
                    context, 
                    category, 
                    progress.clamp(0.0, 1.0), 
                    '${CurrencyFormatter.format(categoryData.actual)} / ${CurrencyFormatter.format(categoryData.estimated)}', 
                    _getIconForCategory(category)
                  );
                }),
              
              const SizedBox(height: AppSpacing.m),
              TetButton(
                label: 'Xem lịch sử mua sắm',
                variant: TetButtonVariant.outline,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ShoppingHistoryPage()),
                  );
                },
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              ElevatedButton.icon(
                onPressed: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TripSummaryPage()),
                  );
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Hoàn thành & Xem tổng kết'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tetRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBudgetStat(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white60, letterSpacing: 1.1)),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
      ],
    );
  }

  Widget _buildCategoryProgress(BuildContext context, String title, double progress, String subtitle, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: TetCard(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.orange, size: 24),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium?.copyWith(fontSize: 16)),
                      Text('Đã chi $subtitle', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Text('${(progress * 100).toInt()}%', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            TetProgressBar(progress: progress),
          ],
        ),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    final catLower = category.toLowerCase();
    if (catLower.contains('thịt') || catLower.contains('seafood') || catLower.contains('hải sản')) return Icons.set_meal;
    if (catLower.contains('rau') || catLower.contains('vegetable') || catLower.contains('quả') || catLower.contains('trái cây')) return Icons.eco;
    if (catLower.contains('trang trí') || catLower.contains('hoa')) return Icons.celebration;
    if (catLower.contains('đồ khô') || catLower.contains('grocery')) return Icons.inventory_2;
    if (catLower.contains('bánh') || catLower.contains('kẹo') || catLower.contains('đồ ăn vặt')) return Icons.cake;
    if (catLower.contains('uống') || catLower.contains('rượu') || catLower.contains('bia') || catLower.contains('drink')) return Icons.local_bar;
    return Icons.shopping_basket;
  }
}
