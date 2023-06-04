part of 'android_version_page_cubit.dart';

@immutable
abstract class AndroidVersionPageState {}

class AndroidVersionPageInitial extends AndroidVersionPageState {}

class AndroidVersionPageSuccess extends AndroidVersionPageState {
  final List<VersionModelAndroid> data;
  final int indexOfSelfVersion;

  AndroidVersionPageSuccess({
    required this.data,
    required this.indexOfSelfVersion,
  });
}

class AndroidVersionPageFailure extends AndroidVersionPageState {
  AndroidVersionPageFailure();
}
