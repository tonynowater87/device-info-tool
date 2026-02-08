/// 藍牙音訊裝置資訊模型
class BluetoothDeviceInfo {
  final String deviceName;
  final String deviceAddress;
  final int? batteryLevel; // -1 表示不支援
  final String bluetoothVersion; // 手機藍牙版本（由於 API 限制，固定為「不支援」）

  BluetoothDeviceInfo({
    required this.deviceName,
    required this.deviceAddress,
    this.batteryLevel,
    this.bluetoothVersion = '不支援',
  });

  factory BluetoothDeviceInfo.fromMap(Map<String, dynamic> map) {
    return BluetoothDeviceInfo(
      deviceName: map['deviceName'] as String? ?? 'Unknown',
      deviceAddress: map['deviceAddress'] as String? ?? 'Unknown',
      batteryLevel: map['batteryLevel'] as int?,
      // 藍牙版本無法透過 Android API 取得，固定為「不支援」
      // 參考 RESEARCH.md: "Android 沒有公開 API 取得藍牙版本號"
      bluetoothVersion: '不支援',
    );
  }

  String get formattedBatteryLevel {
    if (batteryLevel == null || batteryLevel! < 0) return '不支援';
    return '$batteryLevel%';
  }
}

/// 藍牙 Codec 資訊模型
class BluetoothCodecInfo {
  final String codecType;
  final String sampleRate;
  final String bitsPerSample;
  final String channelMode;
  final String bitrate; // 位元率（CODEC-04 需求）

  BluetoothCodecInfo({
    required this.codecType,
    required this.sampleRate,
    required this.bitsPerSample,
    required this.channelMode,
    required this.bitrate,
  });

  factory BluetoothCodecInfo.fromMap(Map<String, dynamic> map) {
    return BluetoothCodecInfo(
      codecType: map['codecType'] as String? ?? 'Unknown',
      sampleRate: map['sampleRate'] as String? ?? 'Unknown',
      bitsPerSample: map['bitsPerSample'] as String? ?? 'Unknown',
      channelMode: map['channelMode'] as String? ?? 'Unknown',
      bitrate: map['bitrate'] as String? ?? '不支援',
    );
  }
}

/// 完整的藍牙音訊資訊模型
class BluetoothAudioInfo {
  final BluetoothDeviceInfo deviceInfo;
  final BluetoothCodecInfo codecInfo;

  BluetoothAudioInfo({
    required this.deviceInfo,
    required this.codecInfo,
  });

  factory BluetoothAudioInfo.fromMap(Map<String, dynamic> map) {
    return BluetoothAudioInfo(
      deviceInfo: BluetoothDeviceInfo.fromMap(map),
      codecInfo: BluetoothCodecInfo.fromMap(map),
    );
  }
}
