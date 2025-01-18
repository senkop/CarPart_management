import 'package:elshaf3y_store/features/seller_feature/data/models/personal_model.dart';

import '../repositories/personal_repo.dart';

class UpdatePersonalSpendUseCase {
  final PersonalSpendRepository repository;

  UpdatePersonalSpendUseCase(this.repository);

  Future<void> call(PersonalSpend personalSpend) async {
    await repository.updatePersonalSpend(personalSpend);
  }
}