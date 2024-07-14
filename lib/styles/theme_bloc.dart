/*

C:\Users\Hp\Desktop\moneyy\moneyy\lib\styles\theme_bloc.dart

*/

import 'package:bloc/bloc.dart';

import 'theme_event.dart';
import 'theme_state.dart';
import 'themes.dart';

class ThemeBloc extends Bloc<ToggleThemeEvent, ThemeState> {
  bool isDarkMode = false;

  ThemeBloc() : super(ThemeState(themeData: lightTheme)) {
    on<ToggleThemeEvent>((event, emit) {
      if (isDarkMode) {
        emit(ThemeState(themeData: lightTheme));
      } else {
        emit(ThemeState(themeData: darkTheme));
      }
      isDarkMode = !isDarkMode;
    });
  }
}
