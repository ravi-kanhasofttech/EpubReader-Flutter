import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';

/// A view class that displays the home screen of the EPUB reader application.
/// This screen provides options to open EPUB files from assets or device storage.
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('EPUB Reader'),
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        // Show loading indicator while content is being loaded
        if (controller.isLoading.value) {
          return const CircularProgressIndicator();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select Option',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Option to open EPUB from assets
                buildBookTile(
                    onTap: () {
                      const assetPath = 'assets/epub/accessible_epub.epub';
                      const endPath = 'accessible_epub.epub';
                      controller.openBook(assetPath, endPath);
                    },
                    icon: Icons.book,
                    backgroundColor: Colors.blue.shade100,
                    iconColor: Colors.blue,
                    subTitle: "Assets"),
                // Option to pick EPUB from device storage
                buildBookTile(
                    onTap: () {
                      controller.pickAndOpenEpub();
                    },
                    icon: Icons.file_open,
                    backgroundColor: Colors.orange.shade100,
                    iconColor: Colors.orange,
                    subTitle: "Choose EPUB File"),
              ],
            ),
          ],
        );
      }),
    );
  }

  /// Builds a clickable book tile with an icon and subtitle.
  /// 
  /// [onTap] - Callback function when the tile is tapped
  /// [icon] - Icon to display in the tile
  /// [backgroundColor] - Background color of the tile
  /// [iconColor] - Color of the icon
  /// [subTitle] - Text to display below the icon
  Widget buildBookTile({
    required VoidCallback onTap,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required String subTitle,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 50,
              color: iconColor,
            ),
          ),
          SizedBox(height: 10),
          Text(
            subTitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          )
        ],
      ),
    );
  }
}
