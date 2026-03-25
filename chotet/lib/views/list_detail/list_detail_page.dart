import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chotet/domain/entities/shopping_list.dart';
import 'package:chotet/themes/design_system.dart';
import 'package:chotet/viewmodels/list_detail_viewmodel.dart';
import 'package:chotet/viewmodels/home_viewmodel.dart';
import 'package:chotet/viewmodels/auth_viewmodel.dart';
import 'package:chotet/data/services/shopping_service.dart';
import 'package:chotet/views/widgets/molecules/shopping_item_tile.dart';
import 'package:chotet/views/add_item/add_item_page.dart';
import 'package:chotet/utils/currency_formatter.dart';
import 'package:chotet/domain/entities/shopping_item.dart';
import 'package:chotet/views/widgets/organisms/receipt_scanner_sheet.dart';
import 'package:chotet/views/list_detail/widgets/update_price_dialog.dart';
import 'package:chotet/views/list_detail/widgets/share_list_dialog.dart';
import 'package:chotet/views/home/widgets/add_list_dialog.dart';
import 'package:google_fonts/google_fonts.dart';

class ListDetailPage extends StatelessWidget {
  final ShoppingList list;

  const ListDetailPage({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ListDetailViewModel(
        list.id,
        Provider.of<HomeViewModel>(context, listen: false),
        Provider.of<ShoppingService>(context, listen: false),
      ),
      child: Consumer<ListDetailViewModel>(
        builder: (context, viewModel, child) {
          final displayItems = viewModel.getFilteredItems();
          
          return Scaffold(
            backgroundColor: AppColors.offWhite,
            body: Column(
              children: [
                // Custom Header
                _buildHeader(context, viewModel),
                
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 130), // Increased space for overlapping card
                          // Tabs
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F4F7),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                children: [
                                  _buildTab(context, 'Tất cả', viewModel.currentFilter == ItemFilter.all, () => viewModel.setFilter(ItemFilter.all)),
                                  _buildTab(context, 'Chưa mua', viewModel.currentFilter == ItemFilter.pending, () => viewModel.setFilter(ItemFilter.pending)),
                                  _buildTab(context, 'Đã mua', viewModel.currentFilter == ItemFilter.purchased, () => viewModel.setFilter(ItemFilter.purchased)),
                                ],
                              ),
                            ),
                          ),
                          
                          // Item List
                          Expanded(
                            child: viewModel.isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : ListView.builder(
                                    padding: const EdgeInsets.all(AppSpacing.m),
                                    itemCount: displayItems.length,
                                    itemBuilder: (context, index) {
                                      final item = displayItems[index];
                                      return Dismissible(
                                        key: Key(item.id),
                                        direction: DismissDirection.endToStart,
                                        background: Container(
                                          alignment: Alignment.centerRight,
                                          padding: const EdgeInsets.only(right: AppSpacing.l),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(AppRadius.m),
                                          ),
                                          child: const Icon(Icons.delete, color: Colors.white),
                                        ),
                                        onDismissed: (_) {
                                          viewModel.deleteItem(item.id);
                                        },
                                        child: ShoppingItemTile(
                                          item: item,
                                          currentUserId: Provider.of<AuthViewModel>(context, listen: false).user?.id?.toString(),
                                          onToggle: () => viewModel.toggleItemPurchase(item.id),
                                          onTap: () {
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor: Colors.transparent,
                                              builder: (_) => UpdatePriceDialog(
                                                item: item,
                                                onUpdate: (price) => viewModel.updateItemPrice(item.id, price),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                      
                      // Overlapping Budget Card
                      Positioned(
                        top: -50,
                        left: AppSpacing.m,
                        right: AppSpacing.m,
                        child: _buildBudgetCard(context, viewModel),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddItemPage(initialDate: viewModel.list.scheduledDate)),
                );
                if (result != null && result is ShoppingItem) {
                  viewModel.addItem(
                    result.name,
                    result.quantity,
                    result.unit,
                    result.estimatedPrice,
                    result.category,
                    scheduledDate: result.scheduledDate,
                    imageUrl: result.imageUrl,
                  );
                }
              },
              heroTag: 'list_detail_fab',
              backgroundColor: AppColors.tetRed,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ListDetailViewModel viewModel) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.tetRed,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1708840250299-18857298ab8a'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          bottom: 90,
          left: 10,
          right: 10,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                
                // Title and Subtitle
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Chi tiết Danh mục',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            const Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sắm Tết Bính Ngọ 2026',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Actions
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.document_scanner_outlined, color: Colors.white, size: 22),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => ReceiptScannerSheet(viewModel: viewModel),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_outlined, color: Colors.white, size: 22),
                      onPressed: () {
                        final currentUserId = Provider.of<AuthViewModel>(context, listen: false)
                            .user
                            ?.id
                            ?.toString();
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => ShareListDialog(
                            viewModel: viewModel,
                            currentUserId: currentUserId,
                          ),
                        );
                      },
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white, size: 22),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditDialog(context, viewModel);
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(context, viewModel);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: AppColors.tetRed, size: 20),
                              SizedBox(width: 12),
                              Text('Chỉnh sửa'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              SizedBox(width: 12),
                              Text('Xóa danh sách', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            if (viewModel.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  viewModel.error!,
                  style: const TextStyle(color: Colors.yellow, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard(BuildContext context, ListDetailViewModel viewModel) {
    final progress = viewModel.list.progress;
    final remains = viewModel.list.budget - viewModel.list.totalActual;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NGÂN SÁCH ĐÃ DÙNG',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.midGrey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(viewModel.list.totalActual),
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.tetRed,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Gradient Progress Bar
          Stack(
            children: [
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.tetRed, Color(0xFFFF8C42)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              remains >= 0 
                  ? '* Còn lại ${CurrencyFormatter.format(remains)} trong hạn mức'
                  : '* Vượt ${CurrencyFormatter.format(remains.abs())} so với ngân sách',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: remains >= 0 ? AppColors.midGrey : AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.tetRed : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            boxShadow: isActive ? [
              BoxShadow(
                color: AppColors.tetRed.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ] : null,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                color: isActive ? Colors.white : AppColors.midGrey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, ListDetailViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddListDialog(
        list: viewModel.list,
        onAdd: (name, budget, scheduledDate, {imageUrl}) {
          viewModel.updateList(name, budget, scheduledDate, imageUrl: imageUrl);
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ListDetailViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa danh sách "${viewModel.list.name}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: AppColors.midGrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              try {
                // Close the dialog first
                navigator.pop();
                
                await viewModel.deleteList();
                
                // Pop the detail page
                navigator.pop();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Không thể xóa danh sách: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
