import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class SyncDiscovery extends ChangeNotifier {
  static const int discoveryPort = 8084;
  RawDatagramSocket? _socket;
  Timer? _broadcastTimer;
  bool isSearching = false;

  /// Start broadcasting presence as a Leader
  Future<void> startLeaderBroadcast(String leaderName) async {
    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    _socket?.broadcastEnabled = true;

    isSearching = true;
    notifyListeners();

    void broadcast() {
      final message = jsonEncode({
        'type': 'OP_LEADER_ANN',
        'name': leaderName,
        'timestamp': DateTime.now().toIso8601String(),
      });
      _socket?.send(utf8.encode(message), InternetAddress('255.255.255.255'), discoveryPort);
    }

    // Broadcast immediately, then every 3 seconds
    broadcast();
    _broadcastTimer = Timer.periodic(const Duration(seconds: 3), (_) => broadcast());
  }

  /// Start listening for a Leader as a Follower
  Future<void> startFollowerDiscovery(Function(String ip, String name) onLeaderFound) async {
    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, discoveryPort);
    
    _socket?.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        final datagram = _socket?.receive();
        if (datagram != null) {
          try {
            final data = jsonDecode(utf8.decode(datagram.data));
            if (data['type'] == 'OP_LEADER_ANN') {
              onLeaderFound(datagram.address.address, data['name']);
            }
          } catch (e) {
            debugPrint('Failed to decode discovery packet: $e');
          }
        }
      }
    });
  }

  void stop() {
    isSearching = false;
    _broadcastTimer?.cancel();
    _broadcastTimer = null;
    _socket?.close();
    _socket = null;
    notifyListeners();
  }
}
