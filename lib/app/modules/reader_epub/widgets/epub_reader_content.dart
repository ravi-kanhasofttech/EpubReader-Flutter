import 'dart:typed_data';

import 'package:epupreader/app/modules/reader_epub/epub_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:page_flip/page_flip.dart';

class EpubReaderContent extends StatelessWidget {
  final EpubControllerWidget controller;
  final ScrollController scrollController;
  final RxDouble scrollProgress;

  const EpubReaderContent({
    super.key,
    required this.controller,
    required this.scrollController,
    required this.scrollProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return PageFlipWidget(
          key: Key("a"),
          backgroundColor: Colors.transparent,
          controller: controller.pageController,
          onPageFlipped: (pageNumber) {
            controller.currentPage.value = pageNumber + 1;
          },
          children: controller.pages
              .map((page) => Obx(() => Container(
                    color: controller.backgroundColor.value,
                    padding: const EdgeInsets.all(10),
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (scrollController.hasClients) {
                          try {
                            final maxScroll =
                                scrollController.position.maxScrollExtent;
                            final currentScroll =
                                scrollController.position.pixels;
                            scrollProgress.value =
                                (currentScroll / maxScroll) * 100;
                          } catch (e) {
                            //nothing to do
                          }
                        }
                        return true;
                      },
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: SelectionArea(
                          onSelectionChanged: (value) {
                            controller.tempTextHighlight.value =
                                value?.plainText ?? "";
                          },
                          contextMenuBuilder: (context, editableTextState) {
                            return AdaptiveTextSelectionToolbar.buttonItems(
                              anchors: editableTextState.contextMenuAnchors,
                              buttonItems: [
                                ContextMenuButtonItem(
                                  label: 'Add Note',
                                  onPressed: () {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    if (controller
                                        .tempTextHighlight.value.isNotEmpty) {
                                      controller.showContextMenu(
                                          context,
                                          controller.currentPage.value,
                                          controller.tempTextHighlight
                                              .value); // Your custom logic
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                          child: Html(
                            data: page,
                            extensions: [
                              TagExtension(
                                tagsToExtend: {"img"},
                                builder: (context) {
                                  final src = context.attributes['src'] ?? '';
                                  final cleanedSrc =
                                      src.replaceAll(RegExp(r'^\.\.?/'), '');

                                  // Try to match the src with the internal image keys
                                  final imageEntry = controller.imageMap.entries
                                      .firstWhere(
                                          (e) => e.key.contains(cleanedSrc));

                                  if (imageEntry.value is Map &&
                                      (imageEntry.value is Map).isBlank ==
                                          false) {
                                    return const Text('[Image not found]');
                                  }

                                  return Image.memory((imageEntry.value
                                      as dynamic) as Uint8List);
                                },
                              ),
                            ],
                            onAnchorTap: (details, element, elementType) {},
                            style: _getHtmlStyles(),
                          ),
                        ),
                      ),
                    ),
                  )))
              .toList());
    });
  }

  Map<String, Style> _getHtmlStyles() {
    return {
      "tr": Style(
        border: Border(bottom: BorderSide(color: Colors.grey)),
      ),
      "td": Style(
        padding: HtmlPaddings.all(6),
        border: Border.all(color: Colors.grey),
      ),
      "th": Style(
        padding: HtmlPaddings.all(6),
        backgroundColor: Colors.grey.shade300,
        border: Border.all(color: Colors.grey),
        fontWeight: FontWeight.bold,
      ),
      // your other styles...
      "body": Style(
        fontFamily: controller.fontFamily.value,
        fontSize: FontSize(controller.fontSize.value),
        color: controller.textColor.value,
        lineHeight: LineHeight(1.5),
        textAlign: TextAlign.justify,
        padding: HtmlPaddings.all(16),
        margin: Margins.all(0),
      ),
      "img": Style(),
      "a": Style(
        color: Colors.blue,
        textDecoration: TextDecoration.underline,
      ),
      "title": Style(
        fontSize: FontSize(controller.fontSize.value * 1.8),
        fontWeight: FontWeight.bold,
        fontFamily: controller.fontFamily.value,
        margin: Margins.only(bottom: 0),
      ),
      "p": Style(
        fontFamily: controller.fontFamily.value,
        margin: Margins.only(bottom: 10),
        color: controller.textColor.value,
        lineHeight: LineHeight(1.5),
        textAlign: TextAlign.left,
      ),
      "h1": Style(
        fontFamily: controller.fontFamily.value,
        fontSize: FontSize(controller.fontSize.value * 1.8),
        fontWeight: FontWeight.bold,
        color: controller.textColor.value,
        margin: Margins.only(bottom: 0),
      ),
      "h2": Style(
        fontFamily: controller.fontFamily.value,
        fontSize: FontSize(controller.fontSize.value * 1.6),
        fontWeight: FontWeight.bold,
        color: controller.textColor.value,
        margin: Margins.only(bottom: 0),
        textAlign: TextAlign.left,
      ),
      "h3": Style(
        fontFamily: controller.fontFamily.value,
        fontSize: FontSize(controller.fontSize.value * 1.4),
        fontWeight: FontWeight.bold,
        color: controller.textColor.value,
        margin: Margins.only(bottom: 0),
      ),
      "h4": Style(
        fontFamily: controller.fontFamily.value,
        fontSize: FontSize(controller.fontSize.value * 1.2),
        fontWeight: FontWeight.bold,
        color: controller.textColor.value,
        margin: Margins.only(bottom: 0),
      ),
      "h5": Style(
        fontFamily: controller.fontFamily.value,
        fontSize: FontSize(controller.fontSize.value * 1.1),
        fontWeight: FontWeight.bold,
        color: controller.textColor.value,
        margin: Margins.only(bottom: 0),
      ),
      "table": Style(
        fontFamily: controller.fontFamily.value,
        border: Border.all(color: Colors.blue),
        margin: Margins.only(bottom: 10),
      ),
    };
  }
}
