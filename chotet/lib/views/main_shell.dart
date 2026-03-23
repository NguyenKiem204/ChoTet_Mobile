import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chotet/themes/design_system.dart';
import 'package:chotet/viewmodels/auth_viewmodel.dart';
import 'package:chotet/views/home/home_page.dart';
import 'package:chotet/views/region/region_route_page.dart';
import 'package:chotet/views/comparison/price_comparison_page.dart';
import 'package:chotet/views/budget/budget_detail_page.dart';
import 'package:chotet/views/auth/edit_profile_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const RegionRoutePage(),
    const PriceComparisonPage(),
    const BudgetDetailPage(),
  ];

  void _handleProfileAction() {
    final authViewModel = context.read<AuthViewModel>();
    
    // Auth gate in main.dart ensures we are authenticated here
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (_currentIndex == 0 || _currentIndex == 1) ? null : AppBar(
        title: Text(
          _getTitle(),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: _handleProfileAction,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.tetRed,
        unselectedItemColor: AppColors.midGrey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shopping_basket), label: 'Danh sách'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Lịch trình'),
          BottomNavigationBarItem(icon: Icon(Icons.compare_arrows), label: 'Giá cả'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Thống kê'),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Sắm Tết 2026';
      case 1:
        return 'Lịch trình mua sắm';
      case 2:
        return 'Khảo giá thị trường';
      case 3:
        return 'Thống kê chi tiêu';
      default:
        return 'ChoTet';
    }
  }
}
