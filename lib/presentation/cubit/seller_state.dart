part of 'seller_cubit.dart';

@immutable
abstract class SellerState {}

class SellerInitial extends SellerState {}

class SellerLoading extends SellerState {}

class SellerLoaded extends SellerState {
  final List<Seller> sellers;

  SellerLoaded(this.sellers);
}

class SellerError extends SellerState {
  final String message;

  SellerError(this.message);
} 
class SellerPinUpdated extends SellerState {
  final List<Seller> sellers;

  SellerPinUpdated(this.sellers);
}
class TransactionHistoryLoaded extends SellerState {
  final List<Transaction> transactions;

  TransactionHistoryLoaded(this.transactions);
}
