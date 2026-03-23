import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../themes/design_system.dart';
import '../widgets/atoms/tet_button.dart';
import '../../../domain/entities/shopping_item.dart';

class AddItemPage extends StatefulWidget {
  final DateTime? initialDate;

  const AddItemPage({super.key, this.initialDate});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _units = ['cái', 'cây', 'kg', 'g', 'bó', 'món', 'túi', 'chai'];
  final List<String> _marketZones = ['Thịt tươi & Hải sản', 'Rau củ', 'Trái cây', 'Bách hóa', 'Đồ ăn vặt', 'Trang trí & Hoa'];
  
  String _name = '';
  double _quantity = 1.0;
  double _price = 0;
  String _selectedUnit = 'kg';
  String _selectedZone = 'Thịt tươi & Hải sản';
  late DateTime _selectedDate;
  File? _selectedImage;
  final _picker = ImagePicker();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Thêm món đồ'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Center(
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppColors.tetRed.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(AppRadius.l),
                      border: Border.all(
                        color: AppColors.tetRed.withValues(alpha: 0.2),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.l),
                            child: Image.file(_selectedImage!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_a_photo, color: AppColors.tetRed, size: 40),
                              const SizedBox(height: AppSpacing.s),
                              Text(
                                '+ Thêm ảnh',
                                style: theme.textTheme.labelLarge?.copyWith(color: AppColors.tetRed),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.l),

              _buildLabel(context, 'TÊN MÓN ĐỒ'),
              TextFormField(
                initialValue: _name,
                decoration: _buildInputDecoration('Nhập tên món đồ'),
                onChanged: (val) => _name = val,
              ),
              const SizedBox(height: AppSpacing.m),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(context, 'SỐ LƯỢNG'),
                        TextFormField(
                          initialValue: _quantity.toStringAsFixed(0),
                          keyboardType: TextInputType.number,
                          decoration: _buildInputDecoration('0'),
                          onChanged: (val) => _quantity = double.tryParse(val) ?? 1.0,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(context, 'ĐƠN VỊ'),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedUnit,
                          items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                          onChanged: (val) => setState(() => _selectedUnit = val!),
                          decoration: _buildInputDecoration(''),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),

              _buildLabel(context, 'GIÁ ƯỚC TÍNH (đ)'),
              TextFormField(
                initialValue: _price > 0 ? _price.toStringAsFixed(0) : '',
                keyboardType: TextInputType.number,
                decoration: _buildInputDecoration('0').copyWith(
                  suffixText: 'đ',
                  suffixStyle: theme.textTheme.bodyMedium?.copyWith(color: AppColors.midGrey),
                ),
                onChanged: (val) {
                  final cleanStr = val.replaceAll(RegExp(r'[^0-9]'), '');
                  _price = double.tryParse(cleanStr) ?? 0;
                },
              ),
              const SizedBox(height: AppSpacing.m),

              _buildLabel(context, 'KHU VỰC CHỢ'),
              DropdownButtonFormField<String>(
                initialValue: _selectedZone,
                items: _marketZones.map((z) => DropdownMenuItem(value: z, child: Text(z))).toList(),
                onChanged: (val) => setState(() => _selectedZone = val!),
                decoration: _buildInputDecoration(''),
              ),
              const SizedBox(height: AppSpacing.m),

              _buildLabel(context, 'NGÀY DỰ KIẾN MUA'),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(AppRadius.l),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18, color: AppColors.tetRed),
                      const SizedBox(width: 12),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down, color: AppColors.midGrey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.m),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              TetButton(
                label: 'LƯU MẶT HÀNG',
                onPressed: () {
                  if (_name.trim().isEmpty) {
                    setState(() {
                      _errorMessage = 'Vui lòng nhập tên món đồ cần mua';
                    });
                    return;
                  }
                  setState(() => _errorMessage = null);
                  final newItem = ShoppingItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: _name.trim(),
                    quantity: _quantity,
                    unit: _selectedUnit,
                    estimatedPrice: _price,
                    category: _selectedZone,
                    scheduledDate: _selectedDate,
                    imageUrl: _selectedImage?.path,
                  );
                  Navigator.pop(context, newItem);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: AppColors.darkSurface,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.m),
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
        borderSide: const BorderSide(color: AppColors.tetRed),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
