import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:prueba/app/api/discogs_api.dart';
import 'package:prueba/app/models/disk_model.dart';
import 'package:prueba/app/database/hive_db.dart';
import 'package:prueba/app/widgets/menu_lateral.dart';
import 'package:prueba/app/pages/search_page/search_page_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final DiscogsAPI _discogsAPI = DiscogsAPI();
  final ScrollController _scrollController = ScrollController();

  List<dynamic> _results = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;

  int _currentPage = 1;
  int _totalPages = 1;
  String _lastQuery = ''; // Almacena el término de búsqueda actual

  @override
  void initState() {
    super.initState();
    // Agregar listener para detectar cuando se acerque al final de la lista
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // Listener para el scroll: carga más resultados cuando se acerca al final
  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _currentPage < _totalPages) {
        _loadMore();
      }
    }
  }

  /// Realiza una búsqueda nueva o recarga la página actual.
  Future<void> _search() async {
    String query = _controller.text.trim();
    if (query.isEmpty) return;

    // Si es una búsqueda nueva, reiniciamos la paginación y resultados.
    if (query != _lastQuery) {
      _currentPage = 1;
      _results.clear();
      _lastQuery = query;
    }

    setState(() => _isLoading = true);
    try {
      final data = await _discogsAPI.search(
        query,
        page: _currentPage,
        limit: 30,
      );

      // Obtener información de paginación de la respuesta
      final pagination = data['pagination'];
      if (pagination != null) {
        _totalPages = pagination['pages'] ?? 1;
      }

      // Los nuevos resultados se agregan o asignan según la página
      List<dynamic> newResults = data['results'] ?? [];
      setState(() {
        if (_currentPage == 1) {
          _results = newResults;
        } else {
          _results.addAll(newResults);
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar(e);
    }
  }

  /// Carga más resultados (la siguiente página).
  Future<void> _loadMore() async {
    if (_currentPage >= _totalPages) return;
    _currentPage++;
    setState(() => _isLoadingMore = true);
    try {
      final data = await _discogsAPI.search(
        _lastQuery,
        page: _currentPage,
        limit: 30,
      );
      List<dynamic> newResults = data['results'] ?? [];
      setState(() {
        _results.addAll(newResults);
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
      _showErrorSnackbar(e);
    }
  }

  /// Muestra un SnackBar con un mensaje de error.
  void _showErrorSnackbar(dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Error al realizar la búsqueda',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Guarda un álbum en la base de datos Hive.
  Future<void> _saveAlbum(int releaseId) async {
    try {
      setState(() => _isLoading = true);
      final details = await _discogsAPI.getReleaseDetails(releaseId);
      if (!mounted) return;
      final completeDisk = convertirADiskModel(details);

      final existingDisk = await HiveDB.getDisk(completeDisk.releaseId);
      if (existingDisk != null) {
        setState(() => _isLoading = false);
        _showSnackbar('Este disco ya está en tu colección');
        return;
      }

      await HiveDB.saveDisk(completeDisk);
      setState(() => _isLoading = false);
      _showSnackbar('Disco guardado en tu colección');
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar(e);
    }
  }

  /// Muestra un mensaje en un SnackBar.
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Convierte los datos de la API en un objeto DiskModel.
  DiskModel convertirADiskModel(Map<String, dynamic> data) {
    return DiskModel(
      releaseId: data['id'] ?? 0,
      title: data['title'] ?? 'Desconocido',
      artist: data['artists'] != null && data['artists'].isNotEmpty
          ? data['artists'][0]['name'] ?? 'Desconocido'
          : 'Desconocido',
      year: data['year'] ?? 0,
      genres: List<String>.from(data['genres'] ?? []),
      styles: List<String>.from(data['styles'] ?? []),
      coverUrl: data['images'] != null && data['images'].isNotEmpty
          ? data['images'][0]['uri'] ?? 'assets/images/portada.png'
          : 'assets/images/portada.png',
      tracklist: (data['tracklist'] ?? [])
          .map<Track>((track) => Track(
                title: track['title'] ?? 'Sin título',
                duration: track['duration'] ?? 'Desconocido',
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buscar discos',
          style: TextStyle(fontFamily: 'Weigl', fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: const MenuLateral(),
      body: Column(
        children: [
          _buildSearchField(),
          Expanded(child: _buildResultsView()),
        ],
      ),
    );
  }

  /// Construye el campo de búsqueda.
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _controller, // Asignamos el controlador aquí
        style: const TextStyle(color: Colors.black, fontSize: 16),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: 'Buscar artista o álbum',
          labelStyle: const TextStyle(color: Colors.black, fontSize: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: _search,
          ),
        ),
        onSubmitted: (_) => _search(),
      ),
    );
  }

  /// Construye la vista de resultados de búsqueda.
  Widget _buildResultsView() {
    return Container(
      decoration: _backgroundDecoration(),
      child: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildResultsGrid(),
    );
  }

  /// Construye la cuadrícula de resultados de búsqueda.
  Widget _buildResultsGrid() {
    return GridView.builder(
      controller: _scrollController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.9,
      ),
      itemCount: _results.length + 1,
      itemBuilder: (context, index) {
        if (index < _results.length) {
          return SearchPageCard(
            result: _results[index],
            imageHeight: MediaQuery.of(context).size.height * 0.16,
            onSave: () => _saveAlbum(_results[index]['id']),
          );
        } else {
          return _isLoadingMore
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox.shrink();
        }
      },
    );
  }

  /// Define el fondo de la vista de resultados.
  BoxDecoration _backgroundDecoration() {
    return const BoxDecoration(
      image: DecorationImage(
        image: AssetImage("assets/images/fondo.png"),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(Color.fromARGB(200, 0, 0, 0), BlendMode.darken),
      ),
    );
  }
}
