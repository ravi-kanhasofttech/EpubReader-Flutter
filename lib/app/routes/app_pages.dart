// Import statements for required modules and views
import 'package:epupreader/app/modules/home/home_binding.dart';
import 'package:epupreader/app/modules/home/home_view.dart';
import 'package:epupreader/app/modules/reader_epub/epub_controller.dart';
import 'package:epupreader/app/modules/reader_epub/epub_reader.dart';
import 'package:get/get.dart';

part 'app_routes.dart';

/// AppPages class defines the routing configuration for the application
class AppPages {
  /// Initial route of the application
  static const INITIAL = Routes.HOME;

  /// List of all available routes in the application
  static final routes = [
    // Home page route configuration
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    // EPUB reader route configuration
    GetPage(
      name: Routes.EPUB_READER,
      page: () => EpubReader(),
      binding: EpubControllerBinding(),
    ),
  ];
}
