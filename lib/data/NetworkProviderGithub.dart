import 'dart:convert';
import 'dart:io';

import 'package:device_info_tool/data/NetworkProvider.dart';
import 'package:device_info_tool/data/model/MobileDistribution.dart';
import 'package:device_info_tool/data/model/VersionModelAndroid.dart';
import 'package:device_info_tool/data/model/VersionModelAndroidWearOS.dart';
import 'package:device_info_tool/data/model/VersionModelIOS.dart';
import 'package:device_info_tool/data/model/VersionModelTvOS.dart';
import 'package:device_info_tool/data/model/VersionModelWatchOS.dart';
import 'package:device_info_tool/data/model/VesionModelMacOS.dart';
import 'package:http/http.dart' as http;

class NetworkProviderGithub extends NetworkProvider {
  static String baseUrl =
      "https://raw.githubusercontent.com/tonynowater87/mobile-os-versions/main/resources";

  late HttpClient httpClient;

  NetworkProviderGithub({
    required this.httpClient,
  });

  @override
  Future<List<VersionModelAndroid>> getAndroidVersions() async {
    List<VersionModelAndroid> models = [];
    try {
      final response =
      await http.get(Uri.parse("$baseUrl/android-os-versions.json"));
      final List<dynamic> entities = json.decode(response.body);
      models = entities.map((e) => VersionModelAndroid.fromJson(e)).toList();
    } finally {
      httpClient.close();
    }
    return Future.value(models);
  }

  @override
  Future<List<VersionModeliOs>> getIOSVersions() async {
    List<VersionModeliOs> models = [];
    try {
      final response =
      await http.get(Uri.parse("$baseUrl/ios-os-versions.json"));
      final List<dynamic> entities = json.decode(response.body);
      models = entities.map((e) => VersionModeliOs.fromJson(e)).toList();
    } finally {
      httpClient.close();
    }
    return Future.value(models);
  }

  @override
  Future<List<VersionModeliOs>> getIPadOSVersions() async {
    List<VersionModeliOs> models = [];
    try {
      final response =
      await http.get(Uri.parse("$baseUrl/ipad-os-versions.json"));
      final List<dynamic> entities = json.decode(response.body);
      models = entities.map((e) => VersionModeliOs.fromJson(e)).toList();
    } finally {
      httpClient.close();
    }
    return Future.value(models);
  }

  @override
  Future<List<VersionModelAndroidWearOs>> getAndroidWearOSVersions() async {
    List<VersionModelAndroidWearOs> models = [];
    try {
      final response =
      await http.get(Uri.parse("$baseUrl/wear-os-versions.json"));
      final List<dynamic> entities = json.decode(response.body);
      models =
          entities.map((e) => VersionModelAndroidWearOs.fromJson(e)).toList();
    } finally {
      httpClient.close();
    }
    return Future.value(models);
  }

  @override
  Future<List<VesionModelMacOs>> getMacOSVersions() async {
    List<VesionModelMacOs> models = [];
    try {
      final response =
      await http.get(Uri.parse("$baseUrl/mac-os-versions.json"));
      final List<dynamic> entities = json.decode(response.body);
      models = entities.map((e) => VesionModelMacOs.fromJson(e)).toList();
    } finally {
      httpClient.close();
    }
    return Future.value(models);
  }

  @override
  Future<List<VersionModelTvOs>> getTvOSVersions() async {
    List<VersionModelTvOs> models = [];
    try {
      final response =
      await http.get(Uri.parse("$baseUrl/tv-os-versions.json"));
      final List<dynamic> entities = json.decode(response.body);
      models = entities.map((e) => VersionModelTvOs.fromJson(e)).toList();
    } finally {
      httpClient.close();
    }
    return Future.value(models);
  }

  @override
  Future<List<VersionModelWatchOs>> getWatchOSVersions() async {
    List<VersionModelWatchOs> models = [];
    try {
      final response =
      await http.get(Uri.parse("$baseUrl/watch-os-versions.json"));
      final List<dynamic> entities = json.decode(response.body);
      models = entities.map((e) => VersionModelWatchOs.fromJson(e)).toList();
    } finally {
      httpClient.close();
    }
    return Future.value(models);
  }

  @override
  Future<MobileDistribution?> getAndroidDistribution() async {
    MobileDistribution model;
    try {
      final response =
          await http.get(Uri.parse("$baseUrl/android-distribution.json"));
      List<dynamic> entities = jsonDecode(response.body);
      entities[0] = {'最後更新': entities[0]['最後更新']};
      entities[1] = {'版本分佈': entities[1]['版本分佈']};
      entities[2] = {'累積分佈': entities[2]['累積分佈']};
      model =
          MobileDistribution.fromJson(entities.cast<Map<String, dynamic>>());
    } finally {
      httpClient.close();
    }
    return Future.value(model);
  }

  @override
  Future<MobileDistribution?> getIOSDistribution() async {
    MobileDistribution model;
    try {
      final response =
          await http.get(Uri.parse("$baseUrl/ios-distribution.json"));
      List<dynamic> entities = jsonDecode(response.body);
      entities[0] = {'最後更新': entities[0]['最後更新']};
      entities[1] = {'版本分佈': entities[1]['版本分佈']};
      entities[2] = {'累積分佈': entities[2]['累積分佈']};
      model =
          MobileDistribution.fromJson(entities.cast<Map<String, dynamic>>());
    } finally {
      httpClient.close();
    }
    return Future.value(model);
  }
}