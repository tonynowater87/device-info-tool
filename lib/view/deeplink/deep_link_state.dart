part of 'deep_link_cubit.dart';

@immutable
abstract class DeepLinkState {}

class DeepLinkLoading extends DeepLinkState {}

class DeepLinkLoaded extends DeepLinkState {
  List<UrlModel> urls;
  bool isTextFieldEmpty;
  String? errorString;

  DeepLinkLoaded(
      {required this.urls,
      required this.isTextFieldEmpty,
      required this.errorString});

  @override
  String toString() {
    return "urls: ${urls.length}, isTextFieldEmpty: $isTextFieldEmpty, errorString: $errorString";
  }
}
