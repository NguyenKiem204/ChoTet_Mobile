import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chotet/themes/design_system.dart';
import 'package:chotet/views/widgets/atoms/tet_card.dart';
import 'package:chotet/viewmodels/home_viewmodel.dart';
import 'package:chotet/domain/entities/shopping_item.dart';
import 'package:chotet/views/list_detail/widgets/update_price_dialog.dart';
import 'package:chotet/utils/currency_formatter.dart';
import 'package:chotet/viewmodels/auth_viewmodel.dart';
import 'package:chotet/views/auth/edit_profile_page.dart';

class RegionRoutePage extends StatefulWidget {
  const RegionRoutePage({super.key});

  @override
  State<RegionRoutePage> createState() => _RegionRoutePageState();
}

class _RegionRoutePageState extends State<RegionRoutePage> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        final groupedByDate = <DateTime, List<({ShoppingItem item, String listName})>>{};
        for (var list in viewModel.lists) {
          for (var item in list.items) {
            final date = item.scheduledDate ?? list.scheduledDate ?? DateTime.now();
            final dateKey = DateTime(date.year, date.month, date.day);
            if (!groupedByDate.containsKey(dateKey)) {
              groupedByDate[dateKey] = [];
            }
            groupedByDate[dateKey]!.add((item: item, listName: list.name));
          }
        }

        final sortedDates = groupedByDate.keys.toList()..sort();
        
        // Build display dates: Today + next 7 days, plus any dates with plans
        final List<DateTime> displayDates = [];
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        for (int i = 0; i < 7; i++) {
          displayDates.add(today.add(Duration(days: i)));
        }
        
        // Ensure selected date is in displayDates if it has items or was explicitly picked
        if (!displayDates.any((d) => d.year == _selectedDate.year && d.month == _selectedDate.month && d.day == _selectedDate.day)) {
          displayDates.add(_selectedDate);
        }

        for (var date in sortedDates) {
          if (!displayDates.any((d) => d.year == date.year && d.month == date.month && d.day == date.day)) {
            displayDates.add(date);
          }
        }
        displayDates.sort();

        final filteredItems = groupedByDate[_selectedDate] ?? [];
        final completedCount = filteredItems.where((entry) => entry.item.isPurchased).length;
        final totalCount = filteredItems.length;
        final progress = totalCount > 0 ? (completedCount / totalCount) : 0.0;

        return Scaffold(
          backgroundColor: AppColors.tetRed,
          appBar: AppBar(
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.maybePop(context),
            ),
            title: const Text(
              'Lịch trình mua sắm',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.account_circle, color: Colors.white),
                onPressed: () => _handleProfileAction(context),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildDateHeader(displayDates, groupedByDate),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
                  ),
                  child: filteredItems.isEmpty
                      ? _buildEmptyState(theme)
                      : ListView(
                          padding: const EdgeInsets.all(AppSpacing.m),
                          children: [
                            _buildDaySummaryCard(theme, completedCount, totalCount, progress),
                            const SizedBox(height: AppSpacing.l),
                            Row(
                              children: [
                                const Icon(Icons.list_alt, color: AppColors.tetRed, size: 24),
                                const SizedBox(width: AppSpacing.s),
                                Text(
                                  'Danh sách hôm nay',
                                  style: theme.textTheme.headlineMedium?.copyWith(fontSize: 18),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.tetRed.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(AppRadius.m),
                                  ),
                                  child: const Text(
                                    'Tết Nguyên Đán',
                                    style: TextStyle(color: AppColors.tetRed, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.m),
                            ...filteredItems.map((entry) => _buildShoppingItemRow(context, viewModel, entry)),
                            const SizedBox(height: AppSpacing.l),
                            _buildPromoBanner(theme),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateHeader(List<DateTime> dates, Map<DateTime, List<({ShoppingItem item, String listName})>> groupedByDate) {
    return Container(
      color: AppColors.tetRed,
      child: Column(
        children: [
          _buildDateSelectorStrip(dates, groupedByDate),
        ],
      ),
    );
  }

  Future<void> _showCalendarPicker() async {
    final theme = Theme.of(context);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith( 
            colorScheme: const ColorScheme.light(
              primary: AppColors.tetRed,
              onPrimary: Colors.white,
              onSurface: AppColors.darkSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  Widget _buildDateSelectorStrip(List<DateTime> dates, Map<DateTime, List<({ShoppingItem item, String listName})>> groupedByDate) {
    return SizedBox(
      height: 90,
      child: Row(
        children: [
          // Calendar Picker Button
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.m, bottom: 8),
            child: IconButton(
              icon: const Icon(Icons.calendar_month, color: Colors.white),
              onPressed: _showCalendarPicker,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.m)),
                padding: const EdgeInsets.all(12),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: AppSpacing.s),
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final date = dates[index];
                final isSelected = date.year == _selectedDate.year && date.month == _selectedDate.month && date.day == _selectedDate.day;
                // final hasItems = groupedByDate.keys.any((d) => d.year == date.year && d.month == date.month && d.day == date.day); // Unused
                // final now = DateTime.now(); // Unused
                // final isToday = date.year == now.year && date.month == now.month && date.day == now.day; // Unused

                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = date),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 65,
                    margin: const EdgeInsets.only(right: AppSpacing.s),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.vibrantGold : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.m),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ] : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'THỨ ${date.weekday == 7 ? 'CN' : date.weekday + 1}',
                          style: TextStyle(
                            color: isSelected ? AppColors.charcoal : Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: isSelected ? AppColors.charcoal : Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (groupedByDate[DateTime(date.year, date.month, date.day)]?.isNotEmpty ?? false)
                          Icon(
                            Icons.stars, 
                            color: isSelected ? AppColors.tetRed : AppColors.vibrantGold, 
                            size: 8
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySummaryCard(ThemeData theme, int completed, int total, double progress) {
    return TetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                   const SizedBox(width: AppSpacing.xs),
                   Text('TIẾN ĐỘ NGÀY', style: theme.textTheme.bodySmall?.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                ],
              ),
              Text('$completed/$total Món đồ', style: theme.textTheme.titleSmall?.copyWith(color: AppColors.tetRed, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Stack(
            children: [
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.tetRed, Colors.orange],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            '"Sắp hoàn thành sắm Tết rồi, cố lên!"',
            style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: AppColors.midGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.tetRed,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        image: DecorationImage(
          image: const NetworkImage('https://images.unsplash.com/photo-1613573488074-590157e97c10?auto=format&fit=crop&q=80&w=800'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(AppColors.tetRed.withValues(alpha: 0.6), BlendMode.srcOver),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: AppSpacing.s),
          Text(
            'HOA KHAI PHÚ QUÝ',
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.vibrantGold, fontWeight: FontWeight.bold, letterSpacing: 2.0),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Vạn Sự Như Ý\nAn Khang Thịnh Vượng',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white, fontSize: 24, height: 1.2),
          ),
          const SizedBox(height: AppSpacing.m),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.vibrantGold.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: const Text('XUÂN TẾT 2026', style: TextStyle(color: AppColors.vibrantGold, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 64, color: AppColors.midGrey.withValues(alpha: 0.1)),
          const SizedBox(height: AppSpacing.m),
          Text(
            'Thảnh thơi rồi!\nKhông có kế hoạch cho ngày này.',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(color: AppColors.midGrey),
          ),
        ],
      ),
    );
  }

  void _handleProfileAction(BuildContext context) {
    final authViewModel = context.read<AuthViewModel>();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(authViewModel.user?.firstName != null || authViewModel.user?.nickname != null 
                  ? (authViewModel.user?.nickname ?? '${authViewModel.user?.firstName} ${authViewModel.user?.lastName}')
                  : authViewModel.user?.username ?? 'Người dùng'),
              subtitle: Text(authViewModel.user?.email ?? ''),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.tetRed),
              title: const Text('Chỉnh sửa hồ sơ'),
              onTap: () {
                Navigator.pop(context); // Close sheet
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfilePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
              onTap: () {
                authViewModel.logout();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShoppingItemRow(BuildContext context, HomeViewModel viewModel, ({ShoppingItem item, String listName}) entry) {
    final theme = Theme.of(context);
    final item = entry.item;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: TetCard(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => UpdatePriceDialog(
              item: item,
              onUpdate: (price) => viewModel.updateItem(item.id, actualPrice: price, isPurchased: true),
            ),
          );
        },
        color: item.isExtra ? const Color(0xFFFFFDE7) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.tetRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: item.imageUrl != null
                    ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                    : Icon(
                        _getCategoryIcon(item.category),
                        color: AppColors.tetRed,
                      ),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: item.isPurchased ? AppColors.midGrey.withValues(alpha: 0.6) : AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (item.isPurchased) ...[
                        Text(
                          CurrencyFormatter.format(item.estimatedPrice),
                          style: TextStyle(
                            color: AppColors.midGrey.withValues(alpha: 0.5),
                            decoration: TextDecoration.lineThrough,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        item.isPurchased 
                            ? (item.actualPrice != null ? CurrencyFormatter.format(item.actualPrice!) : 'Đã mua')
                            : CurrencyFormatter.format(item.estimatedPrice),
                        style: TextStyle(
                          color: AppColors.tetRed,
                          fontWeight: FontWeight.bold,
                          fontSize: item.isPurchased ? 14 : 13,
                        ),
                      ),
                    ],
                  ),
                  if (item.isPurchased && item.purchasedBy != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Đã mua bởi: ${item.purchasedBy!.displayName}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.tetRed.withValues(alpha: 0.7),
                          fontStyle: FontStyle.italic,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => viewModel.toggleItemPurchaseStatus(item.id),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: item.isPurchased ? AppColors.tetRed : AppColors.lightGrey,
                    width: 2,
                  ),
                  color: item.isPurchased ? AppColors.tetRed : Colors.transparent,
                ),
                child: item.isPurchased
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'thực phẩm':
      case 'đồ ăn':
        return Icons.restaurant;
      case 'đồ uống':
        return Icons.local_bar;
      case 'trang trí':
        return Icons.celebration;
      case 'bánh kẹo':
        return Icons.cake;
      case 'trái cây':
        return Icons.apple;
      default:
        return Icons.shopping_bag;
    }
  }
}
