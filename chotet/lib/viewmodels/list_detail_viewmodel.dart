import 'package:flutter/foundation.dart';
import 'package:chotet/domain/entities/shopping_item.dart';
import 'package:chotet/domain/entities/shopping_list.dart';
import 'package:chotet/viewmodels/home_viewmodel.dart';
import 'package:chotet/viewmodels/comparison_viewmodel.dart';
import 'package:chotet/data/services/shopping_service.dart';
import 'package:chotet/utils/error_utils.dart';

enum ItemFilter { all, pending, purchased }

class ListDetailViewModel extends ChangeNotifier {
  final HomeViewModel _homeViewModel;
  final ShoppingService _shoppingService;
  final String _listId;
  ItemFilter _currentFilter = ItemFilter.all;
  bool _isLoading = false;
  String? _error;
  
  ShoppingList get list => _homeViewModel.lists.firstWhere((l) => l.id == _listId, orElse: () => ShoppingList.empty());
  ItemFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  ListDetailViewModel(this._listId, this._homeViewModel, this._shoppingService) {
    _homeViewModel.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _homeViewModel.removeListener(notifyListeners);
    super.dispose();
  }

  void setFilter(ItemFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  Future<void> toggleItemPurchase(String itemId) async {
    try {
      await _homeViewModel.toggleItemPurchaseStatus(itemId);
      notifyListeners();
    } catch (e) {
      _error = ErrorUtils.getErrorMessage(e);
      notifyListeners();
    }
  }

  Future<void> addItem(String name, double quantity, String unit, double estimatedPrice, String category, {DateTime? scheduledDate}) async {
    try {
      await _homeViewModel.addItemToList(_listId, name, quantity, unit, estimatedPrice, category, scheduledDate: scheduledDate);
      notifyListeners();
    } catch (e) {
      _error = ErrorUtils.getErrorMessage(e);
      notifyListeners();
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      // Don't await here so notifyListeners happens immediately (optimistic)
      // HomeViewModel.deleteItemFromList already does its own optimistic update
      _homeViewModel.deleteItemFromList(_listId, itemId);
      notifyListeners();
    } catch (e) {
      _error = ErrorUtils.getErrorMessage(e);
      notifyListeners();
    }
  }

  Future<void> updateItemPrice(String itemId, double actualPrice) async {
    try {
      await _homeViewModel.updateItem(itemId, actualPrice: actualPrice, isPurchased: true);
      notifyListeners();
    } catch (e) {
      _error = ErrorUtils.getErrorMessage(e);
      notifyListeners();
    }
  }

  List<ShoppingItem> getFilteredItems() {
    switch (_currentFilter) {
      case ItemFilter.pending: return list.items.where((i) => !i.isPurchased).toList();
      case ItemFilter.purchased: return list.items.where((i) => i.isPurchased).toList();
      case ItemFilter.all: return list.items;
    }
  }

  List<ShoppingItem> getPendingItems() => list.items.where((i) => !i.isPurchased).toList();
  List<ShoppingItem> getPurchasedItems() => list.items.where((i) => i.isPurchased).toList();

  // Real AI Scan logic with Smart Cross-List Matching
  Future<List<Map<String, dynamic>>> scanReceipt(String imagePath, ComparisonViewModel comparisonVM) async {
    _isLoading = true;
    notifyListeners();

    final results = <Map<String, dynamic>>[];

    try {
      final intId = int.tryParse(_listId);
      if (intId == null) throw Exception('Invalid list ID');

      final scanResult = await _shoppingService.scanReceipt(intId, imagePath);

      // Process matched items
      for (var item in scanResult.updatedItems) {
        results.add({
          'name': item.name,
          'status': 'matched',
          'listName': item.listName ?? 'Danh sách khác',
          'isCurrentList': item.listName == list.name,
        });
      }

      // Process extra items
      for (var item in scanResult.extraItems) {
        results.add({
          'name': item.name,
          'status': 'extra',
          'listName': list.name,
        });
      }

      // Track prices in Price Book - RELY ON BACKEND SAVE
      // We just need to refresh the comparison view model to show new prices
      await comparisonVM.fetchPrices();

      // CRITICAL: Refresh HomeViewModel to reflect cross-list changes
      await _homeViewModel.fetchLists();
      
      _isLoading = false;
      notifyListeners();
      return results;
    } catch (e) {
      _isLoading = false;
      _error = ErrorUtils.getErrorMessage(e);
      notifyListeners();
      return [];
    }
  }

  Future<void> shareList(String usernameOrEmail) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final intId = int.tryParse(_listId);
      if (intId == null) throw Exception('Invalid list ID');

      await _shoppingService.shareList(intId, usernameOrEmail);
      await _homeViewModel.fetchLists(); // Refresh to get updated sharedUsers
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = ErrorUtils.getErrorMessage(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> unshareList(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final intId = int.tryParse(_listId);
      if (intId == null) throw Exception('Invalid list ID');

      await _shoppingService.unshareList(intId, userId);
      await _homeViewModel.fetchLists(); // Refresh to get updated sharedUsers
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
