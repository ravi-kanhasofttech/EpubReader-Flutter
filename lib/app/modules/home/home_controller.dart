import 'package:epupreader/app/data/models/book_model.dart';
import 'package:epupreader/app/data/services/book_service.dart';
import 'package:epupreader/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:epubx/epubx.dart';

class HomeController extends GetxController {
  final BookService _bookService = Get.find<BookService>();
  final RxList<BookModel> books = <BookModel>[].obs;
  final RxBool isLoading = false.obs;

  Future<void> loadBooks() async {
    isLoading.value = true;
    try {
      books.value = await _bookService.getBooks();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load books: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAssetBooks() async {
    try {
      const assetPath = 'assets/epub/accessible_epub.epub';
      final bytes = await rootBundle.load(assetPath);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/accessible_epub.epub');
      await tempFile.writeAsBytes(bytes.buffer.asUint8List());
      await _bookService.addBook(tempFile.path);
      await loadBooks();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load asset book: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['epub'],
      );

      if (result != null) {
        final file = result.files.first;
        await _bookService.addBook(file.path!);
        await loadBooks();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open file: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> openBook(String filePath, String endPath) async {
    isLoading.value = true;
    try {
      final bytes = await rootBundle.load(filePath);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$endPath');
      await tempFile.writeAsBytes(bytes.buffer.asUint8List());

      final epubBook = await EpubReader.readBook(tempFile.readAsBytesSync());
      final book = BookModel(
        id: '1',
        title: epubBook.Title ?? 'Kids World Book',
        author: epubBook.Author,
        filePath: tempFile.path,
        lastRead: DateTime.now(),
      );

      Get.toNamed(
        Routes.EPUB_READER,
        arguments: {
          "model": book,
          "bookByte": epubBook,
        },
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open book: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickAndOpenEpub() async {
    // Step 1: Pick the file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub'],
    );

    // Step 2: Validate result
    if (result != null &&
        result.files.isNotEmpty &&
        result.files.single.path != null) {
      try {
        final filePath = result.files.single.path!;
        final bytes = await File(filePath).readAsBytes();

        // Step 3: Read EPUB
        final epubBook = await EpubReader.readBook(bytes);

        // Step 4: Create book model
        final book = BookModel(
          id: '1',
          title: epubBook.Title ?? 'Kids World Book',
          author: epubBook.Author,
          filePath: filePath,
          lastRead: DateTime.now(),
        );

        // Step 5: Navigate to reader page
        Get.toNamed(
          Routes.EPUB_READER,
          arguments: {
            "model": book,
            "bookByte": epubBook,
          },
        );
      } catch (e) {
        //nothing to do
      }
    } else {
      //nothing to do
    }
  }
}
