import 'package:hive/hive.dart';

part 'select_note.g.dart';

@HiveType(typeId: 1)
class SelectedNote {
  @HiveField(1)
  final int id;

  @HiveField(0)
  final int page;

  @HiveField(2)
  final String text;

  SelectedNote(this.id, this.page, this.text);

  @override
  bool operator ==(Object other) => identical(this, other) || other is SelectedNote && runtimeType == other.runtimeType && text == other.text && page == other.page && id == other.id;

  @override
  int get hashCode => text.hashCode ^ page.hashCode ^ id.hashCode;
}
