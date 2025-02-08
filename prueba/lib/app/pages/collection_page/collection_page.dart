import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:prueba/app/database/hive_db.dart';
import 'package:prueba/app/models/disk_model.dart';
import 'package:prueba/app/widgets/menu_lateral.dart';
import 'package:prueba/app/pages/detail_page/detail_page.dart';

/// Página que muestra la colección de discos almacenados por el usuario.
class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  CollectionPageState createState() => CollectionPageState();
}

class CollectionPageState extends State<CollectionPage> {
  late Box<DiskModel> _box;
  List<DiskModel> _filteredDisks = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _box = HiveDB.getBox();
    _filteredDisks = _box.values.toList();
  }

  /// Actualiza la lista de discos filtrados según la consulta de búsqueda.
  void _updateSearchResults(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredDisks = _box.values
          .where((disk) =>
              disk.title.toLowerCase().contains(_searchQuery) ||
              disk.artist.toLowerCase().contains(_searchQuery))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Colección',
            style: TextStyle(fontFamily: 'Weigl', fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
      ),
      drawer: const MenuLateral(),
      body: Column(
        children: [
          _buildSearchField(),
          Expanded(child: _buildCollectionView()),
        ],
      ),
    );
  }

  /// Construye la barra de búsqueda para filtrar los discos en la colección.
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        style: const TextStyle(color: Colors.black, fontSize: 16),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: 'Buscar en mi colección',
          labelStyle: const TextStyle(color: Colors.black, fontSize: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          suffixIcon: const Icon(Icons.search, color: Colors.black),
        ),
        onChanged: _updateSearchResults,
      ),
    );
  }

  /// Construye la vista principal de la colección con el fondo y la lista de discos.
  Widget _buildCollectionView() {
    return Container(
      decoration: _backgroundDecoration(),
      child: ValueListenableBuilder(
        valueListenable: _box.listenable(),
        builder: (context, Box<DiskModel> box, _) {
          return _filteredDisks.isEmpty
              ? const Center(
                  child: Text("No tienes discos en tu colección.",
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                )
              : _buildGridView();
        },
      ),
    );
  }

  /// Genera una cuadrícula de discos basada en la colección filtrada.
  Widget _buildGridView() {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 4 : 2;

    return GridView.builder(
      padding: EdgeInsets.all(screenWidth * 0.03),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: screenWidth * 0.03,
        mainAxisSpacing: screenWidth * 0.03,
        childAspectRatio: 0.75,
      ),
      itemCount: _filteredDisks.length,
      itemBuilder: (context, index) {
        return _buildDiskTile(_filteredDisks[index]);
      },
    );
  }

  /// Representa una tarjeta individual de un disco en la cuadrícula.
  Widget _buildDiskTile(DiskModel disk) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DetailPage(diskModel: disk)),
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
        child: Stack(
          children: [
            _buildImage(disk.coverUrl),
            _buildDeleteButton(disk.releaseId),
            _buildTextOverlay(disk.title, disk.artist),
          ],
        ),
      ),
    );
  }

  /// Carga y muestra la imagen de la portada del disco.
  Widget _buildImage(String? coverUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        coverUrl != null && coverUrl.isNotEmpty ? coverUrl : 'assets/images/portada.png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: 165,
        errorBuilder: (_, __, ___) => Image.asset('assets/images/portada.png', fit: BoxFit.cover),
      ),
    );
  }

  /// Muestra el título y el artista del disco sobre la imagen.
  Widget _buildTextOverlay(String title, String artist) {
    return Positioned(
      bottom: 8,
      left: 8,
      right: 8,
      child: Column(
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(artist,
              style: const TextStyle(color: Colors.grey, fontSize: 15),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  /// Crea un botón para eliminar un disco de la colección.
  Widget _buildDeleteButton(int releaseId) {
    return Positioned(
      top: 4,
      right: 4,
      child: IconButton(
        icon: const Icon(Icons.delete, size: 30, color: Colors.white),
        onPressed: () => _deleteDisk(releaseId),
      ),
    );
  }

  /// Elimina un disco de la base de datos y actualiza la UI.
  void _deleteDisk(int releaseId) {
    setState(() {
      _box.delete(releaseId);
      _updateSearchResults(_searchQuery);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Disco eliminado de la colección',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Color.fromARGB(255, 37, 37, 37),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Define el fondo de la vista de la colección.
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
