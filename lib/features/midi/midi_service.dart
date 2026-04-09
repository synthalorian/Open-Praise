import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';

/// MIDI foot pedal / controller integration.
/// Maps MIDI CC or note messages to app actions.
typedef MidiAction = void Function();

class MidiService extends ChangeNotifier {
  final MidiCommand _midi = MidiCommand();
  StreamSubscription? _subscription;
  MidiDevice? _connectedDevice;
  bool isConnected = false;

  /// Action callbacks — set these from the performance screen
  MidiAction? onNext;
  MidiAction? onPrevious;
  MidiAction? onTransposeUp;
  MidiAction? onTransposeDown;

  /// Default MIDI mappings (configurable later)
  /// CC 64 (sustain pedal) = next song
  /// CC 67 (soft pedal) = previous song
  /// Note 60 (middle C) = next
  /// Note 59 (B3) = previous
  static const int ccNext = 64;
  static const int ccPrevious = 67;
  static const int noteNext = 60;
  static const int notePrevious = 59;

  Future<List<MidiDevice>> scanDevices() async {
    return await _midi.devices ?? [];
  }

  Future<void> connectToDevice(MidiDevice device) async {
    await _midi.connectToDevice(device);
    _connectedDevice = device;
    isConnected = true;
    notifyListeners();
    _startListening();
  }

  void _startListening() {
    _subscription = _midi.onMidiDataReceived?.listen((data) {
      _handleMidiMessage(data);
    });
  }

  void _handleMidiMessage(MidiPacket packet) {
    final data = packet.data;
    if (data.length < 3) return;

    final status = data[0] & 0xF0;
    final value = data[1];
    final velocity = data[2];

    switch (status) {
      case 0xB0: // Control Change
        if (velocity > 63) {
          // CC on
          if (value == ccNext) onNext?.call();
          if (value == ccPrevious) onPrevious?.call();
        }
        break;
      case 0x90: // Note On
        if (velocity > 0) {
          if (value == noteNext) onNext?.call();
          if (value == notePrevious) onPrevious?.call();
          // Transpose: Note 62 = up, Note 61 = down
          if (value == 62) onTransposeUp?.call();
          if (value == 61) onTransposeDown?.call();
        }
        break;
    }
  }

  void disconnect() {
    _subscription?.cancel();
    if (_connectedDevice != null) {
      _midi.disconnectDevice(_connectedDevice!);
    }
    _connectedDevice = null;
    isConnected = false;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
