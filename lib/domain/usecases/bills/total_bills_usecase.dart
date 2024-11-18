import 'package:dartz/dartz.dart';
import 'package:moneyy/domain/entities/bills/bills.dart';
import 'package:moneyy/domain/repository/bills/bills.dart';

class TotalBillsUsecase {
  final BillsRepository repository;

  TotalBillsUsecase(this.repository);

  Future<Either<String, List<BillsEntity>>> call({required int page,required int pageSize}) {
    return repository.fetchAllBills(page, pageSize);
  }
}
