import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:chotet/viewmodels/home_viewmodel.dart';
import 'package:chotet/themes/design_system.dart';
import 'package:chotet/views/widgets/molecules/home_list_item.dart';
import 'package:chotet/views/list_detail/list_detail_page.dart';
import 'package:chotet/views/home/widgets/add_list_dialog.dart';
import 'package:chotet/views/home/widgets/template_bottom_sheet.dart';
import 'package:chotet/viewmodels/auth_viewmodel.dart';
import 'package:chotet/views/auth/edit_profile_page.dart';
import 'package:chotet/views/home/all_lists_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);
    
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.tetRed,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg_auth_header.png'),
              fit: BoxFit.cover,
              opacity: 0.15,
            ),
          ),
        ),
        title: const Text(
          'Sắm Tết 2026',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white, size: 28),
            onPressed: () => _handleProfileAction(context),
          ),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              children: [
                const SizedBox(height: AppSpacing.m),
                _buildTetHeaderBanner(context),
                const SizedBox(height: AppSpacing.m),
                _buildTemplateButton(context, viewModel),
                const SizedBox(height: AppSpacing.xl),
                _buildSectionHeader(context),
                const SizedBox(height: AppSpacing.m),
                ...viewModel.lists.map((list) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.m),
                      child: HomeListItem(
                        list: list,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ListDetailPage(list: list),
                            ),
                          );
                        },
                      ),
                    )),
                const SizedBox(height: 100),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => AddListDialog(
              onAdd: (name, budget, scheduledDate, {imageUrl}) {
                viewModel.addNewList(name, budget, scheduledDate, imageUrl: imageUrl);
              },
            ),
          );
        },
        heroTag: 'home_fab',
        backgroundColor: AppColors.tetRed,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_shopping_cart_rounded, size: 28),
      ),
    );
  }

  Widget _buildTetHeaderBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.tetRed,
        borderRadius: BorderRadius.circular(32),
        image: DecorationImage(
          image: const NetworkImage('https://images.unsplash.com/photo-1674532533401-dc1edac85007?auto=format&fit=crop&q=80&w=800'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(AppColors.tetRed.withValues(alpha: 0.7), BlendMode.multiply),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chào Xuân Bính Ngọ\n2026!',
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.vibrantGold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cùng sắm sửa Tết sung túc nhé!',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.95),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateButton(BuildContext context, HomeViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => TemplateBottomSheet(
              onSelectTemplate: (templateId, scheduledDate) {
                viewModel.addListFromTemplate(templateId, scheduledDate);
              },
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.vibrantGold,
          foregroundColor: AppColors.charcoal,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
          shadowColor: AppColors.vibrantGold.withValues(alpha: 0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.tetRed,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              ' SỬ DỤNG DANH MỤC MẪU TẾT',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.shopping_bag, color: AppColors.tetRed, size: 24),
        const SizedBox(width: 8),
        Text(
          'Danh sách mua sắm',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.charcoal,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AllListsPage()),
            );
          },
          child: Text(
            'Xem tất cả',
            style: GoogleFonts.outfit(
              color: AppColors.tetRed,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _handleProfileAction(BuildContext context) {
    final authViewModel = context.read<AuthViewModel>();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(authViewModel.user?.firstName != null || authViewModel.user?.nickname != null 
                  ? (authViewModel.user?.nickname ?? '${authViewModel.user?.firstName} ${authViewModel.user?.lastName}')
                  : authViewModel.user?.username ?? 'Người dùng'),
              subtitle: Text(authViewModel.user?.email ?? ''),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.tetRed),
              title: const Text('Chỉnh sửa hồ sơ'),
              onTap: () {
                Navigator.pop(context); // Close sheet
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfilePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
              onTap: () {
                authViewModel.logout();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
