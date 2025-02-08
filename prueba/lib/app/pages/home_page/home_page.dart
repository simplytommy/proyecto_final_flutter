import 'package:flutter/material.dart';
import 'package:prueba/app/api/discogs_api.dart';
import 'package:prueba/app/database/hive_db.dart';
import 'package:prueba/app/models/disk_model.dart';
import 'package:prueba/app/pages/detail_page/detail_page.dart';
import 'package:prueba/app/widgets/menu_lateral.dart';
import 'dart:async';

/// Página de inicio de la aplicación que muestra novedades y discos recientes.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DiscogsAPI _discogsAPI = DiscogsAPI();
  List<DiskModel> _novelties = [];
  List<DiskModel> _recentDisks = [];
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadRecentDisks();
    _fetchNovelties();
    _startAutoScroll();
  }

  /// Carga los últimos discos añadidos desde la base de datos.
  Future<void> _loadRecentDisks() async {
    final allDisks = await HiveDB.getAllDisks();
    setState(() {
      _recentDisks = allDisks.reversed.take(5).toList(); // Últimos 5 discos añadidos
    });
  }

  /// Obtiene las novedades musicales del año actual desde la API de Discogs.
  Future<void> _fetchNovelties() async {
    int currentYear = DateTime.now().year;
    try {
      final data = await _discogsAPI.search(
        "year:$currentYear", // 🔹 Busca discos del año actual
        page: 1,
        limit: 10,
      );

      setState(() {
        _novelties = data['results']
            .where((item) => item.containsKey('year') && item['year'] != null)
            .map<DiskModel>((item) {
          // Extraemos artista y título del formato "Artista - Título"
          final Map<String, String> artistAndTitle = _extractArtistAndTitle(item['title']);

          return DiskModel(
            releaseId: item['id'],
            title: artistAndTitle['title'] ?? 'Desconocido',
            artist: artistAndTitle['artist'] ?? 'Desconocido',
            year: int.tryParse(item['year'].toString()) ?? currentYear,
            genres: List<String>.from(item['genre'] ?? []),
            styles: List<String>.from(item['style'] ?? []),
            coverUrl: (item['cover_image'] != null && item['cover_image'].isNotEmpty)
                ? item['cover_image']
                : 'assets/images/portada.png',
            tracklist: [],
          );
        }).toList();
      });
    } catch (e) {
      _showErrorSnackBar(e); // Muestra un SnackBar con el error en lugar de imprimirlo
    }
  }

  /// Inicia el desplazamiento automático del slideshow de novedades.
  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_pageController.hasClients) {
        _pageController
            .nextPage(
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        )
            .then((_) {
          if (_currentPage == _novelties.length - 1) {
            _pageController.jumpToPage(0);
          }
        });
      }
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Inicio",
          style: TextStyle(
            fontFamily: 'Weigl',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: const MenuLateral(),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage("assets/images/fondo.png"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              const Color.fromARGB(150, 0, 0, 0),
              BlendMode.darken,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSlideshow(),
            const Padding(
              padding: EdgeInsets.all(14.0),
              child: Text(
                "Últimos discos añadidos",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Weigl',
                  color: Colors.white,
                ),
              ),
            ),
            _buildRecentDisks(),
          ],
        ),
      ),
    );
  }

  /// Construye un slideshow con los discos más recientes.
  Widget _buildSlideshow() {
    return SizedBox(
      height: 300,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _novelties.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) => _buildSlideshowItem(context, index),
      ),
    );
  }

  /// Actualiza la página actual cuando se cambia en el slideshow.
  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  /// Construye un elemento individual dentro del slideshow.
  Widget _buildSlideshowItem(BuildContext context, int index) {
    final disk = _novelties[index];
    return GestureDetector(
      onTap: () => _navigateToDetail(context, disk.releaseId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        margin: EdgeInsets.symmetric(horizontal: _currentPage == index ? 5 : 10),
        decoration: _buildBoxDecoration(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(disk.coverUrl, fit: BoxFit.cover),
              _buildTextOverlay(disk),
            ],
          ),
        ),
      ),
    );
  }

  /// Navega a la página de detalles del disco seleccionado.
  void _navigateToDetail(BuildContext context, int releaseId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(releaseId: releaseId),
      ),
    );
  }

  /// Crea la decoración para el contenedor animado de cada disco.
  BoxDecoration _buildBoxDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 5,
          spreadRadius: 2,
        ),
      ],
    );
  }

  /// Construye la superposición de texto con el título y el artista.
  Widget _buildTextOverlay(disk) {
    return Positioned(
      bottom: 8,
      left: 8,
      right: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildText(disk.title, 20, FontWeight.bold),
          _buildText(disk.artist, 18, FontWeight.normal),
        ],
      ),
    );
  }

  /// Construye un texto con estilo dentro del slideshow.
  Widget _buildText(String text, double size, FontWeight weight) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        fontWeight: weight,
        color: Colors.white,
        backgroundColor: Colors.black54,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Construye la lista de los discos más recientes en la colección.
  Widget _buildRecentDisks() {
    return Expanded(
      child: _recentDisks.isEmpty
          ? const Center(
              child: Text("No hay discos en la colección", style: TextStyle(color: Colors.white)))
          : ListView.builder(
              itemCount: _recentDisks.length,
              itemBuilder: (context, index) {
                final disk = _recentDisks[index];
                return ListTile(
                  leading: Image.network(disk.coverUrl, width: 60, height: 60, fit: BoxFit.cover),
                  title: Text(
                    disk.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    disk.artist,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(diskModel: disk),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  /// Extrae el artista y el título del nombre del disco.
  Map<String, String> _extractArtistAndTitle(String? title) {
    if (title != null && title.contains(' - ')) {
      final parts = title.split(' - ');
      return {
        'artist': parts[0].trim(),
        'title': parts.sublist(1).join(' - ').trim(),
      };
    }
    return {'artist': 'Desconocido', 'title': title ?? 'Título desconocido'};
  }

  /// Muestra un mensaje de error en un SnackBar.
  void _showErrorSnackBar(dynamic e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Error: $e',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}
