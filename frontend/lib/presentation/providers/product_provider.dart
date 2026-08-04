import 'package:flutter/material.dart';
import '../../core/init/service_locator.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/product/get_products_usecase.dart';
import '../../domain/usecases/product/add_product_usecase.dart';

enum ProductState { initial, loading, loaded, error }

class ProductProvider extends ChangeNotifier {
  final GetProductsUseCase _getProductsUseCase = getIt<GetProductsUseCase>();
  final AddProductUseCase _addProductUseCase = getIt<AddProductUseCase>();

  ProductState _state = ProductState.initial;
  List<ProductEntity> _products = [];
  String? _errorMessage;

  ProductState get state => _state;
  List<ProductEntity> get products => _products;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ProductState.loading;

  Future<void> fetchProducts() async {
    _state = ProductState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _getProductsUseCase();
    if (result.isSuccess) {
      _products = result.dataOrNull ?? [];
      _state = ProductState.loaded;
    } else {
      _state = ProductState.error;
      _errorMessage = result.failureOrNull?.message ?? 'Ürünler alınamadı.';
    }
    notifyListeners();
  }

  Future<bool> addProduct({
    required String name,
    required double price,
    required int stock,
    required String description,
    required int categoryId,
  }) async {
    final result = await _addProductUseCase(
      name: name,
      price: price,
      stock: stock,
      description: description,
      categoryId: categoryId,
    );

    if (result.isSuccess) {
      await fetchProducts();
      return true;
    } else {
      _errorMessage = result.failureOrNull?.message ?? 'Ürün eklenemedi.';
      notifyListeners();
      return false;
    }
  }
}
