import 'package:elshaf3y_store/features/seller_feature/data/models/personal_model.dart';

abstract class PersonalSpendState {}

class PersonalSpendInitial extends PersonalSpendState {}

class PersonalSpendLoading extends PersonalSpendState {}

class PersonalSpendLoaded extends PersonalSpendState {
  final List<PersonalSpend> personalSpends;

  PersonalSpendLoaded(this.personalSpends);
}

class PersonalSpendEmpty extends PersonalSpendState {}

class PersonalSpendError extends PersonalSpendState {
  final String message;

  PersonalSpendError(this.message);
}