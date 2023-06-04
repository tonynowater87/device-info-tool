part of 'ios_version_page_cubit.dart';

@immutable
abstract class IosVersionPageState {}

class IosVersionPageInitial extends IosVersionPageState {}

class IosVersionPageSuccess extends IosVersionPageState {
  final List<UiModelIOS> data;
  final int indexOfSelfVersion;

  IosVersionPageSuccess({required this.data, required this.indexOfSelfVersion});
}

class IosVersionPageFailure extends IosVersionPageState {
  IosVersionPageFailure();
}
