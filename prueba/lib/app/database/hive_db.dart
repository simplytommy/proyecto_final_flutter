import 'package:hive/hive.dart';
import 'package:prueba/app/models/disk_model.dart';

class HiveDB {
  static late Box<DiskModel> _box;

  // Inicializar la caja cuando sea necesario
  static Future<void> init() async {
    if (!Hive.isBoxOpen('mis_discos')) {
      _box = await Hive.openBox<DiskModel>('mis_discos');
    }
  }

  // Guardar un disco en Hive
  static Future<void> saveDisk(DiskModel disk) async {
    await _box.put(disk.releaseId, disk); // Utiliza el releaseId como clave
  }

  // Obtener un disco por su releaseId
  static Future<DiskModel?> getDisk(int releaseId) async {
    return _box.get(releaseId);
  }

  // Obtener todos los discos
  static Future<List<DiskModel>> getAllDisks() async {
    return _box.values.toList().cast<DiskModel>();
  }

  // Eliminar un disco por su releaseId
  static Future<void> deleteDisk(int releaseId) async {
    await _box.delete(releaseId);
  }

  static Box<DiskModel> getBox() {
    return _box;
  }
}
