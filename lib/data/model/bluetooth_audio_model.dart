/// Codec 選項（下拉選單用）
class CodecOption {
  final int value;
  final String label;

  CodecOption({required this.value, required this.label});

  factory CodecOption.fromMap(Map<String, dynamic> map) {
    return CodecOption(
      value: map['value'] as int,
      label: map['label'] as String,
    );
  }
}

/// Codec 可選能力（裝置支援的選項清單）
class CodecCapabilities {
  final List<CodecOption> sampleRates;
  final List<CodecOption> bitsPerSample;
  final List<CodecOption> channelModes;
  final List<CodecOption> codecTypes;

  CodecCapabilities({
    required this.sampleRates,
    required this.bitsPerSample,
    required this.channelModes,
    required this.codecTypes,
  });

  factory CodecCapabilities.fromMap(Map<String, dynamic> map) {
    return CodecCapabilities(
      sampleRates: map.containsKey('selectableSampleRates')
          ? (map['selectableSampleRates'] as List)
              .map((e) => CodecOption.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList()
          : [],
      bitsPerSample: map.containsKey('selectableBitsPerSample')
          ? (map['selectableBitsPerSample'] as List)
              .map((e) => CodecOption.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList()
          : [],
      channelModes: map.containsKey('selectableChannelModes')
          ? (map['selectableChannelModes'] as List)
              .map((e) => CodecOption.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList()
          : [],
      codecTypes: map.containsKey('selectableCodecTypes')
          ? (map['selectableCodecTypes'] as List)
              .map((e) => CodecOption.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList()
          : [],
    );
  }
}

/// Codec 原始數值（用於建構 setCodecConfig 請求）
class CodecRawValues {
  final int codecType;
  final int sampleRate;
  final int bitsPerSample;
  final int channelMode;
  final int codecSpecific1;

  CodecRawValues({
    required this.codecType,
    required this.sampleRate,
    required this.bitsPerSample,
    required this.channelMode,
    required this.codecSpecific1,
  });

  factory CodecRawValues.fromMap(Map<String, dynamic> map) {
    return CodecRawValues(
      codecType: map['currentCodecType'] as int,
      sampleRate: map['currentSampleRate'] as int,
      bitsPerSample: map['currentBitsPerSample'] as int,
      channelMode: map['currentChannelMode'] as int,
      codecSpecific1: (map['currentCodecSpecific1'] as num).toInt(),
    );
  }
}

/// 藍牙音訊裝置資訊模型
class BluetoothDeviceInfo {
  final String deviceName;
  final String deviceAddress;
  final int? batteryLevel; // -1 表示不支援
  final String bluetoothVersion; // 手機藍牙版本（透過 API 能力推斷）

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
      bluetoothVersion: map['bluetoothVersion'] as String? ?? '不支援',
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
  final CodecCapabilities? capabilities;
  final CodecRawValues? rawValues;

  BluetoothAudioInfo({
    required this.deviceInfo,
    required this.codecInfo,
    this.capabilities,
    this.rawValues,
  });

  factory BluetoothAudioInfo.fromMap(Map<String, dynamic> map) {
    CodecCapabilities? capabilities;
    CodecRawValues? rawValues;

    if (map.containsKey('selectableSampleRates') || map.containsKey('selectableCodecTypes')) {
      capabilities = CodecCapabilities.fromMap(map);
    }
    if (map.containsKey('currentCodecType')) {
      rawValues = CodecRawValues.fromMap(map);
    }

    return BluetoothAudioInfo(
      deviceInfo: BluetoothDeviceInfo.fromMap(map),
      codecInfo: BluetoothCodecInfo.fromMap(map),
      capabilities: capabilities,
      rawValues: rawValues,
    );
  }
}
