import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../themes/design_system.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../widgets/atoms/tet_card.dart';
import '../../utils/currency_formatter.dart';
import '../history/shopping_history_page.dart';

class BudgetDetailPage extends StatelessWidget {
  const BudgetDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          final stats = viewModel.categoryStats;
          final availableYears = viewModel.availableYears;
          final isUnderBudget = viewModel.totalRemaining >= 0;

          return CustomScrollView(
            slivers: [
              // Year Selector
              SliverToBoxAdapter(
                child: Container(
                  height: 60,
                  color: Colors.white,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: 10),
                    itemCount: availableYears.length,
                    itemBuilder: (context, index) {
                      final year = availableYears[index];
                      final isSelected = year == viewModel.selectedYear;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.s),
                        child: ChoiceChip(
                          label: Text('Năm $year', style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.charcoal,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          )),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) viewModel.selectedYear = year;
                          },
                          selectedColor: AppColors.tetRed,
                          backgroundColor: AppColors.lightGrey.withValues(alpha: 0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: isSelected ? AppColors.tetRed : Colors.transparent),
                          ),
                          showCheckmark: false,
                        ),
                      );
                    },
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.m),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Main Summary Card
                    _buildOverviewCard(context, viewModel),
                    const SizedBox(height: AppSpacing.m),

                    // Over Budget Alert
                    if (!isUnderBudget)
                      _buildAlert(
                        context, 
                        'Vượt ngân sách ${CurrencyFormatter.format(viewModel.totalRemaining.abs())}', 
                        'Hãy cân nhắc tối ưu hóa các chi phí không cần thiết.',
                        Icons.warning_amber_rounded,
                        AppColors.danger,
                      ),
                    
                    const SizedBox(height: AppSpacing.l),
                    
                    // Charts Section
                    _buildSectionHeader('Phân bổ chi tiêu'),
                    const SizedBox(height: AppSpacing.m),
                    _buildChartsSection(context, stats),
                    
                    const SizedBox(height: AppSpacing.l),
                    
                    const SizedBox(height: AppSpacing.l),
                    
                    
                    // Contributors (Member Stats)
                    if (viewModel.memberStats.isNotEmpty) ...[
                      _buildSectionHeader('Thành viên đóng góp'),
                      const SizedBox(height: AppSpacing.m),
                      _buildMemberStats(context, viewModel.memberStats),
                      const SizedBox(height: AppSpacing.l),
                    ],

                    // History Link
                    _buildHistoryButton(context),
                    const SizedBox(height: AppSpacing.xl),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, HomeViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.tetRed, Color(0xFFD32F2F)],
        ),
        image: const DecorationImage(
          image: AssetImage('assets/images/bg_auth_header.png'),
          fit: BoxFit.cover,
          opacity: 0.2,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.tetRed.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TỔNG CHI TIÊU ${viewModel.selectedYear}',
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(viewModel.totalActual),
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildCompactStat('Ngân sách', CurrencyFormatter.format(viewModel.totalBudget)),
              const Spacer(),
              _buildCompactStat(
                viewModel.totalRemaining >= 0 ? 'Còn lại' : 'Vượt mức',
                CurrencyFormatter.format(viewModel.totalRemaining.abs()),
                isPositive: viewModel.totalRemaining >= 0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat(String label, String value, {bool? isPositive}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11),
        ),
        Text(
          value,
          style: TextStyle(
            color: isPositive == null 
                ? Colors.white 
                : (isPositive ? AppColors.vibrantGold : Colors.orangeAccent),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildAlert(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                Text(subtitle, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.charcoal,
      ),
    );
  }

  Widget _buildChartsSection(BuildContext context, Map<String, ({double estimated, double actual})> stats) {
    if (stats.isEmpty) return const SizedBox.shrink();

    final data = stats.entries.toList()
      ..sort((a, b) => b.value.actual.compareTo(a.value.actual));
    
    final topCategories = data.take(4).toList();
    final colors = [AppColors.tetRed, AppColors.vibrantGold, AppColors.charcoal, AppColors.midGrey];

    return TetCard(
      child: Row(
        children: [
          SizedBox(
            height: 140,
            width: 140,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: topCategories.asMap().entries.map((e) {
                  return PieChartSectionData(
                    color: colors[e.key % colors.length],
                    value: e.value.value.actual,
                    title: '',
                    radius: 15,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              children: topCategories.asMap().entries.map((e) {
                return _buildChartLegend(e.value.key, e.value.value.actual, colors[e.key % colors.length]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
          ),
          Text(
            CurrencyFormatter.format(value),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(BuildContext context, String category, ({double estimated, double actual}) data) {
    final progress = data.estimated > 0 ? (data.actual / data.estimated) : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(category, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(
                  CurrencyFormatter.format(data.actual),
                  style: const TextStyle(color: AppColors.tetRed, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: AppColors.lightGrey.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress > 1.0 ? AppColors.danger : AppColors.tetRed,
                ),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Hạn mức: ${CurrencyFormatter.format(data.estimated)}', style: const TextStyle(fontSize: 10, color: AppColors.midGrey)),
                Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberStats(BuildContext context, Map<int, ({String name, int itemsCount, double totalSpent})> stats) {
    return Column(
      children: stats.values.map((stat) => Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.tetRed.withValues(alpha: 0.1),
              radius: 16,
              child: Text(stat.name.substring(0, 1).toUpperCase(), style: const TextStyle(color: AppColors.tetRed, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(stat.name, style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(CurrencyFormatter.format(stat.totalSpent), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text('${stat.itemsCount} món', style: const TextStyle(fontSize: 10, color: AppColors.midGrey)),
              ],
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildHistoryButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShoppingHistoryPage())),
        icon: const Icon(Icons.history, color: AppColors.tetRed),
        label: const Text('Xem lịch sử chi tiết', style: TextStyle(color: AppColors.tetRed, fontWeight: FontWeight.bold)),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 32),
          Icon(Icons.bar_chart_outlined, size: 48, color: AppColors.midGrey.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          const Text('Chưa có dữ liệu cho năm này', style: TextStyle(color: AppColors.midGrey)),
        ],
      ),
    );
  }
}
