import 'package:dartz/dartz.dart';
import 'package:moneyy/domain/repository/income/income.dart';

class TodaysIncomeUsecase {
  final IncomeRepository repository;

  TodaysIncomeUsecase(this.repository);

  Future<Either<String, double>> call() {
    return repository.fetchTotalIncome();
  }
}
