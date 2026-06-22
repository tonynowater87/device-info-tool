/// 依 Android 版本產生官方版本更新說明（release notes）頁面的網址。
///
/// 官方網址有三種格式：
///   - Android 5.x ：/about/versions/android-5.0
///   - Android 6–9 ：/about/versions/{代號}/android-6.0  （代號小寫，例如 pie）
///   - Android 10+ ：/about/versions/16
///
/// Android 5 以下沒有對應的官方頁面，回傳 null（UI 不顯示入口）。
class AndroidVersionDoc {
  static const String _base = 'https://developer.android.com/about/versions';

  /// 取得指定版本的官方說明頁網址，沒有對應頁面時回傳 null。
  ///
  /// [version]   例如 "5.0" / "8.1.0" / "9" / "12L" / "16"
  /// [codeName]  例如 "Pie"（Android 6–9 用來組網址）
  /// [localeCode] App 目前語系（例如 "zh_TW"），會轉成官方文件的 ?hl= 參數
  static String? urlFor(String version, String codeName, {String? localeCode}) {
    final major = _majorInt(version);
    if (major == null || major < 5) {
      return null;
    }

    String path;
    if (major >= 10) {
      // 直接用主版號標記，例如 16、12L
      path = '$_base/${version.split('.').first}';
    } else if (major == 5) {
      path = '$_base/android-${_minorVersion(version)}';
    } else {
      final slug = codeName.trim().toLowerCase();
      if (slug.isEmpty) {
        return null;
      }
      path = '$_base/$slug/android-${_minorVersion(version)}';
    }

    final hl = _toHl(localeCode);
    return hl == null ? path : '$path?hl=$hl';
  }

  /// 取出主版號整數："12L" -> 12、"5.0.1" -> 5、"9" -> 9。
  static int? _majorInt(String version) {
    final head = version.split('.').first;
    final digits = RegExp(r'\d+').firstMatch(head);
    return digits == null ? null : int.tryParse(digits.group(0)!);
  }

  /// 收斂到「主.次」版，丟掉修補版號：
  /// "5.0.1" -> "5.0"、"8.1.0" -> "8.1"、"9" -> "9.0"。
  static String _minorVersion(String version) {
    final parts = version.split('.');
    if (parts.length == 1) {
      return '${parts[0]}.0';
    }
    return '${parts[0]}.${parts[1]}';
  }

  /// App 語系轉成官方文件的 hl 參數："zh_TW" -> "zh-tw"，"en" -> null（預設英文不帶參數）。
  static String? _toHl(String? localeCode) {
    if (localeCode == null || localeCode.isEmpty) {
      return null;
    }
    final hl = localeCode.toLowerCase().replaceAll('_', '-');
    if (hl == 'en' || hl.startsWith('en-')) {
      return null;
    }
    return hl;
  }
}
