import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../themes/design_system.dart';
import '../widgets/atoms/tet_card.dart';
import '../widgets/atoms/tet_progress_bar.dart';
import '../../utils/currency_formatter.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../domain/entities/shopping_list.dart';
import '../list_detail/list_detail_page.dart';

class ShoppingHistoryPage extends StatelessWidget {
  const ShoppingHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.offWhite,
        appBar: AppBar(
          title: const Text('Lịch sử mua sắm'),
          backgroundColor: AppColors.tetRed,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg_auth_header.png'),
                fit: BoxFit.cover,
                opacity: 0.15,
              ),
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Tất cả'),
              Tab(text: 'Đã xong'),
              Tab(text: 'Kế hoạch'),
            ],
          ),
        ),
        body: Consumer<HomeViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.tetRed));
            }

            final allLists = viewModel.lists;
            if (allLists.isEmpty) {
              return _buildEmptyState();
            }

            return TabBarView(
              children: [
                _buildListView(context, allLists), // Tất cả
                _buildListView(context, allLists.where((l) => l.status == 'COMPLETED' || l.progress >= 1.0).toList()), // Đã xong
                _buildListView(context, allLists.where((l) => l.status != 'COMPLETED' && l.progress < 1.0).toList()), // Kế hoạch
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildListView(BuildContext context, List<ShoppingList> lists) {
    if (lists.isEmpty) {
      return const Center(child: Text('Không có danh sách nào.', style: TextStyle(color: AppColors.midGrey)));
    }

    // Sort by date descending
    final sortedLists = List<ShoppingList>.from(lists)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Group by month/year
    final Map<String, List<ShoppingList>> groups = {};
    for (var list in sortedLists) {
      final monthYear = DateFormat('MMMM, y', 'vi').format(list.date);
      final key = monthYear[0].toUpperCase() + monthYear.substring(1);
      groups.putIfAbsent(key, () => []).add(list);
    }

    return RefreshIndicator(
      onRefresh: () => context.read<HomeViewModel>().fetchLists(),
      color: AppColors.tetRed,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final title = groups.keys.elementAt(index);
          final items = groups[title]!;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(context, title),
              ...items.map((list) => _buildHistoryCard(context, list)),
              if (index == groups.length - 1) const SizedBox(height: AppSpacing.xl),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.l, bottom: AppSpacing.s),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.midGrey,
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, ShoppingList list) {
    final theme = Theme.of(context);
    final isOverBudget = list.isOverBudget;
    final statusColor = isOverBudget ? AppColors.danger : Colors.green;
    final progress = list.progress;
    final statusLabel = isOverBudget ? 'VƯỢT NGÂN SÁCH' : 'TRONG NGÂN SÁCH';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: TetCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ListDetailPage(list: list),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppRadius.m),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            list.name, 
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd/MM/yyyy').format(list.date), 
                            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.midGrey),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(statusLabel, statusColor),
                  ],
                ),
                const SizedBox(height: AppSpacing.m),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          CurrencyFormatter.format(list.totalActual),
                          style: TextStyle(
                            color: isOverBudget ? AppColors.tetRed : AppColors.darkSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          ' / ${CurrencyFormatter.format(list.budget)}',
                          style: const TextStyle(
                            color: AppColors.midGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        color: isOverBudget ? AppColors.danger : AppColors.midGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s),
                TetProgressBar(
                  progress: progress, 
                  isOverBudget: isOverBudget,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.s),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_outlined, size: 64, color: AppColors.midGrey.withValues(alpha: 0.2)),
          const SizedBox(height: AppSpacing.m),
          const Text('Chưa có lịch sử mua sắm nào.', style: TextStyle(color: AppColors.midGrey)),
        ],
      ),
    );
  }
}
