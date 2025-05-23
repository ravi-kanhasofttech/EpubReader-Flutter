import 'package:hive/hive.dart';

part 'book_model.g.dart';

@HiveType(typeId: 0)
class BookModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? author;

  @HiveField(3)
  final String filePath;

  @HiveField(4)
  final DateTime lastRead;

  @HiveField(5)
  final double progress;

  @HiveField(6)
  final String? coverPath;

  BookModel({
    required this.id,
    required this.title,
    this.author,
    required this.filePath,
    required this.lastRead,
    this.progress = 0.0,
    this.coverPath,
  });

  BookModel copyWith({
    String? id,
    String? title,
    String? author,
    String? filePath,
    DateTime? lastRead,
    double? progress,
    String? coverPath,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      filePath: filePath ?? this.filePath,
      lastRead: lastRead ?? this.lastRead,
      progress: progress ?? this.progress,
      coverPath: coverPath ?? this.coverPath,
    );
  }
}
