import 'package:flutter/material.dart';
import 'package:chotet/themes/design_system.dart';
import 'package:chotet/viewmodels/comparison_viewmodel.dart';
import 'package:intl/intl.dart';

class UpdatePriceLogSheet extends StatefulWidget {
  final TrackedItem item;
  final PriceLog log;
  final ComparisonViewModel viewModel;

  const UpdatePriceLogSheet({
    super.key, 
    required this.item, 
    required this.log, 
    required this.viewModel,
  });

  @override
  State<UpdatePriceLogSheet> createState() => _UpdatePriceLogSheetState();
}

class _UpdatePriceLogSheetState extends State<UpdatePriceLogSheet> {
  late final _storeController = TextEditingController(text: widget.log.storeName);
  late final _priceController = TextEditingController(text: widget.log.price.toStringAsFixed(0));
  late final _dateController = TextEditingController(
    text: DateFormat('dd/MM/yyyy').format(_selectedDate),
  );
  late DateTime _selectedDate = widget.log.recordedAt;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.tetRed,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.l,
        right: AppSpacing.l,
        top: AppSpacing.l,
        bottom: AppSpacing.l + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.l)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              'Chỉnh sửa thông tin giá',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.tetRed,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Mặt hàng: ${widget.item.name}',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            TextField(
              controller: _storeController,
              decoration: InputDecoration(
                labelText: 'Tên sạp / Cửa hàng',
                prefixIcon: const Icon(Icons.storefront_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.m)),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Giá khảo sát (${widget.item.unit})',
                prefixIcon: const Icon(Icons.payments_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.m)),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: TextField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Ngày ghi nhận',
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.m)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final store = _storeController.text.trim();
                  final priceStr = _priceController.text.replaceAll(RegExp(r'[^0-9]'), '');
                  final price = double.tryParse(priceStr) ?? 0;
                  
                  if (store.isNotEmpty && price > 0) {
                    widget.viewModel.updatePriceLog(
                      widget.log.id,
                      widget.item.name,
                      store, 
                      price, 
                      widget.item.unit,
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tetRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.m)),
                  elevation: 0,
                ),
                child: const Text('CẬP NHẬT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Center(
              child: TextButton(
                onPressed: () {
                  widget.viewModel.deletePriceLog(widget.log.id);
                  Navigator.pop(context);
                },
                child: const Text('XÓA BẢN GHI NÀY', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
