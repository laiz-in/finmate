import 'package:equatable/equatable.dart';

abstract class TitleCardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchTitleCardData extends TitleCardEvent {}
