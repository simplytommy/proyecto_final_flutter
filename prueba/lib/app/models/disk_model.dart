import 'package:hive/hive.dart';

part 'disk_model.g.dart';

@HiveType(typeId: 0)
class DiskModel extends HiveObject {
  @HiveField(0)
  final int releaseId;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String artist;

  @HiveField(3)
  final int year;

  @HiveField(4)
  final List<String> genres;

  @HiveField(5)
  final List<String> styles;

  @HiveField(6)
  final String coverUrl;

  @HiveField(7)
  final List<Track> tracklist;

  DiskModel({
    required this.releaseId,
    required this.title,
    required this.artist,
    required this.year,
    required this.genres,
    required this.styles,
    required this.coverUrl,
    required this.tracklist,
  });
}

@HiveType(typeId: 1)
class Track extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String duration;

  Track({
    required this.title,
    required this.duration,
  });
}
