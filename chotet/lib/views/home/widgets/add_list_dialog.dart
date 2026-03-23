import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../themes/design_system.dart';
import '../../../../domain/entities/shopping_list.dart';

class AddListDialog extends StatefulWidget {
  final ShoppingList? list;
  final Function(String name, double budget, DateTime scheduledDate, {String? imageUrl}) onAdd;

  const AddListDialog({super.key, required this.onAdd, this.list});

  @override
  State<AddListDialog> createState() => _AddListDialogState();
}

class _AddListDialogState extends State<AddListDialog> {
  late TextEditingController _nameController;
  late TextEditingController _budgetController;
  late DateTime _selectedDate;
  File? _selectedImage;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.list?.name ?? '');
    _budgetController = TextEditingController(
      text: widget.list != null ? widget.list!.budget.toStringAsFixed(0) : '',
    );
    _selectedDate = widget.list?.scheduledDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
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
        _selectedDate = picked;
      });
    }
  }

  void _submit() {
    final name = _nameController.text.trim();
    final budgetStr = _budgetController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final budget = double.tryParse(budgetStr) ?? 0;

    if (name.isNotEmpty && budget > 0) {
      widget.onAdd(name, budget, _selectedDate, imageUrl: _selectedImage?.path);
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên danh sách và ngân sách hợp lệ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.m,
        right: AppSpacing.m,
        top: AppSpacing.m,
        bottom: AppSpacing.m + bottomInset,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
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
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text(
                  widget.list == null ? 'Thêm danh sách mới' : 'Chỉnh sửa danh sách',
                  style: theme.textTheme.headlineMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            
            // Image Picker Section
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.tetRed.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppRadius.m),
                  border: Border.all(color: AppColors.tetRed.withValues(alpha: 0.2), style: BorderStyle.solid),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.m),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : (widget.list?.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.m),
                            child: Image.network(widget.list!.imageUrl!, fit: BoxFit.cover),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, color: AppColors.tetRed, size: 32),
                              SizedBox(height: 8),
                              Text('Thêm ảnh minh họa', style: TextStyle(color: AppColors.tetRed, fontWeight: FontWeight.bold)),
                              Text('(Nếu không chọn, sẽ dùng ảnh mặc định)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          )),
              ),
            ),
            const SizedBox(height: AppSpacing.l),

            TextField(
              controller: _nameController,
              style: const TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Tên danh sách',
                hintText: 'VD: Đồ cúng, Quà biếu...',
                prefixIcon: const Icon(Icons.edit_note),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.tetRed, width: 2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Ngân sách dự kiến (đ)',
                hintText: 'VD: 500,000',
                prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.tetRed, width: 2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            
            Text('Ngày dự kiến mua', style: theme.textTheme.bodySmall),
            const SizedBox(height: AppSpacing.xs),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: AppColors.tetRed),
                    const SizedBox(width: 12),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tetRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.m)),
                  elevation: 0,
                ),
                child: Text(
                  widget.list == null ? 'Tạo danh sách' : 'Lưu thay đổi',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
