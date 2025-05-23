import 'package:epupreader/app/data/models/book_model.dart';
import 'package:epupreader/app/data/models/bookmark.dart';
import 'package:epupreader/app/data/models/select_note.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:epupreader/app/routes/app_pages.dart';
import 'package:epupreader/app/theme/app_theme.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Get the application documents directory for storing Hive database
  final appDir = await getApplicationDocumentsDirectory();
  // Initialize Hive with the app directory path
  Hive.init(appDir.path);
  
  // Check if adapters are already registered to prevent duplicate registration
  // This is important because registering the same adapter multiple times can cause issues
  if (!Hive.isAdapterRegistered(0)) {
    // Register adapters for different data models:
    // - BookModelAdapter: For storing book information
    // - SelectedNoteAdapter: For storing user's selected notes
    // - BookMarkAdapter: For storing bookmarks
    Hive.registerAdapter(BookModelAdapter());
    Hive.registerAdapter(SelectedNoteAdapter());
    Hive.registerAdapter(BookMarkAdapter());
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'EPUB Reader',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      // home: EpubReaderScreen(),
    );
  }
}
