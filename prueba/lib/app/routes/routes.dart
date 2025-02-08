import 'package:flutter/material.dart';
import 'package:prueba/app/pages/home_page/home_page.dart';
import 'package:prueba/app/pages/detail_page/detail_page.dart';
import 'package:prueba/app/pages/collection_page/collection_page.dart';
import 'package:prueba/app/pages/search_page/search_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String detail = '/detail';
  static const String collection = '/collection';
  static const String search = '/search';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case detail:
        return MaterialPageRoute(builder: (_) => const DetailPage());
      case collection:
        return MaterialPageRoute(builder: (_) => const CollectionPage());
      case search:
        return MaterialPageRoute(builder: (_) => const SearchPage());
      default:
        return MaterialPageRoute(builder: (_) => const HomePage());
    }
  }
}
