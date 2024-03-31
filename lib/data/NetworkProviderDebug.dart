import 'dart:convert';

import 'package:device_info_tool/data/NetworkProvider.dart';
import 'package:device_info_tool/data/model/AndroidDistribution.dart';
import 'package:device_info_tool/data/model/VersionModelAndroid.dart';
import 'package:device_info_tool/data/model/VersionModelAndroidWearOS.dart';
import 'package:device_info_tool/data/model/VersionModelIOS.dart';
import 'package:device_info_tool/data/model/VersionModelTvOS.dart';
import 'package:device_info_tool/data/model/VersionModelWatchOS.dart';
import 'package:device_info_tool/data/model/VesionModelMacOS.dart';
import 'package:flutter/services.dart';

class NetworkProviderDebug extends NetworkProvider {
  @override
  Future<List<VersionModelAndroid>> getAndroidVersions() async {
    List<VersionModelAndroid> models = [];
    final response =
        await rootBundle.loadString('resources/android-os-versions.json');
    final List<dynamic> entities = json.decode(response);
    models = entities.map((e) => VersionModelAndroid.fromJson(e)).toList();
    return Future.value(models);
  }

  @override
  Future<List<VersionModelAndroidWearOs>> getAndroidWearOSVersions() async {
    List<VersionModelAndroidWearOs> models = [];
    final response =
        await rootBundle.loadString('resources/wear-os-versions.json');
    final List<dynamic> entities = json.decode(response);
    models =
        entities.map((e) => VersionModelAndroidWearOs.fromJson(e)).toList();
    return Future.value(models);
  }

  @override
  Future<List<VersionModeliOs>> getIOSVersions() async {
    List<VersionModeliOs> models = [];
    final response =
        await rootBundle.loadString('resources/ios-os-versions.json');
    final List<dynamic> entities = json.decode(response);
    models = entities.map((e) => VersionModeliOs.fromJson(e)).toList();
    return Future.value(models);
  }

  @override
  Future<List<VersionModeliOs>> getIPadOSVersions() async {
    List<VersionModeliOs> models = [];
    final response =
        await rootBundle.loadString('resources/ipad-os-versions.json');
    final List<dynamic> entities = json.decode(response);
    models = entities.map((e) => VersionModeliOs.fromJson(e)).toList();
    return Future.value(models);
  }

  @override
  Future<List<VesionModelMacOs>> getMacOSVersions() async {
    List<VesionModelMacOs> models = [];
    final response =
        await rootBundle.loadString('resources/mac-os-versions.json');
    final List<dynamic> entities = json.decode(response);
    models = entities.map((e) => VesionModelMacOs.fromJson(e)).toList();
    return Future.value(models);
  }

  @override
  Future<List<VersionModelTvOs>> getTvOSVersions() async {
    List<VersionModelTvOs> models = [];
    final response =
        await rootBundle.loadString('resources/tv-os-versions.json');
    final List<dynamic> entities = json.decode(response);
    models = entities.map((e) => VersionModelTvOs.fromJson(e)).toList();
    return Future.value(models);
  }

  @override
  Future<List<VersionModelWatchOs>> getWatchOSVersions() async {
    List<VersionModelWatchOs> models = [];
    final response =
        await rootBundle.loadString('resources/watch-os-versions.json');
    final List<dynamic> entities = json.decode(response);
    models = entities.map((e) => VersionModelWatchOs.fromJson(e)).toList();
    return Future.value(models);
  }

  @override
  Future<MobileDistribution?> getAndroidDistribution() async {
    final response =
        await rootBundle.loadString('resources/android-distribution.json');
    List<dynamic> entities = json.decode(response);
    entities[0] = {'最後更新': entities[0]['最後更新']};
    entities[1] = {'版本分佈': entities[1]['版本分佈']};
    entities[2] = {'累積分佈': entities[2]['累積分佈']};
    return Future.value(MobileDistribution.fromJson(entities.cast<Map<String, dynamic>>()));
  }

  @override
  Future<MobileDistribution?> getIOSDistribution() async {
    final response =
        await rootBundle.loadString('resources/ios-distribution.json');
    List<dynamic> entities = json.decode(response);
    entities[0] = {'最後更新': entities[0]['最後更新']};
    entities[1] = {'版本分佈': entities[1]['版本分佈']};
    entities[2] = {'累積分佈': entities[2]['累積分佈']};
    return Future.value(MobileDistribution.fromJson(entities.cast<Map<String, dynamic>>()));
  }
}
