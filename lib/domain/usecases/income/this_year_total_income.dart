import 'package:dartz/dartz.dart';
import 'package:moneyy/domain/repository/income/income.dart';

class ThisYearToatalIncomeUseCase {
  final IncomeRepository repository;

  ThisYearToatalIncomeUseCase(this.repository);

  Future<Either<String, double>> call() {
    return repository.fetchThisYearIncome();
  }
}