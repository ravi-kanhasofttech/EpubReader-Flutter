# EpubReader-Flutter

---

### How to run the app

- Make sure Flutter SDK is installed.
- Clone the repository and open the project folder.
- Run `flutter pub get` to install dependencies.
- Connect a device or start an emulator.
- Run the app with `flutter run`.

---

### Which packages you used

- **flutter**: Core Flutter SDK
- **get**: State management
- **file_picker**: Pick files from device storage
- **epubx**: Parse and handle EPUB files
- **shared_preferences**: Store simple local key-value data
- **hive**: Local NoSQL database
- **hive_flutter**: Flutter adapter for Hive
- **google_fonts**: Use Google Fonts easily
- **path_provider**: Find device storage paths
- **flutter_svg**: Render SVG images
- **permission_handler**: Request permissions on device
- **uuid**: Generate unique IDs
- **cupertino_icons**: iOS style icons
- **flutter_html**: Render HTML content
- **html_parser_plus**: Advanced HTML parsing
- **epub_view**: EPUB file rendering widget
- **highlight_text**: Highlight words in text
- **epub_reader_highlight**: Text highlighting in EPUBs
- **flutter_epub_viewer**: Fullscreen EPUB viewer
- **page_flip**: Page flip animation

---

### What’s done

- Display current reading progress (e.g. 50% read).
- Open an EPUB file from local assets or device storage.
- Show current page number and total page count.
- Add a bookmark on the current page (saved in local state for now — will be moved to backend
  later).
- Display book contents (table of contents).
- Show book notes and reference list (dummy data for now).
- Select text and add a note (store locally for now — will be saved to backend later).
- Adjust user preferences:
    - Background color
    - Font size
    - Font family

---

### What’s not done

- Turn pages horizontally, simulating a real book.

---
