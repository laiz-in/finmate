import 'package:dartz/dartz.dart';
import 'package:moneyy/data/models/bills/user_bills.dart';
import 'package:moneyy/domain/repository/bills/bills.dart';

class AddBillUsecase {
  final BillsRepository repository;

  AddBillUsecase(this.repository);

  Future<Either> call({BillModel? params}) {
    return repository.addBill(params!);
  }
}
