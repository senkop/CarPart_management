import 'package:bloc/bloc.dart';
import 'package:elshaf3y_store/features/seller_feature/data/models/personal_model.dart';
import 'package:elshaf3y_store/features/seller_feature/domain/use_cases/add_personal.dart';
import 'package:elshaf3y_store/features/seller_feature/domain/use_cases/delete_personal.dart';
import 'package:elshaf3y_store/features/seller_feature/domain/use_cases/get_personal.dart';
import 'package:elshaf3y_store/features/seller_feature/domain/use_cases/update_personal.dart';
import 'package:elshaf3y_store/presentation/cubit/personal_state.dart';

class PersonalSpendCubit extends Cubit<PersonalSpendState> {
  final GetPersonalSpendsUseCase getPersonalSpendsUseCase;
  final AddPersonalSpendUseCase addPersonalSpendUseCase;
  final UpdatePersonalSpendUseCase updatePersonalSpendUseCase;
  final DeletePersonalSpendUseCase deletePersonalSpendUseCase;

  PersonalSpendCubit({
    required this.getPersonalSpendsUseCase,
    required this.addPersonalSpendUseCase,
    required this.updatePersonalSpendUseCase,
    required this.deletePersonalSpendUseCase,
  }) : super(PersonalSpendInitial());

  Future<void> loadPersonalSpends() async {
    emit(PersonalSpendLoading());
    try {
      final personalSpends = await getPersonalSpendsUseCase();
      emit(personalSpends.isEmpty ? PersonalSpendEmpty() : PersonalSpendLoaded(personalSpends));
    } catch (e) {
      emit(PersonalSpendError(e.toString()));
    }
  }

  Future<void> addPersonalSpend(PersonalSpend personalSpend) async {
    final currentState = state;
    if (currentState is PersonalSpendLoaded) {
      final updatedPersonalSpends = List<PersonalSpend>.from(currentState.personalSpends)..add(personalSpend);
      await addPersonalSpendUseCase(personalSpend);
      emit(PersonalSpendLoaded(updatedPersonalSpends));
    } else if (currentState is PersonalSpendEmpty) {
      await addPersonalSpendUseCase(personalSpend);
      emit(PersonalSpendLoaded([personalSpend]));
    }
  }

  Future<void> updatePersonalSpend(PersonalSpend personalSpend) async {
    final currentState = state;
    if (currentState is PersonalSpendLoaded) {
      final updatedPersonalSpends = currentState.personalSpends.map((p) => p.id == personalSpend.id ? personalSpend : p).toList();
      await updatePersonalSpendUseCase(personalSpend);
      emit(PersonalSpendLoaded(updatedPersonalSpends));
    }
  }

  Future<void> deletePersonalSpend(String personalSpendId) async {
    final currentState = state;
    if (currentState is PersonalSpendLoaded) {
      final updatedPersonalSpends = currentState.personalSpends.where((p) => p.id != personalSpendId).toList();
      await deletePersonalSpendUseCase(personalSpendId);
      emit(PersonalSpendLoaded(updatedPersonalSpends));
    }
  }

  void sortPersonalSpendsByAmount() {
   if (state is PersonalSpendLoaded) {
      final personalSpends = (state as PersonalSpendLoaded).personalSpends;
      personalSpends.sort((a, b) => b.amount.compareTo(a.amount));
      emit(PersonalSpendLoaded(List.from(personalSpends)));
    }
  }

  void sortPersonalSpendsByDate() {
      if (state is PersonalSpendLoaded) {
      final personalSpends = (state as PersonalSpendLoaded).personalSpends;
      personalSpends.sort((a, b) => b.date.compareTo(a.date));
      emit(PersonalSpendLoaded(List.from(personalSpends)));
    }
  
  }
}