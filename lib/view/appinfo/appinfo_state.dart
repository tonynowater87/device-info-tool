part of 'appinfo_cubit.dart';

@immutable
abstract class AppInfoState {}

class AppInfoInitial extends AppInfoState {}

class AppInfoLoaded extends AppInfoState {
  String appName;
  String appVersion;
  String githubLink;

  AppInfoLoaded({
    required this.appName,
    required this.appVersion,
    required this.githubLink,
  });
}
