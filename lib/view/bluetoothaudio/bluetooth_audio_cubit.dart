import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_tool/data/model/bluetooth_audio_model.dart';

part 'bluetooth_audio_state.dart';

class BluetoothAudioCubit extends Cubit<BluetoothAudioState> {
  static const _channel = MethodChannel('com.tonynowater.mobileosversions');

  BluetoothAudioCubit() : super(BluetoothAudioInitial());

  Future<void> load() async {
    emit(BluetoothAudioLoading());

    // 檢查平台
    if (!Platform.isAndroid) {
      emit(BluetoothAudioNotSupported(reason: '僅支援 Android 平台'));
      return;
    }

    // 檢查 Android 版本（使用專案現有的 device_info_plus 依賴）
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt < 26) {
      emit(BluetoothAudioNotSupported(reason: 'Android 8.0 以下不支援'));
      return;
    }

    // 檢查並請求權限（Android 12+）
    if (androidInfo.version.sdkInt >= 31) {
      final permissionStatus = await Permission.bluetoothConnect.status;

      if (permissionStatus.isDenied) {
        final result = await Permission.bluetoothConnect.request();
        if (result.isDenied) {
          emit(BluetoothAudioPermissionDenied(isPermanentlyDenied: false));
          return;
        }
        if (result.isPermanentlyDenied) {
          emit(BluetoothAudioPermissionDenied(isPermanentlyDenied: true));
          return;
        }
      }

      if (permissionStatus.isPermanentlyDenied) {
        emit(BluetoothAudioPermissionDenied(isPermanentlyDenied: true));
        return;
      }
    }

    // 呼叫原生端取得資訊
    try {
      final result = await _channel.invokeMethod('getBluetoothAudioInfo');
      final map = Map<String, dynamic>.from(result as Map);

      // 檢查錯誤回應
      if (map.containsKey('error')) {
        final error = map['error'] as String;
        switch (error) {
          case 'unsupported':
            emit(BluetoothAudioNotSupported(reason: map['reason'] as String? ?? '不支援'));
            break;
          case 'bluetooth_disabled':
            emit(BluetoothAudioBluetoothDisabled());
            break;
          case 'no_device':
            emit(BluetoothAudioNoDevice());
            break;
          default:
            // 顯示詳細錯誤訊息（包含 reason）
            final reason = map['reason'] as String?;
            emit(BluetoothAudioError(message: reason ?? error));
        }
        return;
      }

      // 解析成功回應
      final audioInfo = BluetoothAudioInfo.fromMap(map);
      emit(BluetoothAudioLoaded(audioInfo: audioInfo));
    } on PlatformException catch (e) {
      emit(BluetoothAudioError(message: e.message ?? '未知錯誤'));
    } catch (e) {
      emit(BluetoothAudioError(message: e.toString()));
    }
  }

  /// 設定 codec 參數
  Future<void> setCodecConfig({
    int? codecType,
    required int sampleRate,
    required int bitsPerSample,
    required int channelMode,
    required int codecSpecific1,
  }) async {
    // 取得當前 audioInfo
    BluetoothAudioInfo? currentAudioInfo;
    if (state is BluetoothAudioLoaded) {
      currentAudioInfo = (state as BluetoothAudioLoaded).audioInfo;
    } else if (state is BluetoothAudioSettingCodec) {
      currentAudioInfo = (state as BluetoothAudioSettingCodec).audioInfo;
    } else if (state is BluetoothAudioCodecSetError) {
      currentAudioInfo = (state as BluetoothAudioCodecSetError).audioInfo;
    }

    if (currentAudioInfo == null || currentAudioInfo.rawValues == null) return;

    emit(BluetoothAudioSettingCodec(audioInfo: currentAudioInfo));

    try {
      final result = await _channel.invokeMethod('setBluetoothCodecConfig', {
        'codecType': codecType ?? currentAudioInfo.rawValues!.codecType,
        'sampleRate': sampleRate,
        'bitsPerSample': bitsPerSample,
        'channelMode': channelMode,
        'codecSpecific1': codecSpecific1,
      });

      final map = Map<String, dynamic>.from(result as Map);
      if (map['success'] == true) {
        // 等待系統套用設定後重新載入
        await Future.delayed(const Duration(milliseconds: 500));
        await load();
      } else {
        final error = map['error'] as String? ?? '未知錯誤';
        emit(BluetoothAudioCodecSetError(
          message: error,
          audioInfo: currentAudioInfo,
        ));
      }
    } on PlatformException catch (e) {
      emit(BluetoothAudioCodecSetError(
        message: e.message ?? '未知錯誤',
        audioInfo: currentAudioInfo,
      ));
    } catch (e) {
      emit(BluetoothAudioCodecSetError(
        message: e.toString(),
        audioInfo: currentAudioInfo,
      ));
    }
  }

  /// 開啟應用程式設定頁面（用於永久拒絕權限的情況）
  Future<void> openSettings() async {
    await openAppSettings();
  }

  /// 重新嘗試載入
  Future<void> retry() async {
    await load();
  }
}
