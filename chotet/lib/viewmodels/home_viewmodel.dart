import 'package:flutter/foundation.dart';
import 'package:chotet/domain/entities/shopping_item.dart';
import 'package:chotet/domain/entities/shopping_list.dart';
import 'package:chotet/data/services/shopping_service.dart';
import 'package:chotet/data/dtos/shopping_dtos.dart';
import 'package:chotet/domain/entities/user_short.dart';
import 'package:chotet/viewmodels/auth_viewmodel.dart';

class HomeViewModel extends ChangeNotifier {
  final ShoppingService _shoppingService;
  final AuthViewModel _authViewModel;
  
  List<ShoppingList> _lists = [];
  bool _isLoading = false;
  String? _error;

  List<ShoppingList> get lists => _lists;
  bool get isLoading => _isLoading;
  String? get error => _error;

  HomeViewModel(this._shoppingService, this._authViewModel) {
    if (_authViewModel.isAuthenticated) {
      fetchLists();
    }
  }

  Future<void> fetchLists() async {
    final userId = _authViewModel.user?.id;
    if (userId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dtos = await _shoppingService.getShoppingLists(userId);
      _lists = dtos.map(_mapListDtoToEntity).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  ShoppingList _mapListDtoToEntity(ShoppingListDto dto) {
    return ShoppingList(
      id: dto.id?.toString() ?? '',
      name: dto.name,
      budget: dto.budget ?? 0.0,
      createdAt: dto.createdAt ?? DateTime.now(),
      scheduledDate: dto.scheduledDate,
      imageUrl: dto.imageUrl,
      status: dto.status,
      userId: dto.userId?.toString(),
      sharedUsers: dto.sharedUsers.map((u) => UserShort(
        id: u.id,
        username: u.username,
        firstName: u.firstName,
        lastName: u.lastName,
        avatarUrl: u.avatarUrl,
        imageUrl: u.imageUrl,
      )).toList(),
      items: dto.items.map(_mapItemDtoToEntity).toList(),
    );
  }

  ShoppingItem _mapItemDtoToEntity(ShoppingItemDto dto) {
    return ShoppingItem(
      id: dto.id?.toString() ?? '',
      name: dto.name,
      quantity: dto.quantity,
      unit: dto.unit,
      estimatedPrice: dto.estimatedPrice ?? 0.0,
      actualPrice: dto.actualPrice,
      isPurchased: dto.isPurchased,
      isExtra: dto.isExtra,
      category: dto.category ?? 'Khác',
      imageUrl: dto.imageUrl,
      scheduledDate: dto.scheduledDate,
      purchasedBy: dto.purchasedBy != null ? UserShort(
        id: dto.purchasedBy!.id,
        username: dto.purchasedBy!.username,
        firstName: dto.purchasedBy!.firstName,
        lastName: dto.purchasedBy!.lastName,
        avatarUrl: dto.purchasedBy!.avatarUrl,
        imageUrl: dto.purchasedBy!.imageUrl,
      ) : null,
    );
  }

  Future<void> addNewList(String name, double budget, DateTime scheduledDate, {String? imageUrl}) async {
    final userId = _authViewModel.user?.id;
    if (userId == null) return;

    try {
      final dto = ShoppingListDto(
        name: name,
        budget: budget,
        scheduledDate: scheduledDate,
        imageUrl: imageUrl,
      );
      final newListDto = await _shoppingService.createShoppingList(userId, dto);
      _lists.insert(0, _mapListDtoToEntity(newListDto));
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteList(String id) async {
    final intId = int.tryParse(id);
    if (intId == null) return;

    try {
      await _shoppingService.deleteShoppingList(intId);
      _lists.removeWhere((l) => l.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<ShoppingItem> addItemToList(String listId, String name, double quantity, String unit, double estimatedPrice, String category, {DateTime? scheduledDate}) async {
    final intListId = int.tryParse(listId);
    if (intListId == null) throw Exception('Invalid list ID');

    final dto = ShoppingItemDto(
      name: name,
      quantity: quantity,
      unit: unit,
      estimatedPrice: estimatedPrice,
      category: category,
      scheduledDate: scheduledDate,
    );
    
    final resultDto = await _shoppingService.addItemToList(intListId, dto);
    final newItem = _mapItemDtoToEntity(resultDto);
    
    // Update local state
    final listIndex = _lists.indexWhere((l) => l.id == listId);
    if (listIndex != -1) {
      final list = _lists[listIndex];
      final newItems = List<ShoppingItem>.from(list.items)..insert(0, newItem);
      _lists[listIndex] = list.copyWith(items: newItems);
      notifyListeners();
    }
    
    return newItem;
  }

  Future<void> deleteItemFromList(String listId, String itemId) async {
    final intListId = int.tryParse(listId);
    final intItemId = int.tryParse(itemId);
    if (intListId == null || intItemId == null) return;

    // Optimistically update local state
    final listIndex = _lists.indexWhere((l) => l.id == listId);
    ShoppingList? originalList;
    if (listIndex != -1) {
      originalList = _lists[listIndex];
      final newItems = originalList.items.where((i) => i.id != itemId).toList();
      _lists[listIndex] = originalList.copyWith(items: newItems);
      notifyListeners();
    }

    try {
      await _shoppingService.deleteItem(intListId, intItemId);
    } catch (e) {
      // Revert if API fails
      if (listIndex != -1 && originalList != null) {
        _lists[listIndex] = originalList;
        notifyListeners();
      }
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleItemPurchaseStatus(String itemId) async {
    final item = _findItemById(itemId);
    if (item == null) return;
    await updateItem(itemId, isPurchased: !item.isPurchased);
  }

  Future<void> updateItem(String itemId, {String? name, double? quantity, String? unit, double? estimatedPrice, double? actualPrice, bool? isPurchased, String? category}) async {
    ShoppingList? parentList;
    ShoppingItem? targetItem;

    for (var list in _lists) {
      final item = list.items.where((i) => i.id == itemId).firstOrNull;
      if (item != null) {
        parentList = list;
        targetItem = item;
        break;
      }
    }

    if (parentList == null || targetItem == null) return;

    final intListId = int.tryParse(parentList.id);
    final intItemId = int.tryParse(itemId);
    if (intListId == null || intItemId == null) return;

    try {
      final updatedDto = ShoppingItemDto(
        name: name ?? targetItem.name,
        quantity: quantity ?? targetItem.quantity,
        unit: unit ?? targetItem.unit,
        estimatedPrice: estimatedPrice ?? targetItem.estimatedPrice,
        actualPrice: actualPrice ?? targetItem.actualPrice,
        isPurchased: isPurchased ?? targetItem.isPurchased,
        category: category ?? targetItem.category,
      );
      
      final userId = _authViewModel.user?.id;
      if (userId == null) throw Exception('User not authenticated');

      final resultDto = await _shoppingService.updateItem(intListId, intItemId, updatedDto, userId);
      
      final listIndex = _lists.indexOf(parentList);
      final itemIndex = parentList.items.indexOf(targetItem);
      
      final newItems = List<ShoppingItem>.from(parentList.items);
      newItems[itemIndex] = _mapItemDtoToEntity(resultDto);
      
      _lists[listIndex] = parentList.copyWith(items: newItems);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  ShoppingItem? _findItemById(String itemId) {
    for (var list in _lists) {
      final item = list.items.where((i) => i.id == itemId).firstOrNull;
      if (item != null) return item;
    }
    return null;
  }

  double get totalBudget => _lists.fold(0, (sum, list) => sum + list.budget);
  double get totalEstimated => _lists.fold(0, (sum, list) => sum + list.totalEstimated);
  double get totalActual => _lists.fold(0, (sum, list) => sum + list.totalActual);
  double get totalRemaining => totalBudget - totalActual;

  Map<String, ({double estimated, double actual})> get categoryStats {
    final stats = <String, ({double estimated, double actual})>{};
    for (var list in _lists) {
      for (var item in list.items) {
        final current = stats[item.category] ?? (estimated: 0.0, actual: 0.0);
        stats[item.category] = (
          estimated: current.estimated + (item.estimatedPrice * item.quantity),
          actual: current.actual + (item.isPurchased ? (item.price * item.quantity) : 0.0),
        );
      }
    }
    return stats;
  }

  Map<int, ({String name, int itemsCount, double totalSpent})> get memberStats {
    final stats = <int, ({String name, int itemsCount, double totalSpent})>{};
    
    for (var list in _lists) {
      for (var item in list.items) {
        if (item.isPurchased) {
          final userId = item.purchasedBy?.id ?? -1; // -1 for unknown/legacy
          final userName = item.purchasedBy?.displayName ?? 'Khác';
          
          final current = stats[userId] ?? (name: userName, itemsCount: 0, totalSpent: 0.0);
          stats[userId] = (
            name: userName,
            itemsCount: current.itemsCount + 1,
            totalSpent: current.totalSpent + (item.price * item.quantity),
          );
        }
      }
    }
    return stats;
  }

  Future<void> addListFromTemplate(String templateId, DateTime scheduledDate) async {
    String name = 'Danh sách từ mẫu';
    double budget = 500000;
    String? imageUrl;
    
    if (templateId == 'traditional_tet' || templateId == 'co_cung') {
      name = 'Cỗ cúng giao thừa';
      budget = 1000000;
      imageUrl = 'https://picsum.photos/seed/tet_cung/800/600';
    } else if (templateId == 'fruit_tray' || templateId == 'mam_ngu_qua') {
      name = 'Mâm ngũ quả';
      budget = 300000;
      imageUrl = 'https://picsum.photos/seed/tet_fruit/800/600';
    } else if (templateId == 'decoration') {
      name = 'Trang trí nhà cửa';
      budget = 2000000;
      imageUrl = 'https://picsum.photos/seed/tet_decoration/800/600';
    }

    await addNewList(name, budget, scheduledDate, imageUrl: imageUrl);
  }
}
