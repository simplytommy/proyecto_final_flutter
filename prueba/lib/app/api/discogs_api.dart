import 'dart:convert';
import 'package:http/http.dart' as http;

class DiscogsAPI {
  static const String baseUrl = "https://api.discogs.com";
  static const String consumerKey = "eCqmihLbePOSNTphmPVY";
  static const String consumerSecret = "QmiKeklGUTJmcoDsvvLTWOoANYIwvBav";

  /// 🔍 Realiza una búsqueda en la API de Discogs
  Future<Map<String, dynamic>> search(String query, {int limit = 10, int page = 1}) async {
    final url = Uri.parse(
      '$baseUrl/database/search?q=$query&per_page=$limit&page=$page&key=$consumerKey&secret=$consumerSecret&type=master',
    );

    try {
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception("⏳ Tiempo de espera excedido al contactar con la API.");
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception("🔑 Error de autenticación: Verifica tus credenciales de API.");
      } else if (response.statusCode == 404) {
        throw Exception("❌ Recurso no encontrado: La URL solicitada no existe.");
      } else {
        throw Exception("⚠️ Error desconocido: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      throw Exception("🚨 Error durante la comunicación con la API: $e");
    }
  }

  /// 🔍 Obtiene detalles de un disco en Discogs
  Future<Map<String, dynamic>> getReleaseDetails(int releaseId) async {
    final url = Uri.parse(
      '$baseUrl/masters/$releaseId?key=$consumerKey&secret=$consumerSecret',
    );

    try {
      final response = await http.get(url).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("❌ Error al obtener detalles: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("🚨 Error de conexión: $e");
    }
  }

  /// 🆕 Obtiene las novedades de este año en Discogs
  Future<Map<String, dynamic>> fetchNovelties(int year, {int limit = 10}) async {
    final url = Uri.parse(
      '$baseUrl/database/search?year=$year&type=release&format=album&sort=year&sort_order=desc&per_page=$limit&page=1&key=$consumerKey&secret=$consumerSecret',
    );

    try {
      final response = await http.get(url).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("🔍 Novedades obtenidas para $year: ${data['results'].length} discos.");
        return data;
      } else {
        throw Exception("⚠️ Error al obtener novedades: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("🚨 Error de conexión al obtener novedades: $e");
    }
  }
}
