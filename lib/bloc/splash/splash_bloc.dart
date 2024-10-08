import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'splash.dart';
part 'splash_event.dart';

class SplahBloc extends Bloc<SplahEvent, SplahState> {
  SplahBloc() : super(SplahInitial()) {
    on<SplahEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
