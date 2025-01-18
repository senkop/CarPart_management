import 'package:elshaf3y_store/features/seller_feature/data/models/personal_model.dart';
import 'package:elshaf3y_store/features/seller_feature/domain/repositories/personal_repo.dart';

class AddPersonalSpendUseCase {
  final PersonalSpendRepository repository;

  AddPersonalSpendUseCase(this.repository);

  Future<void> call(PersonalSpend personalSpend) async {
    final personalSpends = await repository.getPersonalSpends();
    personalSpends.add(personalSpend);
    await repository.savePersonalSpends(personalSpends);
  }
}