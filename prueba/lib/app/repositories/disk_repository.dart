import '../database/hive_db.dart';
import '../models/disk_model.dart';

class DiskRepository {
  Future<void> addDisk(DiskModel disk) async {
    await HiveDB.saveDisk(disk);
  }

  Future<void> removeDisk(int releaseId) async {
    await HiveDB.deleteDisk(releaseId);
  }

  Future<DiskModel?> getDiskById(int releaseId) async {
    return await HiveDB.getDisk(releaseId);
  }

  Future<List<DiskModel>> getAllDisks() async {
    return await HiveDB.getAllDisks();
  }
}
