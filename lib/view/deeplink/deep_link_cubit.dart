import 'package:bloc/bloc.dart';
import 'package:device_info_tool/data/database_provider.dart';
import 'package:device_info_tool/data/model/url_record.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

part 'deep_link_state.dart';

class DeepLinkCubit extends Cubit<DeepLinkState> {
  DatabaseProvider databaseProvider;

  DeepLinkCubit(this.databaseProvider) : super(DeepLinkLoading());

  load(String query) async {
    var results =
        await databaseProvider.queryUrlRecords(DatabaseOrder.DESC, query);
    var urls = results.map((e) => UrlModel(id: e.id, url: e.url)).toList();
    debugPrint('load $query');
    emit(DeepLinkLoaded(
        urls: urls, isTextFieldEmpty: query.isEmpty, errorString: null));
  }

  Future<bool> open(String url) async {
    var urls = state as DeepLinkLoaded;
    if (_isValidUrl(url)) {
      bool canResolveApp;
      try {
        canResolveApp = await launchUrl(Uri.parse(url),
            mode: LaunchMode.externalNonBrowserApplication);
      } on PlatformException {
        canResolveApp = false;
      }
      await databaseProvider.insertOrUpdateUrlRecord(url);
      load(url);
      return Future.value(canResolveApp);
    } else {
      emit(DeepLinkLoaded(
          urls: urls.urls,
          isTextFieldEmpty: false,
          errorString: "Not a valid URL"));
      return Future.value(false);
    }
  }

  deleteById(int id) async {
    await databaseProvider.deleteUrlRecord(id);
    var oldState = (state as DeepLinkLoaded);
    var newList = oldState.urls.toList();
    newList.removeWhere((element) => element.id == id);
    emit(DeepLinkLoaded(
        urls: newList,
        isTextFieldEmpty: oldState.isTextFieldEmpty,
        errorString: oldState.errorString));
  }

  deleteAll() async {
    await databaseProvider.deleteAllUrlRecords();
    var oldState = (state as DeepLinkLoaded);
    emit(DeepLinkLoaded(
        urls: const [],
        isTextFieldEmpty: oldState.isTextFieldEmpty,
        errorString: oldState.errorString));
  }

  copy(String url) {
    Clipboard.setData(ClipboardData(text: url));
  }

  bool _isValidUrl(String url) {
    const pattern = r'^(\w+)://[^/\s?#]+(?:/[^?\s#]*)?(?:\?[^#\s]*)?(?:#[^\s]*)?$';
    final regex = RegExp(pattern);
    return regex.hasMatch(url);
  }
}
