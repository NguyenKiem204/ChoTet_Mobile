import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chotet/themes/design_system.dart';
import 'package:chotet/views/widgets/atoms/tet_card.dart';
import 'package:chotet/views/comparison/widgets/add_tracked_item_sheet.dart';
import 'package:chotet/views/comparison/widgets/add_price_log_sheet.dart'; // Added here
import 'package:chotet/utils/currency_formatter.dart';
import 'package:chotet/viewmodels/comparison_viewmodel.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class PriceComparisonPage extends StatelessWidget {
  const PriceComparisonPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<ComparisonViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Sổ tay khảo giá'),
            actions: [
              IconButton(icon: const Icon(Icons.add), onPressed: () => _showAddItemDialog(context, viewModel)),
            ],
          ),
          body: viewModel.items.isEmpty
              ? Center(child: Text('Chưa có mặt hàng nào được khảo giá!', style: theme.textTheme.titleMedium?.copyWith(color: AppColors.midGrey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  itemCount: viewModel.items.length,
                  itemBuilder: (context, index) {
                    final item = viewModel.items[index];
                    return _buildTrackedItemCard(context, item, viewModel);
                  },
                ),
        );
      },
    );
  }

  Widget _buildTrackedItemCard(BuildContext context, TrackedItem item, ComparisonViewModel viewModel) {
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
                      Text(item.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text('Đơn vị tính: ${item.unit}', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Lịch sử khảo giá', style: theme.textTheme.titleSmall),
                TextButton.icon(
                  onPressed: () => _showAddPriceDialog(context, item, viewModel),
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
                child: Text('Chưa có giá nào được lưu.', style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
              )
            else
              ...item.priceLogs.map((log) {
                final isLowest = item.lowestPrice == log.price;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.s),
                    decoration: BoxDecoration(
                      color: isLowest ? Colors.green.withValues(alpha: 0.1) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(AppRadius.s),
                      border: isLowest ? Border.all(color: Colors.green.withValues(alpha: 0.3)) : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(log.storeName, style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text(DateFormat('dd/MM HH:mm').format(log.recordedAt), style: theme.textTheme.labelSmall?.copyWith(color: AppColors.midGrey, fontSize: 10)),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            if (isLowest)
                              const Padding(
                                padding: EdgeInsets.only(right: 4.0),
                                child: Icon(Icons.thumb_up, color: Colors.green, size: 14),
                              ),
                            Text(CurrencyFormatter.format(log.price), style: TextStyle(
                              color: isLowest ? Colors.green : AppColors.darkSurface,
                              fontWeight: isLowest ? FontWeight.bold : FontWeight.normal,
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  void _showAddPriceDialog(BuildContext context, TrackedItem item, ComparisonViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddPriceLogSheet(item: item, viewModel: viewModel),
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

  void _showAddItemDialog(BuildContext context, ComparisonViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTrackedItemSheet(viewModel: viewModel),
    );
  }
}
