import 'package:flutter/material.dart';
import '../../../../themes/design_system.dart';

class TemplateBottomSheet extends StatefulWidget {
  final Function(String templateId, DateTime scheduledDate) onSelectTemplate;

  const TemplateBottomSheet({super.key, required this.onSelectTemplate});

  @override
  State<TemplateBottomSheet> createState() => _TemplateBottomSheetState();
}

class _TemplateBottomSheetState extends State<TemplateBottomSheet> {
  DateTime _selectedDate = DateTime.now();

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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.l)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Chọn mẫu có sẵn', style: theme.textTheme.headlineMedium),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text('Ngày dự kiến mua', style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          InkWell(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: AppColors.tetRed),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const Text('Thay đổi', style: TextStyle(color: AppColors.tetRed, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          _buildTemplateOption(
            context,
            'mam_ngu_qua',
            'Mâm ngũ quả',
            '5 món • Dự kiến: 300.000đ',
            'https://picsum.photos/seed/tet_fruit/800/600',
          ),
          const SizedBox(height: AppSpacing.s),
          _buildTemplateOption(
            context,
            'co_cung',
            'Cỗ cúng giao thừa',
            '5 món • Dự kiến: 1.000.000đ',
            'https://picsum.photos/seed/tet_cung/800/600',
          ),
          const SizedBox(height: AppSpacing.s),
          _buildTemplateOption(
            context,
            'decoration',
            'Trang trí nhà cửa',
            '10 món • Dự kiến: 2.000.000đ',
            'https://picsum.photos/seed/tet_decoration/800/600',
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildTemplateOption(BuildContext context, String id, String title, String subtitle, String imageUrl) {
    return ListTile(
      leading: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.s),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.m),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      onTap: () {
        widget.onSelectTemplate(id, _selectedDate);
        Navigator.of(context).pop();
      },
    );
  }
}
