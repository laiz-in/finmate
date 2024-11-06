import 'package:equatable/equatable.dart';

abstract class NetworkEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class NetworkStatusChanged extends NetworkEvent {
  final bool isConnected;

  NetworkStatusChanged(this.isConnected);

  @override
  List<Object> get props => [isConnected];
}
