import 'package:flutter/material.dart';
import '../../../themes/design_system.dart';
import '../widgets/atoms/tet_card.dart';
import '../widgets/atoms/tet_progress_bar.dart';
import '../../utils/currency_formatter.dart';

class ShoppingHistoryPage extends StatelessWidget {
  const ShoppingHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lịch sử mua sắm'),
          bottom: const TabBar(
            indicatorColor: AppColors.tetRed,
            labelColor: AppColors.tetRed,
            unselectedLabelColor: AppColors.midGrey,
            tabs: [
              Tab(text: 'Tất cả'),
              Tab(text: 'Đã xong'),
              Tab(text: 'Kế hoạch'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Tìm kiếm lịch sử...',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.l),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                children: [
                  _buildSectionHeader(context, 'Tháng 1, 2025'),
                  _buildHistoryCard(
                    context,
                    title: 'Đồ Tết đầy đủ',
                    date: '25 Tháng 1, 2025',
                    spent: CurrencyFormatter.format(1820000),
                    budget: CurrencyFormatter.format(2000000),
                    progress: 0.91,
                    status: 'TRONG NGÂN SÁCH',
                    isOverBudget: false,
                  ),
                  _buildHistoryCard(
                    context,
                    title: 'Giỏ quà biếu',
                    date: '10 Tháng 1, 2025',
                    spent: CurrencyFormatter.format(480000),
                    budget: CurrencyFormatter.format(500000),
                    progress: 0.96,
                    status: 'TRONG NGÂN SÁCH',
                    isOverBudget: false,
                  ),
                  _buildHistoryCard(
                    context,
                    title: 'Trang trí & Hoa',
                    date: '05 Tháng 1, 2025',
                    spent: CurrencyFormatter.format(1250000),
                    budget: CurrencyFormatter.format(1000000),
                    progress: 1.0,
                    status: 'VƯỢT NGÂN SÁCH',
                    isOverBudget: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context, {
    required String title,
    required String date,
    required String spent,
    required String budget,
    required double progress,
    required String status,
    required bool isOverBudget,
  }) {
    final theme = Theme.of(context);
    final statusColor = isOverBudget ? AppColors.danger : Colors.green;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: TetCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    Text(date, style: theme.textTheme.bodySmall),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.m),
                  ),
                  child: Text(
                    status,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodySmall,
                    children: [
                      const TextSpan(text: 'Đã chi: '),
                      TextSpan(
                        text: spent,
                        style: TextStyle(color: isOverBudget ? AppColors.tetRed : Colors.green.shade700, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Text('Hạn mức: $budget', style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            TetProgressBar(progress: progress, isOverBudget: isOverBudget),
            const SizedBox(height: AppSpacing.m),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.receipt_long, size: 18),
                    label: const Text('Xem chi tiết'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.darkSurface,
                      side: BorderSide(color: Colors.grey.shade200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.tetRed.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppRadius.m),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.share_outlined, color: AppColors.tetRed),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
