import 'dart:io';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/book_model.dart';
import 'package:epubx/epubx.dart';

class BookService extends GetxService {
  late Box<BookModel> _bookBox;
  final _uuid = const Uuid();

  BookService() {
    _init();
  }

  Future<void> _init() async {
    final appDir = await getApplicationDocumentsDirectory();
    Hive.init(appDir.path);

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(BookModelAdapter());
    }

    _bookBox = await Hive.openBox<BookModel>('books');
  }

  Future<List<BookModel>> getBooks() async {
    return _bookBox.values.toList();
  }

  Future<BookModel> addBook(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File does not exist');
    }

    final epubBook = await EpubReader.readBook(file.readAsBytesSync());
    final book = BookModel(
      id: _uuid.v4(),
      title: epubBook.Title ?? 'Untitled',
      author: epubBook.Author,
      filePath: filePath,
      lastRead: DateTime.now(),
    );

    await _bookBox.put(book.id, book);
    return book;
  }

  Future<void> updateBook(BookModel book) async {
    await _bookBox.put(book.id, book);
  }

  Future<void> deleteBook(String id) async {
    await _bookBox.delete(id);
  }

  Future<void> updateProgress(String id, double progress) async {
    final book = _bookBox.get(id);
    if (book != null) {
      await _bookBox.put(
        id,
        book.copyWith(
          progress: progress,
          lastRead: DateTime.now(),
        ),
      );
    }
  }
}
