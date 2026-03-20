import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../themes/design_system.dart';
import '../widgets/atoms/tet_card.dart';
import '../../utils/currency_formatter.dart';
import '../../viewmodels/home_viewmodel.dart';

class TripSummaryPage extends StatelessWidget {
  const TripSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeViewModel = Provider.of<HomeViewModel>(context);
    
    final totalActual = homeViewModel.totalActual;
    final totalBudget = homeViewModel.totalBudget;
    final saving = totalBudget - totalActual;
    final savingPercent = totalBudget > 0 ? ((saving / totalBudget) * 100).round() : 0;
    
    int purchasedCount = 0;
    int totalCount = 0;
    for (var list in homeViewModel.lists) {
      totalCount += list.items.length;
      purchasedCount += list.items.where((i) => i.isPurchased).length;
    }
    final completionRate = totalCount > 0 ? (purchasedCount / totalCount) : 0.0;
    final skippedCount = totalCount - purchasedCount;

    return Scaffold(
       appBar: AppBar(
        title: const Text('Tổng kết chuyến đi'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.m),
        children: [
          const SizedBox(height: AppSpacing.l),
          const Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.tetRed,
              child: Icon(Icons.celebration, color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Center(child: Text('Mua sắm hoàn tất! 🥳', style: theme.textTheme.headlineMedium)),
          Center(
            child: Text(
              'Bạn đã hoàn thành danh sách sắm Tết!',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.tetRed),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          TetCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tổng chi tiêu', style: theme.textTheme.bodySmall),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: (savingPercent >= 0 ? Colors.green : Colors.red).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${savingPercent >= 0 ? "↓" : "↑"} ${savingPercent.abs()}%',
                        style: TextStyle(
                          color: savingPercent >= 0 ? Colors.green : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(CurrencyFormatter.format(totalActual), style: theme.textTheme.displayLarge?.copyWith(fontSize: 32)),
                ),
                const SizedBox(height: AppSpacing.m),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text('Ngân sách', style: theme.textTheme.bodySmall),
                           Text(CurrencyFormatter.format(totalBudget), style: theme.textTheme.titleMedium),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(saving >= 0 ? 'Tiết kiệm được' : 'Vượt ngân sách', style: theme.textTheme.bodySmall),
                           Text(
                             CurrencyFormatter.format(saving.abs()),
                             style: theme.textTheme.titleMedium?.copyWith(
                               color: saving >= 0 ? Colors.green : Colors.red,
                             ),
                           ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.l),

          Text('Chi tiết', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.m),

          _buildDetailRow(context, 'Đã mua', '$purchasedCount món', 'Hoàn thành', Colors.green, purchasedCount, totalCount),
          _buildDetailRow(context, 'Đồ còn lại', '$skippedCount món', 'Chưa mua', Colors.orange, skippedCount, totalCount),

          const SizedBox(height: AppSpacing.l),
          if (homeViewModel.memberStats.isNotEmpty) ...[
            Text('Đóng góp của thành viên', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.m),
            ...homeViewModel.memberStats.values.map((stat) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: TetCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.tetRed.withValues(alpha: 0.1),
                      child: Text(stat.name.substring(0, 1).toUpperCase(), style: const TextStyle(color: AppColors.tetRed)),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(stat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Đã mua ${stat.itemsCount} món', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(stat.totalSpent),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success),
                    ),
                  ],
                ),
              ),
            )),
            const SizedBox(height: AppSpacing.l),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tỷ lệ hoàn thành', style: theme.textTheme.titleSmall),
              Text('${(completionRate * 100).round()}%', style: theme.textTheme.titleSmall?.copyWith(color: AppColors.tetRed, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: completionRate,
              minHeight: 12,
              backgroundColor: Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.tetRed),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Xuất PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkSurface,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share),
                  label: const Text('Chia sẻ'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          ElevatedButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tetRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Về Trang chủ', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String title, String count, String status, Color color, int value, int total) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: TetCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(title == 'Đã mua' ? Icons.shopping_cart : Icons.assignment_late, color: color, size: 20),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(count, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(status, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('trên $total', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
