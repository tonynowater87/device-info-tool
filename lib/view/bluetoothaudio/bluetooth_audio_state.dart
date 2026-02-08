part of 'bluetooth_audio_cubit.dart';

/// 藍牙音訊頁面狀態基類
abstract class BluetoothAudioState {}

/// 初始狀態
class BluetoothAudioInitial extends BluetoothAudioState {}

/// 載入中
class BluetoothAudioLoading extends BluetoothAudioState {}

/// 需要權限
class BluetoothAudioPermissionRequired extends BluetoothAudioState {}

/// 權限被拒絕
class BluetoothAudioPermissionDenied extends BluetoothAudioState {
  final bool isPermanentlyDenied;
  BluetoothAudioPermissionDenied({this.isPermanentlyDenied = false});
}

/// 不支援（Android 8.0 以下）
class BluetoothAudioNotSupported extends BluetoothAudioState {
  final String reason;
  BluetoothAudioNotSupported({required this.reason});
}

/// 藍牙未開啟
class BluetoothAudioBluetoothDisabled extends BluetoothAudioState {}

/// 無已連接裝置
class BluetoothAudioNoDevice extends BluetoothAudioState {}

/// 載入成功
class BluetoothAudioLoaded extends BluetoothAudioState {
  final BluetoothAudioInfo audioInfo;
  BluetoothAudioLoaded({required this.audioInfo});
}

/// 載入失敗
class BluetoothAudioError extends BluetoothAudioState {
  final String message;
  BluetoothAudioError({required this.message});
}
