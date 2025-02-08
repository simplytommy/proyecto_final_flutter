import 'package:flutter/material.dart';
import 'package:prueba/app/pages/home_page/home_page.dart';
import 'package:prueba/app/pages/search_page/search_page.dart';
import 'package:prueba/app/pages/collection_page/collection_page.dart';

class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage("assets/images/portada.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: const Center(
              child: Text(
                'Menú',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'Weigl',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          _buildMenuItem(
            icon: Icons.home,
            text: 'Inicio',
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.album,
            text: 'Mi Colección',
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CollectionPage()),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.search,
            text: 'Búsqueda',
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  // Construye cada opción del menú con un icono y un texto
  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        text,
        style: const TextStyle(
          fontSize: 22,
          fontFamily: 'Weigl',
          color: Colors.white,
        ),
      ),
      onTap: onTap,
    );
  }
}
