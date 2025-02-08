import 'package:flutter/material.dart';
import 'package:prueba/app/api/discogs_api.dart';
import 'package:prueba/app/database/hive_db.dart';
import 'package:prueba/app/models/disk_model.dart';

class DetailPage extends StatefulWidget {
  final int? releaseId;
  final DiskModel? diskModel;

  const DetailPage({super.key, this.releaseId, this.diskModel});

  @override
  DetailPageState createState() => DetailPageState();
}

/// Estado de la página de detalles del disco.
class DetailPageState extends State<DetailPage> {
  final DiscogsAPI _discogsAPI = DiscogsAPI();
  Map<String, dynamic>? _releaseDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.diskModel != null) {
      _setDiskDetails(widget.diskModel!);
    } else if (widget.releaseId != null) {
      _fetchReleaseDetails();
    } else {
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _releaseDetails == null
              ? const Center(child: Text("No se pudo cargar la información."))
              : _buildDetailContent(),
    );
  }

  /// Establece los detalles del disco a partir de un objeto DiskModel.
  void _setDiskDetails(DiskModel disk) {
    setState(() {
      _releaseDetails = {
        'id': disk.releaseId,
        'title': disk.title,
        'artists': [
          {'name': disk.artist}
        ],
        'year': disk.year,
        'genres': disk.genres,
        'styles': disk.styles,
        'images': [
          {'uri': disk.coverUrl}
        ],
        'tracklist': disk.tracklist
            .map((track) => {'title': track.title, 'duration': track.duration})
            .toList(),
      };
      _isLoading = false;
    });
  }

  /// Obtiene los detalles de un disco desde la API de Discogs.
  Future<void> _fetchReleaseDetails() async {
    try {
      final details = await _discogsAPI.getReleaseDetails(widget.releaseId!);
      if (!mounted) return;
      final diskModel = convertirADiskModel(details);
      _setDiskDetails(diskModel);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar(e);
    }
  }

  /// Convierte un mapa de datos en un objeto DiskModel.
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
          ? data['images'][0]['uri'] ?? 'https://via.placeholder.com/300'
          : 'https://via.placeholder.com/300',
      tracklist: (data['tracklist'] ?? [])
          .map<Track>((track) => Track(
                title: track['title'] ?? 'Sin título',
                duration: track['duration'] ?? 'Desconocido',
              ))
          .toList(),
    );
  }

  /// Muestra un mensaje de error en un SnackBar.
  void _showErrorSnackBar(dynamic e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Error: $e',
          style: const TextStyle(color: Colors.black), // Texto en negro
        ),
        backgroundColor: Colors.white, // Fondo claro para contraste
      ),
    );
  }

  /// Construye el contenido detallado de la página de detalles del disco.
  Widget _buildDetailContent() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage("assets/images/fondo.png"), // 📌 Fondo de portada
          fit: BoxFit.cover, // La imagen cubre toda la pantalla
          colorFilter: ColorFilter.mode(
            const Color.fromARGB(200, 0, 0, 0), // 🔹 Oscurecimiento sutil para mejorar visibilidad
            BlendMode.darken,
          ),
        ),
      ),
      child: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _releaseDetails?['title'] ?? 'Título desconocido',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // 🔹 Asegura visibilidad sobre la imagen de fondo
                      ),
                    ),
                    Text(
                      "Artista: ${_releaseDetails?['artists'][0]['name'] ?? 'Desconocido'}",
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    Text("Año: ${_releaseDetails?['year'] ?? 'Desconocido'}",
                        style: const TextStyle(color: Colors.white)),
                    Text("Géneros: ${(_releaseDetails?['genres'] ?? []).join(', ')}",
                        style: const TextStyle(color: Colors.white)),
                    Text("Estilos: ${(_releaseDetails?['styles'] ?? []).join(', ')}",
                        style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 16),
                    const Text("Lista de canciones:", style: TextStyle(color: Colors.white)),
                    ...(_releaseDetails?['tracklist'] ?? []).map<Widget>((track) {
                      return ListTile(
                        title: Text(track['title'], style: const TextStyle(color: Colors.white)),
                        subtitle: Text("Duración: ${track['duration']}",
                            style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  /// Construye la barra de aplicación deslizante.
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 350.0,
      pinned: true,
      floating: false,
      leading: _buildIconWithShadow(
        icon: Icons.arrow_back,
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        FutureBuilder<DiskModel?>(
          future: HiveDB.getDisk(_releaseDetails?['id'] ?? 0),
          builder: (context, snapshot) {
            bool isInCollection = snapshot.hasData;

            if (!isInCollection) {
              return _buildIconWithShadow(
                icon: Icons.add_box,
                onPressed: _saveDisk,
              );
            }
            return const SizedBox();
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Image.network(
          _releaseDetails?['images']?[0]?['uri'] ?? 'assets/images/portada.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // Método auxiliar para construir iconos con sombra**
  Widget _buildIconWithShadow({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color.fromARGB(0, 0, 0, 0),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 36),
        onPressed: onPressed,
      ),
    );
  }

  // Método para guardar el disco en la colección
  void _saveDisk() async {
    final completeDisk = convertirADiskModel(_releaseDetails!);

    final existingDisk = await HiveDB.getDisk(completeDisk.releaseId);

    if (!mounted) return;

    if (existingDisk != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este disco ya está en tu colección')),
      );
      return;
    }

    await HiveDB.saveDisk(completeDisk);

    if (!mounted) return;

    // Muestra un mensaje de confirmacion
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Disco eliminado de la colección',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 37, 37, 37),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
