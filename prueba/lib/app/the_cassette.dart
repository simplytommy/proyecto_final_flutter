import 'package:flutter/material.dart';
import 'package:prueba/app/pages/home_page/home_page.dart';
import 'package:prueba/app/theme/theme.dart';

/// Clase principal de la aplicación
class TheCassette extends StatelessWidget {
  const TheCassette({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'The Cassette',
      theme: customTheme,
      home: const HomePage(),
    );
  }
}
