part of 'ios_device_info_cubit.dart';

@immutable
class IosDeviceInfoState {
  String brand;
  String model;
  String systemVersion;
  String identifierForVendor;
  bool isPhysicalDevice;

  String sysName;
  String nodeName;
  String release;
  String version;
  String machine;

  String resolution;
  String screenPt;
  String inch;
  String aspectRatio;
  String ppi;

  String wifiIp;
  String connectivities;
  String totalMemoryInGB;
  String storageInfo;

  IosDeviceInfoState(
      {required this.brand,
      required this.model,
      required this.systemVersion,
      required this.identifierForVendor,
      required this.isPhysicalDevice,
      required this.sysName,
      required this.nodeName,
      required this.release,
      required this.version,
      required this.machine,
      required this.resolution,
      required this.screenPt,
      required this.inch,
      required this.aspectRatio,
      required this.ppi,
      required this.wifiIp,
      required this.connectivities,
      required this.totalMemoryInGB,
      required this.storageInfo});

  IosDeviceInfoState.empty()
      : brand = '',
        model = '',
        systemVersion = '',
        identifierForVendor = '',
        isPhysicalDevice = false,
        sysName = '',
        nodeName = '',
        release = '',
        version = '',
        machine = '',
        resolution = '',
        screenPt = '',
        inch = '',
        aspectRatio = '',
        ppi = '',
        wifiIp = '',
        connectivities = '',
        totalMemoryInGB = '',
        storageInfo = '';

  IosDeviceInfoState copyWith({
    String? brand,
    String? model,
    String? systemVersion,
    String? identifierForVendor,
    bool? isPhysicalDevice,
    String? sysName,
    String? nodeName,
    String? release,
    String? version,
    String? machine,
    String? resolution,
    String? screenPt,
    String? inch,
    String? aspectRatio,
    String? ppi,
    String? wifiIp,
    String? connectivities,
    String? totalMemoryInGB,
    String? storageInfo,
  }) {
    return IosDeviceInfoState(
      brand: brand ?? this.brand,
      model: model ?? this.model,
      systemVersion: systemVersion ?? this.systemVersion,
      identifierForVendor: identifierForVendor ?? this.identifierForVendor,
      isPhysicalDevice: isPhysicalDevice ?? this.isPhysicalDevice,
      sysName: sysName ?? this.sysName,
      nodeName: nodeName ?? this.nodeName,
      release: release ?? this.release,
      version: version ?? this.version,
      machine: machine ?? this.machine,
      resolution: resolution ?? this.resolution,
      screenPt: screenPt ?? this.screenPt,
      inch: inch ?? this.inch,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      ppi: ppi ?? this.ppi,
      wifiIp: wifiIp ?? this.wifiIp,
      connectivities: connectivities ?? this.connectivities,
      totalMemoryInGB: totalMemoryInGB ?? this.totalMemoryInGB,
      storageInfo: storageInfo ?? this.storageInfo,
    );
  }
}
