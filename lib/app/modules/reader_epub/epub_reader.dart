import 'package:epupreader/app/modules/reader_epub/epub_controller.dart';
import 'package:epupreader/app/modules/reader_epub/widgets/epub_app_bar.dart';
import 'package:epupreader/app/modules/reader_epub/widgets/epub_bottom_bar.dart';
import 'package:epupreader/app/modules/reader_epub/widgets/epub_reader_content.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A widget that displays an EPUB reader with app bar, content, and bottom navigation.
/// Uses GetX for state management and provides scroll progress tracking.
class EpubReader extends StatelessWidget {
  EpubReader({super.key});
  
  /// Controller for managing EPUB reader state and functionality
  final controller = Get.put(EpubControllerWidget());
  
  /// Observable variable to track the current page scroll progress (0.0 to 1.0)
  final RxDouble _currentPageScrollProgress = 0.0.obs;

  @override
  Widget build(BuildContext context) {
    /// Controller for managing the scroll position of the reader content
    final ScrollController scrollController = ScrollController();

    return Obx(() => Scaffold(
          backgroundColor: controller.backgroundColor.value,
          appBar: EpubAppBar(controller: controller),
          body: controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : EpubReaderContent(
                  controller: controller,
                  scrollController: scrollController,
                  scrollProgress: _currentPageScrollProgress,
                ),
          bottomNavigationBar: EpubBottomBar(
            controller: controller,
            scrollProgress: _currentPageScrollProgress,
          ),
        ));
  }
}
