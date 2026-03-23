import 'package:flutter/foundation.dart';
import 'package:chotet/data/services/price_book_service.dart';
import 'package:chotet/data/dtos/price_book_dto.dart';

class PriceLog {
  final String id;
  final String storeName;
  final double price;
  final DateTime recordedAt;

  PriceLog({
    required this.id,
    required this.storeName,
    required this.price,
    required this.recordedAt,
  });
}

class TrackedItem {
  final String id;
  final String name;
  final String unit;
  final String imageUrl;
  final List<PriceLog> priceLogs;

  TrackedItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.imageUrl,
    this.priceLogs = const [],
  });

  double? get lowestPrice {
    if (priceLogs.isEmpty) return null;
    return priceLogs.map((p) => p.price).reduce((a, b) => a < b ? a : b);
  }
}

class ComparisonViewModel extends ChangeNotifier {
  final PriceBookService _priceBookService;
  List<TrackedItem> _items = [];
  bool _isLoading = false;
  String? _error;

  ComparisonViewModel(this._priceBookService) {
    fetchPrices();
  }

  List<TrackedItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPrices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dtos = await _priceBookService.getAllPrices();
      _items = _mapDtosToTrackedItems(dtos);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  List<TrackedItem> _mapDtosToTrackedItems(List<PriceBookDto> dtos) {
    final Map<String, List<PriceBookDto>> grouped = {};
    for (var dto in dtos) {
      grouped.putIfAbsent(dto.itemName, () => []).add(dto);
    }

    return grouped.entries.map((entry) {
      final first = entry.value.first;
      return TrackedItem(
        id: entry.key,
        name: entry.key,
        unit: first.unit,
        imageUrl: first.imageUrl ?? 'https://picsum.photos/seed/groceries/600/600',
        priceLogs: entry.value.map((dto) => PriceLog(
          id: dto.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          storeName: dto.storeName,
          price: dto.price,
          recordedAt: dto.observedAt ?? DateTime.now(),
        )).toList()..sort((a, b) => a.price.compareTo(b.price)),
      );
    }).toList();
  }

  Future<void> addPriceLog(String itemName, String storeName, double price, String unit, {DateTime? observedAt}) async {
    try {
      final dto = PriceBookDto(
        itemName: itemName,
        storeName: storeName,
        price: price,
        unit: unit,
        observedAt: observedAt,
      );
      await _priceBookService.addPriceLog(dto);
      await fetchPrices(); // Refresh data
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void addNewTrackedItem(String name, String unit, {String? imageUrl}) {
    final List<String> defaultImages = [
      'https://picsum.photos/seed/groceries/600/600',
      'https://picsum.photos/seed/market/600/600',
      'https://picsum.photos/seed/food/600/600',
    ];
    
    // Pick a default based on name length for some deterministic variety
    final String defaultImg = defaultImages[name.length % defaultImages.length];
    
    _items.insert(0, TrackedItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      unit: unit,
      imageUrl: imageUrl ?? defaultImg,
    ));
    notifyListeners();
  }

  Future<void> autoAddScanResult(String name, String unit, double price, String storeName) async {
    name = name.trim();
    if (name.isEmpty) return;
    await addPriceLog(name, storeName, price, unit);
  }

  Future<void> deletePriceLog(String id) async {
    try {
      await _priceBookService.deletePriceLog(id);
      await fetchPrices();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTrackedItem(String itemName) async {
    try {
      await _priceBookService.deleteItem(itemName);
      await fetchPrices();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateTrackedItem(String oldName, String newName, String newUnit, {String? imageUrl}) async {
    try {
      await _priceBookService.updateItem(oldName, newName, newUnit, imageUrl);
      await fetchPrices();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updatePriceLog(String id, String itemName, String storeName, double price, String unit) async {
    try {
      final dto = PriceBookDto(
        itemName: itemName,
        storeName: storeName,
        price: price,
        unit: unit,
      );
      await _priceBookService.updatePriceLog(id, dto);
      await fetchPrices();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
