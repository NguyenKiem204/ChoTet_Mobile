import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
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

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBudgetDashboard(context, totalActual, totalBudget, saving, savingPercent),
                    const SizedBox(height: AppSpacing.l),
                    _buildSectionHeader(context, 'Tiến độ sắm Tết', Icons.trending_up),
                    const SizedBox(height: AppSpacing.m),
                    _buildProgressCard(context, completionRate, purchasedCount, totalCount),
                    const SizedBox(height: AppSpacing.l),
                    _buildSectionHeader(context, 'Phân bổ chi tiêu', Icons.pie_chart_outline),
                    const SizedBox(height: AppSpacing.m),
                    _buildCategoryChart(context, homeViewModel.categoryStats),
                    const SizedBox(height: AppSpacing.l),
                    if (homeViewModel.memberStats.isNotEmpty) ...[
                      _buildSectionHeader(context, 'Thành viên đóng góp', Icons.group_outlined),
                      const SizedBox(height: AppSpacing.m),
                      _buildMemberStats(context, homeViewModel.memberStats),
                      const SizedBox(height: AppSpacing.l),
                    ],
                    _buildActionButtons(context),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: AppColors.tetRed,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/bg_auth_header.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.4),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.1),
                    AppColors.tetRed.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text(
                  'TỔNG KẾT TẾT 2026',
                  style: GoogleFonts.outfit(
                    color: AppColors.vibrantGold,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sắm Tết Sung Túc',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Vạn sự như ý - An khang thịnh vượng',
                  style: GoogleFonts.nunito(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.tetRed, size: 20),
        const SizedBox(width: AppSpacing.s),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.charcoal,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetDashboard(BuildContext context, double actual, double budget, double saving, int percent) {
    return TetCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TỔNG CHI TIÊU', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.midGrey, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 4),
                    Text(CurrencyFormatter.format(actual), style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.tetRed)),
                    const SizedBox(height: 16),
                    _buildMiniStat('Ngân sách', CurrencyFormatter.format(budget), Icons.account_balance_wallet_outlined),
                    const SizedBox(height: 8),
                    _buildMiniStat(
                      saving >= 0 ? 'Tiết kiệm' : 'Vượt mức', 
                      CurrencyFormatter.format(saving.abs()), 
                      saving >= 0 ? Icons.trending_down : Icons.trending_up,
                      color: saving >= 0 ? Colors.green : AppColors.tetRed,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 120,
                  child: Stack(
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 35,
                          startDegreeOffset: -90,
                          sections: [
                            PieChartSectionData(
                              color: AppColors.tetRed,
                              value: actual,
                              title: '',
                              radius: 12,
                            ),
                            PieChartSectionData(
                              color: AppColors.lightGrey.withValues(alpha: 0.3),
                              value: saving > 0 ? saving : 0,
                              title: '',
                              radius: 10,
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${budget > 0 ? (actual / budget * 100).round() : 0}%',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const Text('Sử dụng', style: TextStyle(fontSize: 8, color: AppColors.midGrey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color ?? AppColors.midGrey),
        const SizedBox(width: 4),
        Text('$label: ', style: const TextStyle(fontSize: 12, color: AppColors.midGrey)),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color ?? AppColors.charcoal)),
      ],
    );
  }

  Widget _buildProgressCard(BuildContext context, double rate, int purchased, int total) {
    return TetCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tỷ lệ hoàn thành', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
              Text('${(rate * 100).round()}%', style: GoogleFonts.outfit(color: AppColors.tetRed, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: rate,
              minHeight: 10,
              backgroundColor: AppColors.lightGrey.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.tetRed),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressItem(context, 'Đã mua', purchased.toString(), Colors.green),
              _buildProgressItem(context, 'Chưa mua', (total - purchased).toString(), Colors.orange),
              _buildProgressItem(context, 'Tổng cộng', total.toString(), AppColors.midGrey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.midGrey)),
      ],
    );
  }

  Widget _buildCategoryChart(BuildContext context, Map<String, ({double estimated, double actual})> stats) {
    final entries = stats.entries.toList()
      ..sort((a, b) => b.value.actual.compareTo(a.value.actual));
    
    final displayEntries = entries.take(5).toList();

    return TetCard(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: displayEntries.isEmpty ? 100 : displayEntries.map((e) => e.value.actual).reduce((a, b) => a > b ? a : b) * 1.2,
                barTouchData: BarTouchData(enabled: true),
                titlesData: const FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: displayEntries.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.value.actual,
                        color: AppColors.tetRed,
                        width: 16,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          ...displayEntries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.tetRed, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(e.key, style: const TextStyle(fontSize: 12)),
                const Spacer(),
                Text(CurrencyFormatter.format(e.value.actual), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildMemberStats(BuildContext context, Map<int, ({String name, int itemsCount, double totalSpent})> stats) {
    return Column(
      children: stats.values.map((stat) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.s),
        child: TetCard(
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.tetRed.withValues(alpha: 0.1),
                child: Text(stat.name.substring(0, 1).toUpperCase(), style: const TextStyle(color: AppColors.tetRed, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stat.name, style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
                    Text('${stat.itemsCount} món đồ', style: const TextStyle(fontSize: 12, color: AppColors.midGrey)),
                  ],
                ),
              ),
              Text(CurrencyFormatter.format(stat.totalSpent), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.success)),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.picture_as_pdf, size: 18),
                label: const Text('XUẤT PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.charcoal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share, size: 18),
                label: const Text('CHIA SẺ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.charcoal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.lightGrey),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tetRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('VỀ TRANG CHỦ', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ),
        ),
      ],
    );
  }
}
