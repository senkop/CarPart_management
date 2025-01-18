import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:elshaf3y_store/domain/use_cases/delete_car_part_use_case.dart';
import 'package:elshaf3y_store/domain/use_cases/get_sellers_use_case.dart';
import 'package:elshaf3y_store/domain/use_cases/add_seller_use_case.dart';
import 'package:elshaf3y_store/domain/use_cases/add_car_part_use_case.dart';
import 'package:elshaf3y_store/features/car_parts_feature/data/models/car_parts_model.dart';
import 'package:elshaf3y_store/features/seller_feature/data/models/seller_model.dart';
import 'package:elshaf3y_store/domain/use_cases/update_car_part_use_case.dart';
import 'package:elshaf3y_store/domain/use_cases/delete_seller_use_case.dart';
import 'package:elshaf3y_store/domain/use_cases/get_transaction_history_use_case.dart';
import 'package:elshaf3y_store/features/seller_feature/data/models/transaction_model.dart';
import 'package:elshaf3y_store/domain/use_cases/update_seller_use_case.dart';

part 'seller_state.dart';
class SellerCubit extends Cubit<SellerState> {
  final GetSellersUseCase getSellersUseCase;
  final AddSellerUseCase addSellerUseCase;
  final AddCarPartUseCase addCarPartUseCase;
  final UpdateCarPartUseCase updateCarPartUseCase;
  final DeleteSellerUseCase deleteSellerUseCase;
  final GetTransactionHistoryUseCase getTransactionHistoryUseCase;
  final DeleteCarPartUseCase deleteCarPartUseCase;
  final UpdateSellerUseCase updateSellerUseCase;

  SellerCubit({
    required this.getSellersUseCase,
    required this.addSellerUseCase,
    required this.addCarPartUseCase,
    required this.updateCarPartUseCase,
    required this.deleteSellerUseCase,
    required this.getTransactionHistoryUseCase,
    required this.deleteCarPartUseCase,
    required this.updateSellerUseCase,
  }) : super(SellerInitial()) {
    loadSellers(); // Load sellers on initialization
  }

  Future<void> loadSellers() async {
    try {
      emit(SellerLoading());
      final sellers = await getSellersUseCase();
      sellers.sort((a, b) => b.isPinned ? 1 : -1); // Sort sellers by pinned state
      emit(SellerLoaded(sellers));
    } catch (e) {
      emit(SellerError(e.toString()));
    }
  }

  Future<void> togglePinSeller(Seller seller) async {
    if (state is SellerLoaded) {
      seller.isPinned = !seller.isPinned;
      await updateSellerUseCase(seller);
      final updatedSellers = await getSellersUseCase();
      updatedSellers.sort((a, b) => b.isPinned ? 1 : -1); // Sort sellers by pinned state
// Sort sellers by pinned state
      emit(SellerLoaded(updatedSellers));
    }
  }

  Future<void> addSeller(Seller seller) async {
    if (state is SellerLoaded) {
      await addSellerUseCase(seller);
      final updatedSellers = await getSellersUseCase();
      emit(SellerLoaded(updatedSellers));
    }
  }

  Future<void> addCarPartToSeller(String sellerId, CarPart carPart) async {
    if (state is SellerLoaded) {
      await addCarPartUseCase(sellerId, carPart);
      final updatedSellers = await getSellersUseCase();
      emit(SellerLoaded(updatedSellers));
    }
  }

  Future<void> updateCarPart(String sellerId, CarPart carPart) async {
    if (state is SellerLoaded) {
      await updateCarPartUseCase(sellerId, carPart);
      final updatedSellers = await getSellersUseCase();
      emit(SellerLoaded(updatedSellers));
    }
  }

  Future<void> deleteSeller(String sellerId) async {
    if (state is SellerLoaded) {
      await deleteSellerUseCase(sellerId);
      final updatedSellers = await getSellersUseCase();
      emit(SellerLoaded(updatedSellers));
    }
  }

  Future<void> deleteCarPart(String sellerId, String carPartId) async {
    if (state is SellerLoaded) {
      await deleteCarPartUseCase(sellerId, carPartId);
      final updatedSellers = await getSellersUseCase();
      emit(SellerLoaded(updatedSellers));
    }
  }

  Future<void> getTransactionHistory(String sellerId) async {
    try {
      emit(SellerLoading());
      final transactions = await getTransactionHistoryUseCase(sellerId);
      emit(TransactionHistoryLoaded(transactions));
    } catch (e) {
      emit(SellerError(e.toString()));
    }
  }

  Future<void> updateSeller(Seller seller) async {
    if (state is SellerLoaded) {
      await updateSellerUseCase(seller);
      final updatedSellers = await getSellersUseCase();
      emit(SellerLoaded(updatedSellers));
    }
  }
   Future<void> sortCarPartsByDate(String sellerId) async {
    if (state is SellerLoaded) {
      final sellers = (state as SellerLoaded).sellers;
      final seller = sellers.firstWhere((s) => s.id == sellerId);
      seller.carParts.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
      emit(SellerLoaded(sellers));
    }
  }

  Future<void> sortCarPartsByPrice(String sellerId) async {
    if (state is SellerLoaded) {
      final sellers = (state as SellerLoaded).sellers;
      final seller = sellers.firstWhere((s) => s.id == sellerId);
      seller.carParts.sort((a, b) => b.price.compareTo(a.price));
      emit(SellerLoaded(sellers));
    }
  }
  Future<void> sortCarPartsByAmountOwed(String sellerId) async {
  if (state is SellerLoaded) {
    final sellers = (state as SellerLoaded).sellers;
    final seller = sellers.firstWhere((s) => s.id == sellerId);
    seller.carParts.sort((a, b) => b.amountOwed.compareTo(a.amountOwed));
    emit(SellerLoaded(sellers));
  }
}
    Future<void> addPaymentToCarPart(String sellerId, String carPartId, Payment payment) async {
    if (state is SellerLoaded) {
      final sellers = (state as SellerLoaded).sellers;
      final seller = sellers.firstWhere((s) => s.id == sellerId);
      final carPart = seller.carParts.firstWhere((cp) => cp.id == carPartId);
      carPart.payments.add(payment);
      await updateSellerUseCase(seller);
      emit(SellerLoaded(sellers));
    }
  }
}