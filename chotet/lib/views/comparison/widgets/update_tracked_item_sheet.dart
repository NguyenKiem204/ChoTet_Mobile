import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chotet/themes/design_system.dart';
import 'package:chotet/viewmodels/comparison_viewmodel.dart';

class UpdateTrackedItemSheet extends StatefulWidget {
  final TrackedItem item;
  final ComparisonViewModel viewModel;

  const UpdateTrackedItemSheet({super.key, required this.item, required this.viewModel});

  @override
  State<UpdateTrackedItemSheet> createState() => _UpdateTrackedItemSheetState();
}

class _UpdateTrackedItemSheetState extends State<UpdateTrackedItemSheet> {
  late final _nameController = TextEditingController(text: widget.item.name);
  late final _unitController = TextEditingController(text: widget.item.unit);
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
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
              'Chỉnh sửa mặt hàng',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.tetRed,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            // Image Picker Area
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(AppRadius.m),
                    border: Border.all(color: Colors.grey.shade200),
                    image: _selectedImage != null
                        ? DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          )
                        : (widget.item.imageUrl.isNotEmpty
                            ? DecorationImage(
                                image: widget.item.imageUrl.startsWith('http')
                                    ? NetworkImage(widget.item.imageUrl) as ImageProvider
                                    : FileImage(File(widget.item.imageUrl)),
                                fit: BoxFit.cover,
                              )
                            : null),
                  ),
                  child: (_selectedImage == null && widget.item.imageUrl.isEmpty)
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_a_photo_outlined, size: 32, color: AppColors.tetRed),
                            const SizedBox(height: 8),
                            Text('Thêm ảnh', style: theme.textTheme.labelSmall?.copyWith(color: AppColors.tetRed)),
                          ],
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Tên mặt hàng',
                prefixIcon: const Icon(Icons.shopping_basket_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.m)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.m),
                  borderSide: const BorderSide(color: AppColors.tetRed, width: 2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            
            TextField(
              controller: _unitController,
              decoration: InputDecoration(
                labelText: 'Đơn vị tính',
                prefixIcon: const Icon(Icons.scale_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.m)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.m),
                  borderSide: const BorderSide(color: AppColors.tetRed, width: 2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final name = _nameController.text.trim();
                  final unit = _unitController.text.trim();
                  if (name.isNotEmpty && unit.isNotEmpty) {
                    widget.viewModel.updateTrackedItem(
                      widget.item.name, 
                      name, 
                      unit,
                      imageUrl: _selectedImage?.path,
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
                onPressed: () => Navigator.pop(context),
                child: Text('Hủy bỏ', style: TextStyle(color: Colors.grey.shade600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
