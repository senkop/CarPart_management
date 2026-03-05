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
      // ✅ FIX: Pinned sellers should come FIRST (a.isPinned returns true = 1, false = 0)
      sellers.sort((a, b) {
        if (a.isPinned == b.isPinned) return 0;
        return a.isPinned ? -1 : 1; // Pinned items first
      });
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
      // ✅ FIX: Same sorting logic
      updatedSellers.sort((a, b) {
        if (a.isPinned == b.isPinned) return 0;
        return a.isPinned ? -1 : 1;
      });
      emit(SellerLoaded(updatedSellers));
    }
  }

  Future<void> addSeller(Seller seller) async {
    if (state is SellerLoaded) {
      await addSellerUseCase(seller);
      final updatedSellers = await getSellersUseCase();
      // ✅ FIX: Apply sorting after add
      updatedSellers.sort((a, b) {
        if (a.isPinned == b.isPinned) return 0;
        return a.isPinned ? -1 : 1;
      });
      emit(SellerLoaded(updatedSellers));
    }
  }

  Future<void> addCarPartToSeller(String sellerId, CarPart carPart) async {
    if (state is SellerLoaded) {
      await addCarPartUseCase(sellerId, carPart);
      final updatedSellers = await getSellersUseCase();
      // ✅ FIX: Apply sorting after add car part
      updatedSellers.sort((a, b) {
        if (a.isPinned == b.isPinned) return 0;
        return a.isPinned ? -1 : 1;
      });
      emit(SellerLoaded(updatedSellers));
    }
  }

  Future<void> updateCarPart(String sellerId, CarPart carPart) async {
    if (state is SellerLoaded) {
      await updateCarPartUseCase(sellerId, carPart);
      final updatedSellers = await getSellersUseCase();
      // ✅ FIX: Apply sorting after update
      updatedSellers.sort((a, b) {
        if (a.isPinned == b.isPinned) return 0;
        return a.isPinned ? -1 : 1;
      });
      emit(SellerLoaded(updatedSellers));
    }
  }

  Future<void> deleteSeller(String sellerId) async {
    if (state is SellerLoaded) {
      await deleteSellerUseCase(sellerId);
      final updatedSellers = await getSellersUseCase();
      // ✅ FIX: Apply sorting after delete
      updatedSellers.sort((a, b) {
        if (a.isPinned == b.isPinned) return 0;
        return a.isPinned ? -1 : 1;
      });
      emit(SellerLoaded(updatedSellers));
    }
  }

  Future<void> deleteCarPart(String sellerId, String carPartId) async {
    if (state is SellerLoaded) {
      try {
        print('Cubit: Starting delete for car part: $carPartId');
        await deleteCarPartUseCase(sellerId, carPartId);
        print('Cubit: Delete use case completed');

        final updatedSellers = await getSellersUseCase();
        // ✅ FIX: Apply sorting after delete car part
        updatedSellers.sort((a, b) {
          if (a.isPinned == b.isPinned) return 0;
          return a.isPinned ? -1 : 1;
        });

        print(
            'Cubit: Fetched updated sellers, count: ${updatedSellers.length}');

        final seller = updatedSellers.firstWhere((s) => s.id == sellerId);
        print('Cubit: Seller car parts count: ${seller.carParts.length}');
        print(
            'Cubit: Car part IDs: ${seller.carParts.map((cp) => cp.id).toList()}');

        emit(SellerLoaded(updatedSellers));
        print('Cubit: Emitted new state');
      } catch (e) {
        print('Cubit: Error in deleteCarPart: $e');
        emit(SellerError(e.toString()));
      }
    }
  }

  Future<void> updateSeller(Seller seller) async {
    if (state is SellerLoaded) {
      await updateSellerUseCase(seller);
      final updatedSellers = await getSellersUseCase();
      // ✅ FIX: Apply sorting after update seller
      updatedSellers.sort((a, b) {
        if (a.isPinned == b.isPinned) return 0;
        return a.isPinned ? -1 : 1;
      });
      emit(SellerLoaded(updatedSellers));
    }
  }

  Future<void> addPaymentToCarPart(
      String sellerId, String carPartId, Payment payment) async {
    if (state is SellerLoaded) {
      final sellers = (state as SellerLoaded).sellers;
      final seller = sellers.firstWhere((s) => s.id == sellerId);
      final carPart = seller.carParts.firstWhere((cp) => cp.id == carPartId);
      carPart.payments.add(payment);
      await updateSellerUseCase(seller);

      // ✅ FIX: Re-fetch and sort to maintain pin order
      final updatedSellers = await getSellersUseCase();
      updatedSellers.sort((a, b) {
        if (a.isPinned == b.isPinned) return 0;
        return a.isPinned ? -1 : 1;
      });
      emit(SellerLoaded(updatedSellers));
    }
  }

  void sortSellersByAmountOwed() {
    if (state is SellerLoaded) {
      final sellers = (state as SellerLoaded).sellers;
      sellers.sort((a, b) => b.getTotalOwed().compareTo(a.getTotalOwed()));
      emit(SellerLoaded(sellers));
    }
  }

  Future<void> sortCarPartsByAmountOwed(String sellerId) async {
    if (state is SellerLoaded) {
      final sellers = (state as SellerLoaded).sellers;
      final seller = sellers.firstWhere((s) => s.id == sellerId);

      // Debug print before sorting
      print("Before sorting by amount owed:");
      seller.carParts.forEach(
          (carPart) => print("${carPart.name}: ${carPart.amountOwed}"));

      seller.carParts.sort((a, b) => a.amountOwed.compareTo(b.amountOwed));

      // Debug print after sorting
      print("After sorting by amount owed:");
      seller.carParts.forEach(
          (carPart) => print("${carPart.name}: ${carPart.amountOwed}"));

      // Create a new list to trigger UI update
      final updatedSellers =
          sellers.map((s) => s.id == sellerId ? seller : s).toList();
      emit(SellerLoaded(updatedSellers));
    }
  }

  Future<void> sortCarPartsByDate(String sellerId) async {
    if (state is SellerLoaded) {
      final sellers = (state as SellerLoaded).sellers;
      final sellerIndex = sellers.indexWhere((s) => s.id == sellerId);

      if (sellerIndex != -1) {
        final seller = sellers[sellerIndex];
        // Sort car parts by date (newest first)
        seller.carParts.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));

        await updateSellerUseCase(seller);

        final updatedSellers = await getSellersUseCase();
        // ✅ Maintain pin order
        updatedSellers.sort((a, b) {
          if (a.isPinned == b.isPinned) return 0;
          return a.isPinned ? -1 : 1;
        });
        emit(SellerLoaded(updatedSellers));
      }
    }
  }

  Future<void> sortCarPartsByPrice(String sellerId) async {
    if (state is SellerLoaded) {
      final sellers = (state as SellerLoaded).sellers;
      final sellerIndex = sellers.indexWhere((s) => s.id == sellerId);

      if (sellerIndex != -1) {
        final seller = sellers[sellerIndex];
        // Sort car parts by total selling price (highest first)
        seller.carParts.sort((a, b) =>
            b.getTotalSellingPrice().compareTo(a.getTotalSellingPrice()));

        await updateSellerUseCase(seller);

        final updatedSellers = await getSellersUseCase();
        // ✅ Maintain pin order
        updatedSellers.sort((a, b) {
          if (a.isPinned == b.isPinned) return 0;
          return a.isPinned ? -1 : 1;
        });
        emit(SellerLoaded(updatedSellers));
      }
    }
  }

  // ✅ FIXED: Sort by current month's gain
  void sortSellersByGains() {
    if (state is SellerLoaded) {
      final sellers = (state as SellerLoaded).sellers;
      final currentMonth = DateTime.now().month;
      final currentYear = DateTime.now().year;

      sellers.sort((a, b) => b
          .getMonthlyGainForMonth(currentMonth, currentYear)
          .compareTo(a.getMonthlyGainForMonth(currentMonth, currentYear)));

      emit(SellerLoaded(sellers));
    }
  }

  // ✅ OR if you want to sort by TOTAL gain (all time):
  void sortSellersByTotalGains() {
    if (state is SellerLoaded) {
      final sellers = (state as SellerLoaded).sellers;
      sellers.sort(
          (a, b) => b.getTotalActualGain().compareTo(a.getTotalActualGain()));
      emit(SellerLoaded(sellers));
    }
  }
}
