import 'package:dartz/dartz.dart';
import 'package:moneyy/domain/repository/income/income.dart';

class ThisWeekToatalIncomeUseCase {
  final IncomeRepository repository;

  ThisWeekToatalIncomeUseCase(this.repository);

  Future<Either<String, double>> call() {
    return repository.fetchThisWeekIncome();
  }
}
