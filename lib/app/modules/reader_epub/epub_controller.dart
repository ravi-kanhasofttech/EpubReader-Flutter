import 'dart:convert';
import 'dart:developer';

import 'package:epub_reader_highlight/epub_reader_highlight.dart';
import 'package:epupreader/app/data/models/bookmark.dart';
import 'package:epupreader/app/data/models/select_note.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Uint8List;
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:page_flip/page_flip.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EpubControllerWidget extends GetxController {
  // State variables
  var isLoading = true.obs;
  final fontSize = 16.0.obs;
  final fontFamily = 'Roboto'.obs;
  final textColor = Colors.black.obs;
  final backgroundColor = Colors.white.obs;
  final currentPage = 1.obs;
  final chapterList = <EpubChapter>[].obs;

  final highlights = <Map<String, dynamic>>[].obs;
  final pageController = PageFlipController();
  final pages = <String>[].obs;
  final screenHeight = 956.obs;
  final tempTextHighlight = "".obs;
  final tempHtmlContent = "".obs;
  final textSelectionCfis = ''.obs;
  late Map<String, Uint8List> imageMap;

  // Constants
  static const String _prefsFontSize = 'fontSize';
  static const String _prefsFontFamily = 'fontFamily';
  static const String _prefsTextColor = 'textColor';
  static const String _prefsBackgroundColor = 'backgroundColor';
  static const String _prefsLastPage = 'lastPage';

  late EpubController epubReaderController;

  RxList<SelectedNote> noteList = <SelectedNote>[].obs;
  RxList<BookMark> bookmarks = <BookMark>[].obs;

  final notes = <SelectedNote>[].obs;
  late Box<SelectedNote> noteOpenBox;
  Box<BookMark>? bookmarkOpenBox;
  RxString bookTitle = "".obs;

  @override
  void onInit() {
    super.onInit();

    _loadPreferences();
    loadBook();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // pageController.dispose();
    currentPage.value = 1;
  }

  Future<void> _loadPreferences() async {
    currentPage.value = 1;
    final prefs = await SharedPreferences.getInstance();
    fontSize.value = prefs.getDouble(_prefsFontSize) ?? 16.0;
    fontFamily.value = prefs.getString(_prefsFontFamily) ?? 'Roboto';
    textColor.value =
        Color(prefs.getInt(_prefsTextColor) ?? Colors.black.value);
    backgroundColor.value =
        Color(prefs.getInt(_prefsBackgroundColor) ?? Colors.white.value);
    currentPage.value = prefs.getInt(_prefsLastPage) ?? 1;
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefsFontSize, fontSize.value);
    await prefs.setString(_prefsFontFamily, fontFamily.value);
    await prefs.setInt(_prefsTextColor, textColor.value.value);
    await prefs.setInt(_prefsBackgroundColor, backgroundColor.value.value);
    await prefs.setInt(_prefsLastPage, currentPage.value);
    // await prefs.setStringList(
    //     _prefsBookmarks, bookmarks.map((e) => e.toString()).toList());
    update();
  }

  Future<void> loadBook() async {
    noteOpenBox = await Hive.openBox<SelectedNote>('notes');
    bookmarkOpenBox = await Hive.openBox<BookMark>('bookmark');

    currentPage.value = 1;
    try {
      isLoading.value = true;
      if (Get.arguments != null &&
          Get.arguments is Map &&
          (Get.arguments as Map).containsKey('model') &&
          (Get.arguments as Map).containsKey('bookByte')) {
        EpubBook book = (Get.arguments as Map)['bookByte'];
        //
        bookTitle.value = book.Title ?? "";
        chapterList.assignAll(book.Chapters!);
        final paginatedPages = await getPaginatedPages(book, 2000);
        pages.assignAll(paginatedPages);
        imageMap = _extractImages(book);

        // Navigate to last read page
        // if (currentPage.value > 1 && currentPage.value <= pages.length) {
        //   pageController.jumpToPage(currentPage.value - 1);
        // }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load book: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;

      loadNotes();
      loadBookmark();
    }
  }

  Map<String, Uint8List> _extractImages(EpubBook book) {
    final map = <String, Uint8List>{};
    book.Content?.Images?.forEach((key, value) {
      if (value.Content != null) {
        map[key] = Uint8List.fromList(value.Content!);
      }
    });
    return map;
  }

  Future<List<String>> getPaginatedPages(
      EpubBook book, int charsPerPage) async {
    List<String> pages = [];
    final dynamicPageSize = (charsPerPage * (16 / fontSize.value)).round();
    final baseStyles = _getBaseStyles();

    for (var chapter in book.Chapters!) {
      final htmlContent = chapter.HtmlContent ?? "";
      if (htmlContent.isEmpty) continue;

      final styledContent = _wrapWithStyles(htmlContent, baseStyles);
      final chunks = _splitHtmlIntoChunks(styledContent, dynamicPageSize);
      pages.addAll(chunks);
    }

    return pages;
  }

  String _getBaseStyles() {
    return '''
      <style>
        html, body {
          margin: 0;
          padding: 0;
          overflow: hidden;
          height: 100vh;
          width: 100vw;
        }

        .reader-container {
          display: flex;
          flex-direction: row;
          overflow-x: auto;
          overflow-y: hidden;
          scroll-snap-type: x mandatory;
          width: 100vw;
          height: 100vh;
        }

        .page {
          flex: 0 0 100vw;
          height: 100vh;
          scroll-snap-align: start;
          padding: 16px;
          box-sizing: border-box;
          overflow-y: auto;
        }

        .page::-webkit-scrollbar {
          width: 0px;
          background: transparent;
        }

        body {
          font-family: ${fontFamily.value};
          font-size: ${fontSize.value}px;
          color: ${textColor.value};
          line-height: 1.5;
          text-align: justify;
        }

        p { margin-bottom: 10px; }
        h1 { font-size: ${fontSize.value * 1.8}px; font-weight: bold; margin-bottom: 16px; }
        h2 { font-size: ${fontSize.value * 1.6}px; font-weight: bold; margin-bottom: 14px; }
        h3 { font-size: ${fontSize.value * 1.4}px; font-weight: bold; margin-bottom: 12px; }
        h4 { font-size: ${fontSize.value * 1.2}px; font-weight: bold; margin-bottom: 10px; }
        h5 { font-size: ${fontSize.value * 1.1}px; font-weight: bold; margin-bottom: 8px; }

        img { 
          max-width: 100%; 
          height: auto; 
          display: block; 
          margin: 10px auto;
          object-fit: contain;
          max-height: 80vh;
        }

        code, pre {
          background-color: rgba(128, 128, 128, 0.2);
          padding: 10px;
          overflow-x: auto;
        }

        table, th, td {
          border: 1px solid grey;
          border-collapse: collapse;
          padding: 8px;
          width: 100%;
        }
      </style>
    ''';
  }

  String _wrapWithStyles(String content, String styles) {
    return '''
      <!DOCTYPE html>
      <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          $styles
        </head>
        <body>
          <div class="reader-container">
            $content
          </div>
        </body>
      </html>
    ''';
  }

  List<String> _splitHtmlIntoChunks(String html, int targetSize) {
    List<String> chunks = [];
    String currentChunk = '';
    int currentSize = 0;
    List<String> tagStack = [];
    bool inTag = false;

    final tagRegex = RegExp(r'<[^>]*>');
    final selfClosingTags = {'img', 'br', 'hr', 'input', 'meta', 'link'};

    final parts = html.split(tagRegex);
    final tags = tagRegex.allMatches(html).map((m) => m.group(0)!).toList();

    for (int i = 0; i < parts.length; i++) {
      final text = parts[i];
      final tag = i < tags.length ? tags[i] : '';

      if (tag.startsWith('<') && !tag.startsWith('</') && !tag.endsWith('/>')) {
        final tagName = tag.replaceAll(RegExp(r'[<>]'), '').split(' ')[0];
        if (!selfClosingTags.contains(tagName)) {
          tagStack.add(tagName);
        }
      } else if (tag.startsWith('</')) {
        final tagName = tag.replaceAll(RegExp(r'[<>]'), '').split(' ')[0];
        if (tagStack.isNotEmpty && tagStack.last == tagName) {
          tagStack.removeLast();
        }
      }

      currentChunk += text + tag;
      currentSize += text.length;

      if (currentSize >= targetSize &&
          (tagStack.isEmpty ||
              text.contains(RegExp(r'</p>|</div>|</section>|</article>')))) {
        if (!inTag) {
          chunks.add(currentChunk);
          currentChunk = '';
          currentSize = 0;
        }
      }
    }

    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk);
    }

    return chunks;
  }

  void showSettingsBottomSheet(
      BuildContext context, EpubControllerWidget controller) {
    // Reading-friendly color palette
    final readingColors = {
      'Light': {
        'background': Colors.white,
        'text': const Color(0xFF2C3E50),
        'accent': const Color(0xFF3498DB),
      },
      'Sepia': {
        'background': const Color(0xFFF4ECD8),
        'text': const Color(0xFF5C4033),
        'accent': const Color(0xFFD4A76A),
      },
      'Dark': {
        'background': const Color(0xFF1A1A1A),
        'text': const Color(0xFFE0E0E0),
        'accent': const Color(0xFF64B5F6),
      },
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Important for full-height scroll
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Obx(() => SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Fix overflow
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      "Reading Settings",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Font Size Section
                  const Text(
                    "Font Size",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          if (controller.fontSize.value > 12) {
                            controller.fontSize.value -= 1;
                            _savePreferences();
                          }
                        },
                      ),
                      Expanded(
                        child: Slider(
                          value: controller.fontSize.value,
                          min: 12,
                          max: 30,
                          divisions: 18,
                          label: "${controller.fontSize.value.toInt()}",
                          onChanged: (value) {
                            controller.fontSize.value = value;
                            _savePreferences();
                          },
                          activeColor: const Color(0xFF3498DB),
                          inactiveColor: Colors.grey[300],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          if (controller.fontSize.value < 30) {
                            controller.fontSize.value += 1;
                            _savePreferences();
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Font Family Section
                  const Text(
                    "Font Family",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      dropdownColor: Colors.white,
                      value: controller.fontFamily.value,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: [
                        'Roboto',
                        'Poppins',
                        'Merriweather',
                        'Lora',
                        'Source Serif Pro'
                      ]
                          .map((f) => DropdownMenuItem(
                        value: f,
                        child: Text(f),
                      ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.fontFamily.value = value;
                          _savePreferences();
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Theme Section
                  const Text(
                    "Theme",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: readingColors.entries.map((theme) {
                      final isSelected = controller.backgroundColor.value ==
                          theme.value['background'];
                      return GestureDetector(
                        onTap: () {
                          controller.backgroundColor.value =
                          theme.value['background']!;
                          controller.textColor.value = theme.value['text']!;
                          _savePreferences();
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: theme.value['background'],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? theme.value['accent']!
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              theme.key[0],
                              style: TextStyle(
                                color: theme.value['text'],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ));
      },
    );

  }

  Future<void> toggleBookmark(int page) async {
    BookMark bookmarkObject = BookMark((chapterList.length + 1), page,
        "${chapterList[page].Title}", bookTitle.value);

    // Find if bookmark exists for this page
    final existingIndex = bookmarks
        .indexWhere((b) => b.page == page && b.bookTitle == bookTitle.value);

    if (existingIndex != -1) {
      // Remove existing bookmark
      log('Removed bookmark: $jsonEncode(bookmarkObject)');
      await bookmarkOpenBox?.deleteAt(existingIndex);
    } else {
      // Add new bookmark
      await bookmarkOpenBox?.add(bookmarkObject);
    }
    loadBookmark();
    log('Current bookmarks: ${bookmarks.toString()}');
  }

  bool isBookmarked(int page) =>
      bookmarks.any((b) => b.page == page && b.bookTitle == bookTitle.value);

  String highlightPhrase(String html, String phrase) {
    return html.replaceAll(
      phrase,
      '<span style="background-color: yellow;">$phrase</span>',
    );
  }

  void addHighlight(int index) {
    if (tempTextHighlight.value.isEmpty) return;

    highlights.add({
      'page': index + 1,
      'text': tempTextHighlight.value,
      'color': Colors.yellow,
    });

    tempTextHighlight.value = "";
  }

  String highlightTextInHtml(
      String html, String textToHighlight, Color highlightColor) {
    if (textToHighlight.isEmpty) return html;

    final colorHex = '#${highlightColor.value.toRadixString(16).substring(2)}';
    final escapedText = RegExp.escape(textToHighlight);

    return html.replaceAllMapped(
      RegExp(escapedText, caseSensitive: false),
      (match) => '<span style="background-color: $colorHex">${match[0]}</span>',
    );

    /*List<String> chunks = [];
    List<String> currentChunkBlocks = [];
    int currentSize = 0;

    // Match block-level tags and their content (simplified, assumes well-formed HTML)
    final blockTagPattern =
    RegExp(r'<(p|div|section|article|h[1-6]|li|blockquote)[^>]*>.*?<\/\1>', dotAll: true, caseSensitive: false);

    final matches = blockTagPattern.allMatches(html).toList();

    // If no block tags found, fallback: treat whole html as one chunk
    if (matches.isEmpty) {
      if (html.trim().isNotEmpty) {
        chunks.add(html);
      }
      return chunks;
    }

    for (var match in matches) {
      final block = match.group(0) ?? '';

      // Check if block has visible text (remove tags and trim)
      final textOnly = block.replaceAll(RegExp(r'<[^>]*>'), '').trim();
      if (textOnly.isEmpty) continue; // skip empty blocks

      final blockSize = block.length;

      if (currentSize + blockSize > targetSize && currentChunkBlocks.isNotEmpty) {
        // Add current chunk
        chunks.add(currentChunkBlocks.join());
        currentChunkBlocks = [];
        currentSize = 0;
      }

      currentChunkBlocks.add(block);
      currentSize += blockSize;
    }

    // Add remaining blocks as last chunk
    if (currentChunkBlocks.isNotEmpty) {
      chunks.add(currentChunkBlocks.join());
    }

    return chunks;*/
  }

  loadNotes() {
    noteList.assignAll(Hive.box<SelectedNote>('notes').values.toList());
  }

  loadBookmark() {
    List<BookMark> allBookmark = Hive.box<BookMark>('bookmark').values.toList();
    bookmarks.assignAll(allBookmark);
  }

  List<Map<String, dynamic>> getHighlightsForPage(int page) =>
      highlights.where((h) => h['page'] == page).toList();

  double calculateReadingProgress({
    required int currentPageIndex,
    required int totalPages,
    required double scrollOffset,
    required double maxScrollExtent,
  }) {
    if (totalPages == 0) return 0;

    // Base progress from completed pages
    double basePageProgress = currentPageIndex / totalPages;

    // In-page progress (0.0 to 1.0)
    double inPageProgress =
        maxScrollExtent > 0 ? (scrollOffset / maxScrollExtent) : 0.0;

    // Combine progress
    double totalProgress =
        (basePageProgress + (inPageProgress / totalPages)) * 100;

    // Clamp to 0-100%
    return totalProgress.clamp(0.0, 100.0);
  }

  void showContextMenu(
      BuildContext context, int page, String selectedText) async {
    final trimmedText = selectedText.trim();
    if (!notes.any((note) => note.text == selectedText)) {
      final newNote = SelectedNote(page, notes.length, trimmedText);
      await noteOpenBox.add(newNote);
      notes.add(newNote);
      Get.snackbar("Note", 'Note saved!', backgroundColor: Colors.green);
      loadNotes();
    }

  }

  //calculating percentage of book read
  int getBookPercentageValue() {
    int progress = 0;
    if (pages.isNotEmpty) {
      progress = ((currentPage.value) / pages.length * 100).toInt();
    }
    return progress;
  }
}

class EpubControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EpubControllerWidget());
  }
}
