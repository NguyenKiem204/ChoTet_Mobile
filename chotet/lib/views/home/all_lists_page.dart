import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../themes/design_system.dart';
import '../widgets/molecules/home_list_item.dart';
import '../list_detail/list_detail_page.dart';

class AllListsPage extends StatefulWidget {
  const AllListsPage({super.key});

  @override
  State<AllListsPage> createState() => _AllListsPageState();
}

class _AllListsPageState extends State<AllListsPage> {
  final TextEditingController _searchController = TextEditingController();
  int? _selectedYear;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Tiện ích loại bỏ dấu Tiếng Việt để tìm kiếm thông minh hơn
  String _removeDiacritics(String str) {
    var withDiacritics = 'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ';
    var withoutDiacritics = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyydAAAAAAAAAAAAAAAAAEEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYYD';
    for (int i = 0; i < withDiacritics.length; i++) {
      str = str.replaceAll(withDiacritics[i], withoutDiacritics[i]);
    }
    return str.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);
    
    // Lấy danh sách các năm duy nhất từ dữ liệu hiện có (chỉ lấy các danh sách có ngày)
    final availableYears = viewModel.lists
        .where((l) => l.scheduledDate != null)
        .map((l) => l.scheduledDate!.year)
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    // Lọc danh sách theo Search và Year
    final filteredLists = viewModel.lists.where((list) {
      final matchesYear = _selectedYear == null || (list.scheduledDate?.year == _selectedYear);
      
      final normalizedListName = _removeDiacritics(list.name);
      final normalizedQuery = _removeDiacritics(_searchQuery);
      final matchesSearch = normalizedListName.contains(normalizedQuery);
      
      return matchesYear && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.tetRed,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Tất cả danh sách',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: AppColors.tetRed,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.tetRed.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm tên danh sách...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: const Icon(Icons.search, color: AppColors.tetRed),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                // Year Filter Row
                Row(
                  children: [
                    const Icon(Icons.filter_list, color: AppColors.vibrantGold, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Lọc theo năm:',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int?>(
                            value: _selectedYear,
                            dropdownColor: AppColors.tetRed,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            hint: const Text('Tất cả', style: TextStyle(color: Colors.white70)),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('Tất cả')),
                              ...availableYears.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))),
                            ],
                            onChanged: (val) => setState(() => _selectedYear = val),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // List Section
          Expanded(
            child: filteredLists.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 64, color: AppColors.midGrey.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'Không tìm thấy danh sách nào',
                          style: GoogleFonts.outfit(color: AppColors.midGrey, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    itemCount: filteredLists.length,
                    itemBuilder: (context, index) {
                      final list = filteredLists[index];
                      return Padding(
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
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
