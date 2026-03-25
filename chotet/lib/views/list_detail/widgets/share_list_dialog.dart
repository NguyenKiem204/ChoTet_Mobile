import 'package:flutter/material.dart';
import 'package:chotet/themes/design_system.dart';
import 'package:chotet/viewmodels/list_detail_viewmodel.dart';
import 'package:chotet/utils/error_utils.dart';

class ShareListDialog extends StatefulWidget {
  final ListDetailViewModel viewModel;
  /// ID của người dùng đang đăng nhập (String vì ShoppingList.userId là String?)
  final String? currentUserId;

  const ShareListDialog({
    super.key,
    required this.viewModel,
    this.currentUserId,
  });

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
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final list = widget.viewModel.list;
    final sharedUsers = list.sharedUsers;

    // Chỉ owner mới có quyền kick thành viên
    final isOwner = list.isOwner(widget.currentUserId);

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
          // Chỉ owner mới thấy ô mời
          if (isOwner) ...[
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
          ] else ...[
            // Member chỉ xem, không mời được
            Container(
              padding: const EdgeInsets.all(AppSpacing.s),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.m),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppColors.midGrey),
                  const SizedBox(width: AppSpacing.s),
                  Text(
                    'Chỉ chủ danh sách mới có thể mời thêm thành viên.',
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.midGrey),
                  ),
                ],
              ),
            ),
          ],
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
                // Không cho kick chính owner (phòng trường hợp backend trả về cả owner)
                final isThisUserOwner = user.id.toString() == list.userId;
                final canKick = isOwner && !isThisUserOwner;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.tetGold.withValues(alpha: 0.2),
                    backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                    child: user.avatarUrl == null ? Text(user.username[0].toUpperCase()) : null,
                  ),
                  title: Row(
                    children: [
                      Text(user.displayName),
                      if (isThisUserOwner) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.tetRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Chủ',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.tetRed,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(user.username),
                  trailing: canKick
                      ? IconButton(
                          icon: const Icon(Icons.person_remove, color: AppColors.danger),
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              await widget.viewModel.unshareList(user.id);
                            } catch (e) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('Lỗi: ${ErrorUtils.getErrorMessage(e)}'),
                                  backgroundColor: AppColors.danger,
                                ),
                              );
                            }
                          },
                        )
                      : null,
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
