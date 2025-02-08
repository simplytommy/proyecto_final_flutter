import 'package:flutter/material.dart';

final ThemeData customTheme = ThemeData.dark().copyWith(
  primaryColor: const Color.fromARGB(255, 0, 0, 0),
  appBarTheme: const AppBarTheme(
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  snackBarTheme: const SnackBarThemeData(
    contentTextStyle: TextStyle(color: Colors.white),
  ),
);
