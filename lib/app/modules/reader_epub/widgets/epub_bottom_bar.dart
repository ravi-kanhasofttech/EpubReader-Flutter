import 'package:epupreader/app/modules/reader_epub/epub_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EpubBottomBar extends StatelessWidget {
  final EpubControllerWidget controller;
  final RxDouble scrollProgress;

  const EpubBottomBar({
    super.key,
    required this.controller,
    required this.scrollProgress,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Obx(
                () => controller.currentPage.value == 1
                    ? Container(
                        width: 50,
                      )
                    : IconButton(
                        onPressed: () {
                          if (controller.currentPage.value > 1) {
                            controller.pageController.previousPage();
                          }
                        },
                        icon: const Icon(Icons.arrow_back),
                      ),
              ),
              Obx(() => Text(
                  '${controller.currentPage.value} / ${controller.pages.length}',
                  style: TextStyle(color: controller.textColor.value))),
              Row(
                children: [
                  Obx(() => Text("${controller.getBookPercentageValue()}%")),
                  Obx(() =>
                      controller.currentPage.value == controller.pages.length
                          ? Container(
                              width: 50,
                            )
                          : IconButton(
                              onPressed: () {
                                if (controller.currentPage.value <
                                    controller.pages.length) {
                                  controller.pageController.nextPage();
                                }
                              },
                              icon: const Icon(Icons.arrow_forward),
                            )),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
