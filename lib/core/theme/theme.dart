// import 'package:flutter/material.dart';
// import 'package:testik2/core/theme/colors.dart';
//
// class AppTheme{
//
//   static _border ([Color color = Palete.greyColor]) => OutlineInputBorder(
//     borderSide: BorderSide(
//       color: color,
//       width: 2,
//     ),
//     borderRadius: BorderRadius.circular(15),
//   );
//
//   static final darkThemeMode = ThemeData.light().copyWith(
//     scaffoldBackgroundColor: Palete.background,
//     appBarTheme: AppBarTheme(
//       backgroundColor: Palete.background,
//     ),
//     inputDecorationTheme: InputDecorationTheme(
//       contentPadding: const EdgeInsets.all(20),
//       enabledBorder: _border(),
//       focusedBorder: _border(Palete.primaryOrange),
//     )
//   );
// }

import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}
