import 'package:flutter/material.dart';
import 'package:chotet/themes/design_system.dart';
import 'package:chotet/viewmodels/list_detail_viewmodel.dart';
import 'package:chotet/utils/error_utils.dart';

class ShareListDialog extends StatefulWidget {
  final ListDetailViewModel viewModel;

  const ShareListDialog({super.key, required this.viewModel});

  @override
  State<ShareListDialog> createState() => _ShareListDialogState();
}

class _ShareListDialogState extends State<ShareListDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleShare() async {
    if (_controller.text.trim().isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isSubmitting = true);
    try {
      await widget.viewModel.shareList(_controller.text.trim());
      _controller.clear();
      messenger.showSnackBar(
        const SnackBar(content: Text('Đã chia sẻ danh sách thành công!')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Lỗi: ${ErrorUtils.getErrorMessage(e)}'), backgroundColor: AppColors.danger),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sharedUsers = widget.viewModel.list.sharedUsers;

    return Container(
      padding: EdgeInsets.only(
        top: AppSpacing.l,
        left: AppSpacing.l,
        right: AppSpacing.l,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.l,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Chia sẻ danh sách', style: theme.textTheme.headlineMedium),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            'Mời người thân cùng đi chợ bằng cách nhập username hoặc email của họ.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Username hoặc Email',
                    filled: true,
                    fillColor: AppColors.lightGrey.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.m),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _handleShare(),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              if (_isSubmitting)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _handleShare,
                  child: const Text('Mời'),
                ),
            ],
          ),
          if (sharedUsers.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            Text('Đang chia sẻ với', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sharedUsers.length,
              itemBuilder: (_, index) {
                final user = sharedUsers[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.tetGold.withValues(alpha: 0.2),
                    backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                    child: user.avatarUrl == null ? Text(user.username[0].toUpperCase()) : null,
                  ),
                  title: Text(user.displayName),
                  subtitle: Text(user.username),
                  trailing: IconButton(
                    icon: const Icon(Icons.person_remove, color: AppColors.danger),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await widget.viewModel.unshareList(user.id);
                      } catch (e) {
                        messenger.showSnackBar(
                          SnackBar(content: Text('Lỗi: ${ErrorUtils.getErrorMessage(e)}'), backgroundColor: AppColors.danger),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: AppSpacing.m),
        ],
      ),
    );
  }
}
