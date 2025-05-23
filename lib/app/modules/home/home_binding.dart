import 'package:get/get.dart';
import 'home_controller.dart';
import '../../data/services/book_service.dart';

/// Binding class for the Home module that handles dependency injection
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize BookService as a singleton
    Get.put(BookService());
    // Initialize HomeController lazily
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
