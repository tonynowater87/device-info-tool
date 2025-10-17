import 'package:shared_preferences/shared_preferences.dart';

class DefaultPageProvider {
  static const String _keyDefaultPageIndex = 'default_page_index';
  static const String _keyDefaultPageTitle = 'default_page_title';

  Future<void> saveDefaultPage(int pageIndex, String pageTitle) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDefaultPageIndex, pageIndex);
    await prefs.setString(_keyDefaultPageTitle, pageTitle);
  }

  Future<DefaultPageSettings?> getDefaultPage() async {
    final prefs = await SharedPreferences.getInstance();
    final pageIndex = prefs.getInt(_keyDefaultPageIndex);
    final pageTitle = prefs.getString(_keyDefaultPageTitle);

    if (pageIndex != null && pageTitle != null) {
      return DefaultPageSettings(pageIndex: pageIndex, pageTitle: pageTitle);
    }
    return null;
  }

  Future<void> clearDefaultPage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDefaultPageIndex);
    await prefs.remove(_keyDefaultPageTitle);
  }
}

class DefaultPageSettings {
  final int pageIndex;
  final String pageTitle;

  DefaultPageSettings({required this.pageIndex, required this.pageTitle});
}
