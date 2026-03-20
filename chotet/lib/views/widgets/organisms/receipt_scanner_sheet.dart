import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../themes/design_system.dart';
import '../../../../viewmodels/list_detail_viewmodel.dart';
import '../../../../viewmodels/comparison_viewmodel.dart';

class ReceiptScannerSheet extends StatefulWidget {
  final ListDetailViewModel viewModel;
  
  const ReceiptScannerSheet({super.key, required this.viewModel});

  @override
  State<ReceiptScannerSheet> createState() => _ReceiptScannerSheetState();
}

class _ReceiptScannerSheetState extends State<ReceiptScannerSheet> {
  bool _isScanning = false;
  bool _isDone = false;
  List<Map<String, dynamic>> _scanResults = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImageFromSource(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (image == null) return;
    if (!mounted) return;
    
    Navigator.pop(context); // Close the source picker modal
    _processImage(image.path);
  }

  Future<void> _startScan() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.l)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Chọn nguồn ảnh', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: AppSpacing.l),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.tetRed),
              title: const Text('Chụp ảnh mới'),
              onTap: () => _pickImageFromSource(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.tetRed),
              title: const Text('Chọn từ thư viện'),
              onTap: () => _pickImageFromSource(ImageSource.gallery),
            ),
            const SizedBox(height: AppSpacing.m),
          ],
        ),
      ),
    );
  }

  Future<void> _processImage(String path) async {
    setState(() {
      _isScanning = true;
      _isDone = false;
    });

    final comparisonVM = Provider.of<ComparisonViewModel>(context, listen: false);
    
    // 2. Call the real scan API
    final results = await widget.viewModel.scanReceipt(path, comparisonVM);

    if (mounted) {
      setState(() {
        _isScanning = false;
        _isDone = true;
        _scanResults = results;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.l)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.l),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quét hóa đơn bằng AI',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (_isDone)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng', style: TextStyle(color: AppColors.tetRed)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          if (!_isScanning && !_isDone)
            Text(
              'Hệ thống sẽ tự động đọc hóa đơn, cập nhật giá cho mọi danh sách và thêm các món phát sinh.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.midGrey),
            ),
          const SizedBox(height: AppSpacing.xl),
          if (_isScanning) ...[
            const CircularProgressIndicator(color: AppColors.tetRed),
            const SizedBox(height: AppSpacing.m),
            const Text('AI đang phân bổ món đồ vào các danh sách...'),
          ] else if (_isDone) ...[
            const Text('KẾT QUẢ PHÂN TÍCH', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppColors.midGrey)),
            const SizedBox(height: AppSpacing.m),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _scanResults.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final res = _scanResults[index];
                  final isMatched = res['status'] == 'matched';
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      isMatched ? Icons.check_circle : Icons.add_circle,
                      color: isMatched ? Colors.green : Colors.orange,
                    ),
                    title: Text(res['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      isMatched 
                        ? (res['isCurrentList'] ? 'Cập nhật giá & Đã mua' : 'Cập nhật vào: ${res['listName']}')
                        : 'Món phát sinh (Đã thêm)',
                      style: TextStyle(fontSize: 11, color: isMatched ? Colors.green.shade700 : Colors.orange.shade800),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            const Text('Tất cả đã được đồng bộ hóa!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ] else ...[
            Icon(Icons.document_scanner_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: AppSpacing.l),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _startScan,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Chụp / Tải hóa đơn lên'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tetRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.m)),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.l),
        ],
      ),
    );
  }
}
