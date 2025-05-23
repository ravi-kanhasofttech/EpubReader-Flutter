import 'package:hive/hive.dart';

part 'bookmark.g.dart';

@HiveType(typeId: 2)
class BookMark {
  @HiveField(1)
  final int id;

  @HiveField(0)
  final int page;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String bookTitle;

  BookMark(this.id, this.page, this.title, this.bookTitle);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookMark &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          bookTitle == other.bookTitle &&
          page == other.page &&
          id == other.id;

  @override
  int get hashCode =>
      title.hashCode ^ bookTitle.hashCode ^ page.hashCode ^ id.hashCode;
}
