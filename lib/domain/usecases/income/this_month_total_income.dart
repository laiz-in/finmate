import 'package:dartz/dartz.dart';
import 'package:moneyy/domain/repository/income/income.dart';

class ThisMonthToatalIncomeUseCase {
  final IncomeRepository repository;

  ThisMonthToatalIncomeUseCase(this.repository);

  Future<Either<String, double>> call() {
    return repository.fetchThisMonthIncome();
  }
}
