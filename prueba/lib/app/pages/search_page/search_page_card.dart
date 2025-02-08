import 'package:flutter/material.dart';
import 'package:prueba/app/pages/detail_page/detail_page.dart';

class SearchPageCard extends StatelessWidget {
  final dynamic result;
  final double imageHeight;
  final VoidCallback onSave;

  const SearchPageCard({
    super.key,
    required this.result,
    required this.imageHeight,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    String albumTitle = _getAlbumTitle();
    String artist = _getArtistName();
    double screenWidth = MediaQuery.of(context).size.width;
    double imageWidth = screenWidth * 0.45;

    return GestureDetector(
      onTap: () => _navigateToDetailPage(context),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
        child: Stack(
          children: [
            _buildImage(imageWidth),
            _buildSaveButton(),
            Positioned(bottom: 8, left: 8, right: 8, child: _buildText(albumTitle, artist)),
          ],
        ),
      ),
    );
  }

  /// Navega a la página de detalles del álbum seleccionado.
  void _navigateToDetailPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(releaseId: result['id']),
      ),
    );
  }

  /// Obtiene el título del álbum desde los datos del resultado.
  String _getAlbumTitle() {
    return result['title']?.split(' - ').last ?? 'Sin título';
  }

  /// Obtiene el nombre del artista desde los datos del resultado.
  String _getArtistName() {
    return result['title']?.split(' - ').first ?? 'Desconocido';
  }

  /// Construye la imagen del álbum con un marcador de posición en caso de error.
  Widget _buildImage(double imageWidth) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: imageWidth,
        height: imageHeight,
        child: Image.network(
          result['thumb'] ?? _getImageUrl(result),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset('assets/images/portada.png', fit: BoxFit.cover),
        ),
      ),
    );
  }

  /// Construye el texto que muestra el título del álbum y el nombre del artista.
  Widget _buildText(String albumTitle, String artist) {
    return Column(
      children: [
        Text(albumTitle,
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
    );
  }

  /// Construye el botón para guardar el álbum en la colección.
  Widget _buildSaveButton() {
    return Positioned(
      top: 4,
      right: 4,
      child: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(color: Color.fromARGB(50, 0, 0, 0), blurRadius: 15, offset: Offset(1, 1)),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.add_box, size: 30, color: Colors.white),
          onPressed: onSave,
        ),
      ),
    );
  }

  /// Obtiene la URL de la imagen del álbum desde los datos del resultado.
  String _getImageUrl(Map<String, dynamic> data) {
    if (data['thumb'] != null && data['thumb'].isNotEmpty) {
      return data['thumb'];
    }
    if (data['images'] != null && data['images'].isNotEmpty) {
      final imageUri = data['images'][0]['uri'];
      if (imageUri != null && imageUri.isNotEmpty) {
        return imageUri;
      }
    }
    return 'assets/images/portada.png';
  }
}
