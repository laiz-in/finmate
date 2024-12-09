import 'package:dartz/dartz.dart';
import 'package:moneyy/domain/entities/income/income.dart';
import 'package:moneyy/domain/repository/income/income.dart';

class TotalIncomeUseCase {
  final IncomeRepository repository;

  TotalIncomeUseCase(this.repository);

  Future<Either<String, List<IncomeEntity>>> call({required int page,required int pageSize}) {
    return repository.fetchAllIncome(page, pageSize);
  }
}
