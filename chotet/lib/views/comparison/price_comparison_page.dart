import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chotet/themes/design_system.dart';
import 'package:chotet/views/widgets/atoms/tet_card.dart';
import 'package:chotet/views/comparison/widgets/add_tracked_item_sheet.dart';
import 'package:chotet/views/comparison/widgets/add_price_log_sheet.dart';
import 'package:chotet/views/comparison/widgets/update_tracked_item_sheet.dart';
import 'package:chotet/views/comparison/widgets/update_price_log_sheet.dart';
import 'package:chotet/utils/currency_formatter.dart';
import 'package:chotet/viewmodels/comparison_viewmodel.dart';
import 'package:intl/intl.dart';

class PriceComparisonPage extends StatefulWidget {
  const PriceComparisonPage({super.key});

  @override
  State<PriceComparisonPage> createState() => _PriceComparisonPageState();
}

class _PriceComparisonPageState extends State<PriceComparisonPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<ComparisonViewModel>(
      builder: (context, viewModel, child) {
        final filteredItems = viewModel.items.where((item) {
          return item.name.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.offWhite,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddItemDialog(context, viewModel),
            heroTag: 'price_comparison_fab',
            backgroundColor: AppColors.tetRed,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          body: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.m, AppSpacing.m, AppSpacing.m, AppSpacing.s),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm mặt hàng...',
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.midGrey),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: AppColors.midGrey, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 0, horizontal: AppSpacing.m),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.l),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.l),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.l),
                      borderSide:
                          const BorderSide(color: AppColors.tetRed, width: 1.5),
                    ),
                  ),
                ),
              ),
              // List content
              Expanded(
                child: viewModel.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.tetRed))
                    : filteredItems.isEmpty
                        ? Center(
                            child: Text(
                              _searchQuery.isEmpty
                                  ? 'Chưa có mặt hàng nào được khảo giá!'
                                  : 'Không tìm thấy mặt hàng nào.',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(color: AppColors.midGrey),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(AppSpacing.m, 0,
                                AppSpacing.m, AppSpacing.m),
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              return _buildTrackedItemCard(
                                  context, item, viewModel);
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrackedItemCard(
      BuildContext context, TrackedItem item, ComparisonViewModel viewModel) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.l),
      child: TetCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.m),
                  child: _buildItemImage(item.imageUrl),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Text('Đơn vị tính: ${item.unit}',
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.midGrey),
                  onSelected: (val) {
                    if (val == 'edit') {
                      _showUpdateItemDialog(context, item, viewModel);
                    } else if (val == 'delete') {
                      _showDeleteItemConfirmation(context, item, viewModel);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'edit', child: Text('Sửa mặt hàng')),
                    const PopupMenuItem(
                        value: 'delete',
                        child: Text('Xóa toàn bộ',
                            style: TextStyle(color: Colors.red))),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Lịch sử khảo giá',
                    style: theme.textTheme.titleSmall),
                TextButton.icon(
                  onPressed: () =>
                      _showAddPriceDialog(context, item, viewModel),
                  icon: const Icon(Icons.add_circle_outline, size: 16),
                  label: const Text('Thêm giá'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.tetRed,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            if (item.priceLogs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Chưa có giá nào được lưu.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontStyle: FontStyle.italic),
                ),
              )
            else
              ...item.priceLogs.map((log) {
                final isLowest = item.lowestPrice == log.price;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: InkWell(
                    onTap: () => _showUpdatePriceLogDialog(
                        context, item, log, viewModel),
                    borderRadius: BorderRadius.circular(AppRadius.s),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.s),
                      decoration: BoxDecoration(
                        color: isLowest
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(AppRadius.s),
                        border: isLowest
                            ? Border.all(
                                color:
                                    Colors.green.withValues(alpha: 0.3))
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(log.storeName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                Text(
                                  DateFormat('dd/MM HH:mm')
                                      .format(log.recordedAt),
                                  style: theme.textTheme.labelSmall
                                      ?.copyWith(
                                          color: AppColors.midGrey,
                                          fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              if (isLowest)
                                const Padding(
                                  padding: EdgeInsets.only(right: 4.0),
                                  child: Icon(Icons.thumb_up,
                                      color: Colors.green, size: 14),
                                ),
                              Text(
                                CurrencyFormatter.format(log.price),
                                style: TextStyle(
                                  color: isLowest
                                      ? Colors.green
                                      : AppColors.darkSurface,
                                  fontWeight: isLowest
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  void _showAddPriceDialog(
      BuildContext context, TrackedItem item, ComparisonViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddPriceLogSheet(item: item, viewModel: viewModel),
    );
  }

  void _showUpdatePriceLogDialog(BuildContext context, TrackedItem item,
      PriceLog log, ComparisonViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          UpdatePriceLogSheet(item: item, log: log, viewModel: viewModel),
    );
  }

  void _showUpdateItemDialog(
      BuildContext context, TrackedItem item, ComparisonViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          UpdateTrackedItemSheet(item: item, viewModel: viewModel),
    );
  }

  void _showDeleteItemConfirmation(
      BuildContext context, TrackedItem item, ComparisonViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
            'Bạn có chắc muốn xóa mặt hàng "${item.name}" và toàn bộ lịch sử giá của nó không?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              viewModel.deleteTrackedItem(item.name);
              Navigator.pop(context);
            },
            child:
                const Text('XÓA', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildItemImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImageError(),
      );
    } else {
      return Image.file(
        File(imageUrl),
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImageError(),
      );
    }
  }

  Widget _buildImageError() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey.shade100,
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }

  void _showAddItemDialog(
      BuildContext context, ComparisonViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTrackedItemSheet(viewModel: viewModel),
    );
  }
}
