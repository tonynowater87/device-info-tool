part of 'android_wear_os_version_page_cubit.dart';

@immutable
abstract class AndroidWearOSVersionPageState {}

class AndroidWearVersionPageInitial extends AndroidWearOSVersionPageState {}

class AndroidWearVersionPageSuccess extends AndroidWearOSVersionPageState {
  final List<VersionModelAndroidWearOs> data;

  AndroidWearVersionPageSuccess({required this.data});
}

class AndroidWearVersionPageFailure extends AndroidWearOSVersionPageState {
  AndroidWearVersionPageFailure();
}
