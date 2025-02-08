import 'package:flutter/material.dart';
import 'package:prueba/app/database/hive_db.dart';
import 'package:prueba/app/models/disk_model.dart';
import 'package:prueba/app/theme/theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:prueba/app/routes/routes.dart';

/// Función principal que inicia la aplicación.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Hive para la persistencia de datos.
  await Hive.initFlutter();

  // Registra los adaptadores de los modelos en Hive.
  Hive.registerAdapter(DiskModelAdapter());
  Hive.registerAdapter(TrackAdapter());

  // Inicializa la base de datos Hive.
  await HiveDB.init();

  // Ejecuta la aplicación.
  runApp(const TheCassette());
}

/// Clase principal de la aplicación.
///
/// Configura el tema, las rutas y el punto de entrada de la app.
class TheCassette extends StatelessWidget {
  const TheCassette({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'The Cassette',
      theme: customTheme,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
