import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:device_info_tool/l10n/app_localizations.dart';
import 'package:device_info_tool/view/bluetoothaudio/bluetooth_audio_cubit.dart';
import 'package:device_info_tool/data/model/bluetooth_audio_model.dart';

class BluetoothAudioPage extends StatefulWidget {
  const BluetoothAudioPage({Key? key}) : super(key: key);

  @override
  State<BluetoothAudioPage> createState() => _BluetoothAudioPageState();
}

class _BluetoothAudioPageState extends State<BluetoothAudioPage> {
  @override
  void initState() {
    super.initState();
    context.read<BluetoothAudioCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BluetoothAudioCubit, BluetoothAudioState>(
      builder: (context, state) {
        return _buildContent(context, state);
      },
    );
  }

  Widget _buildContent(BuildContext context, BluetoothAudioState state) {
    if (state is BluetoothAudioLoading || state is BluetoothAudioInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is BluetoothAudioNotSupported) {
      return _buildNotSupportedView(context, state.reason);
    }

    if (state is BluetoothAudioPermissionDenied) {
      return _buildPermissionDeniedView(context, state.isPermanentlyDenied);
    }

    if (state is BluetoothAudioPermissionRequired) {
      return _buildPermissionRequiredView(context);
    }

    if (state is BluetoothAudioBluetoothDisabled) {
      return _buildBluetoothDisabledView(context);
    }

    if (state is BluetoothAudioNoDevice) {
      return _buildNoDeviceView(context);
    }

    if (state is BluetoothAudioError) {
      return _buildErrorView(context, state.message);
    }

    if (state is BluetoothAudioSettingCodec) {
      return _buildLoadedView(context, state.audioInfo, isSettingCodec: true);
    }

    if (state is BluetoothAudioCodecSetError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      });
      return _buildLoadedView(context, state.audioInfo);
    }

    if (state is BluetoothAudioLoaded) {
      return _buildLoadedView(context, state.audioInfo);
    }

    return const SizedBox.shrink();
  }

  Widget _buildNotSupportedView(BuildContext context, String reason) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              l10n.bluetoothNotSupported,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(reason, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionDeniedView(BuildContext context, bool isPermanentlyDenied) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bluetooth_disabled, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              l10n.bluetoothPermissionRequired,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isPermanentlyDenied
                  ? l10n.bluetoothPermissionPermanentlyDenied
                  : l10n.bluetoothPermissionDenied,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (isPermanentlyDenied) {
                  context.read<BluetoothAudioCubit>().openSettings();
                } else {
                  context.read<BluetoothAudioCubit>().retry();
                }
              },
              child: Text(isPermanentlyDenied ? l10n.openSettings : l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionRequiredView(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bluetooth, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              l10n.bluetoothPermissionRequired,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<BluetoothAudioCubit>().retry(),
              child: Text(l10n.requestPermission),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBluetoothDisabledView(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bluetooth_disabled, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              l10n.bluetoothDisabled,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(l10n.bluetoothDisabledHint, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<BluetoothAudioCubit>().retry(),
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDeviceView(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.headphones_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              l10n.noBluetoothDevice,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(l10n.noBluetoothDeviceHint, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<BluetoothAudioCubit>().retry(),
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              l10n.error,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<BluetoothAudioCubit>().retry(),
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedView(BuildContext context, BluetoothAudioInfo audioInfo, {bool isSettingCodec = false}) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<BluetoothAudioCubit>();
    final capabilities = audioInfo.capabilities;
    final rawValues = audioInfo.rawValues;
    final hasCapabilities = capabilities != null && rawValues != null;

    return RefreshIndicator(
      onRefresh: () => cubit.retry(),
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // 裝置資訊區塊
              _buildSectionHeader(context, l10n.deviceInfo, Icons.headphones),
              _buildInfoCard(context, [
                _buildInfoRow(l10n.deviceName, audioInfo.deviceInfo.deviceName),
                _buildInfoRow(l10n.macAddress, audioInfo.deviceInfo.deviceAddress),
                _buildInfoRow(l10n.bluetoothVersion, audioInfo.deviceInfo.bluetoothVersion),
                _buildInfoRow(l10n.batteryLevel, audioInfo.deviceInfo.formattedBatteryLevel),
              ]),
              const SizedBox(height: 16),
              // Codec 資訊區塊
              _buildSectionHeader(context, l10n.codecInfo, Icons.audiotrack),
              _buildInfoCard(context, [
                // codecType 永遠靜態顯示
                _buildInfoRow(l10n.codecType, audioInfo.codecInfo.codecType),
                // sampleRate
                if (hasCapabilities && capabilities.sampleRates.length > 1)
                  _buildDropdownRow(
                    l10n.sampleRate,
                    rawValues.sampleRate,
                    capabilities.sampleRates,
                    isSettingCodec ? null : (value) {
                      if (value != null) {
                        cubit.setCodecConfig(
                          sampleRate: value,
                          bitsPerSample: rawValues.bitsPerSample,
                          channelMode: rawValues.channelMode,
                          codecSpecific1: rawValues.codecSpecific1,
                        );
                      }
                    },
                  )
                else
                  _buildInfoRow(l10n.sampleRate, audioInfo.codecInfo.sampleRate),
                // bitsPerSample
                if (hasCapabilities && capabilities.bitsPerSample.length > 1)
                  _buildDropdownRow(
                    l10n.bitsPerSample,
                    rawValues.bitsPerSample,
                    capabilities.bitsPerSample,
                    isSettingCodec ? null : (value) {
                      if (value != null) {
                        cubit.setCodecConfig(
                          sampleRate: rawValues.sampleRate,
                          bitsPerSample: value,
                          channelMode: rawValues.channelMode,
                          codecSpecific1: rawValues.codecSpecific1,
                        );
                      }
                    },
                  )
                else
                  _buildInfoRow(l10n.bitsPerSample, audioInfo.codecInfo.bitsPerSample),
                // channelMode
                if (hasCapabilities && capabilities.channelModes.length > 1)
                  _buildDropdownRow(
                    l10n.channelMode,
                    rawValues.channelMode,
                    capabilities.channelModes,
                    isSettingCodec ? null : (value) {
                      if (value != null) {
                        cubit.setCodecConfig(
                          sampleRate: rawValues.sampleRate,
                          bitsPerSample: rawValues.bitsPerSample,
                          channelMode: value,
                          codecSpecific1: rawValues.codecSpecific1,
                        );
                      }
                    },
                  )
                else
                  _buildInfoRow(l10n.channelMode, audioInfo.codecInfo.channelMode),
                // bitrate / LDAC quality
                if (hasCapabilities && rawValues.codecType == 4) // LDAC
                  _buildDropdownRow(
                    l10n.bitrate,
                    rawValues.codecSpecific1,
                    [
                      CodecOption(value: 1000, label: '990 kbps'),
                      CodecOption(value: 1001, label: '660 kbps'),
                      CodecOption(value: 1002, label: '330 kbps'),
                      CodecOption(value: 1003, label: 'ABR'),
                    ],
                    isSettingCodec ? null : (value) {
                      if (value != null) {
                        cubit.setCodecConfig(
                          sampleRate: rawValues.sampleRate,
                          bitsPerSample: rawValues.bitsPerSample,
                          channelMode: rawValues.channelMode,
                          codecSpecific1: value,
                        );
                      }
                    },
                  )
                else
                  _buildInfoRow(l10n.bitrate, audioInfo.codecInfo.bitrate),
              ]),
            ],
          ),
          if (isSettingCodec)
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildDropdownRow(String label, int currentValue, List<CodecOption> options, ValueChanged<int?>? onChanged) {
    // Ensure currentValue exists in options; if not, add it as fallback
    final hasCurrentValue = options.any((o) => o.value == currentValue);
    final effectiveOptions = hasCurrentValue
        ? options
        : [CodecOption(value: currentValue, label: 'Current ($currentValue)'), ...options];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: DropdownButton<int>(
                value: currentValue,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                alignment: AlignmentDirectional.centerEnd,
                items: effectiveOptions.map((option) {
                  return DropdownMenuItem<int>(
                    value: option.value,
                    child: Text(
                      option.label,
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
