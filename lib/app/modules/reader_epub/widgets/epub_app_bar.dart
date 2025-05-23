import 'package:epub_reader_highlight/epub_reader_highlight.dart';
import 'package:epupreader/app/modules/reader_epub/epub_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EpubAppBar extends StatelessWidget implements PreferredSizeWidget {
  final EpubControllerWidget controller;

  const EpubAppBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Epub Reader'),
      backgroundColor: controller.backgroundColor.value,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          showModalBottomSheet(
            // isScrollControlled: true,
            backgroundColor: Colors.white,
            context: context,
            builder: (context) => Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chapters',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: controller.chapterList.length,
                      itemBuilder: (context, index) {
                        final chapter = controller.chapterList[index];
                        return _buildChapterItem(chapter);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      actions: [
        // Notes List Icon
        IconButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (context) => DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.6,
                minChildSize: 0.3,
                maxChildSize: 0.95,
                builder: (context, scrollController) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Notes",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: controller.textColor.value,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: controller.noteList.isNotEmpty
                              ? ListView.builder(
                                  controller: scrollController,
                                  itemCount: controller.noteList.length,
                                  itemBuilder: (context, index) {
                                    final note = controller.noteList[index];
                                    final RxBool isExpanded = false.obs;
                                    return Obx(() => GestureDetector(
                                          onTap: () => isExpanded.toggle(),
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  note.text,
                                                  maxLines: isExpanded.value
                                                      ? null
                                                      : 3,
                                                  overflow: isExpanded.value
                                                      ? TextOverflow.visible
                                                      : TextOverflow.ellipsis,
                                                ),
                                                if (note.text
                                                            .split('\n')
                                                            .length >
                                                        3 ||
                                                    note.text.length > 100)
                                                  Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                      isExpanded.value
                                                          ? "Show less"
                                                          : "Read more",
                                                      style: TextStyle(
                                                        color: Colors.blue,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  )
                                              ],
                                            ),
                                          ),
                                        ));
                                  },
                                )
                              : const Center(
                                  child: Text("Notes not found!"),
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
          icon: const Icon(Icons.note_alt_outlined),
        ),

        // Bookmark List
        PopupMenuButton(
          color: controller.backgroundColor.value,
          icon: const Icon(Icons.bookmark),
          position: PopupMenuPosition.under,
          padding: EdgeInsets.zero,
          itemBuilder: (_) => controller.bookmarks
              .where(
            (b) => b.bookTitle == controller.bookTitle.value,
          )
              .map((bookmark) {
            return PopupMenuItem(
              onTap: () {
                // Get.back();
                controller.currentPage.value = bookmark.page;
                _navigateToChapter(controller.chapterList[bookmark.page],
                    isFromBottomShit: false);
              },
              value: bookmark.page,
              child: Text(
                bookmark.title,
                style: TextStyle(color: controller.textColor.value),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
        ),
        // Current Page Bookmark
        Obx(() => IconButton(
              onPressed: () =>
                  controller.toggleBookmark(controller.currentPage.value - 1),
              icon: controller.isBookmarked(controller.currentPage.value - 1)
                  ? const Icon(Icons.bookmark)
                  : const Icon(Icons.bookmark_border_rounded),
            )),
        // Theme Settings
        IconButton(
          onPressed: () =>
              controller.showSettingsBottomSheet(context, controller),
          icon: const Icon(Icons.palette_rounded),
        ),
      ],
    );
  }

  Widget _buildChapterItem(EpubChapter chapter) {
    if (chapter.SubChapters?.isEmpty ?? true) {
      return ListTile(
        title: Text(
          chapter.Title ?? '',
          style: const TextStyle(fontSize: 16),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        onTap: () {
          _navigateToChapter(chapter);
          // Get.back();
        },
      );
    } else {
      return ExpansionTile(
        title: Text(
          chapter.Title ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: chapter.SubChapters?.map((subChapter) => ListTile(
                  title: Text(
                    subChapter.Title ?? '',
                    style: const TextStyle(fontSize: 14),
                  ),
                  onTap: () {
                    _navigateToChapter(subChapter);
                    // Get.back();
                  },
                )).toList() ??
            [],
      );
    }
  }

  void _navigateToChapter(EpubChapter chapter, {bool isFromBottomShit = true}) {
    if (chapter.HtmlContent != null) {
      final pageIndex = controller.pages
          .indexWhere((page) => page.contains(chapter.HtmlContent!));

      if (pageIndex != -1) {
        if (isFromBottomShit) {
          Get.back();
        }
        controller.pageController.goToPage(pageIndex);
        controller.currentPage.value = pageIndex + 1;
      }
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
