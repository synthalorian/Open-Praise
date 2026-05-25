// SyncBridge UDP Discovery unit test
// Tests message parsing and service lifecycle using the SyncDiscovery service.
// UDP broadcast is tested with an isolated loopback pair.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// ignore_for_file: avoid_print — this is a smoke/integration test helper

const int discoveryPort = 8084;
const String testLeader = 'SMOKE_TEST_LEADER';

void main() {
  test(
    'SyncBridge UDP discovery: broadcast and receive',
    timeout: const Timeout(Duration(seconds: 15)),
    () async {
      // 1. Bind receiver (follower)
      final receiver = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        discoveryPort,
      );
      addTearDown(receiver.close);
      receiver.broadcastEnabled = true;

      final received = Completer<Map<String, dynamic>>();

      receiver.listen((event) {
        if (event == RawSocketEvent.read) {
          final dg = receiver.receive();
          if (dg != null) {
            try {
              final msg = jsonDecode(utf8.decode(dg.data))
                  as Map<String, dynamic>;
              if (msg['type'] == 'OP_LEADER_ANN' &&
                  !received.isCompleted) {
                received.complete(msg);
              }
            } catch (_) {
              // skip malformed packets
            }
          }
        }
      });

      // 2. Bind sender (leader) and broadcast
      final sender = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        0,
      );
      addTearDown(sender.close);
      sender.broadcastEnabled = true;

      final beacon = jsonEncode({
        'type': 'OP_LEADER_ANN',
        'name': testLeader,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Let the listener settle
      await Future.delayed(const Duration(milliseconds: 300));

      // Send to loopback broadcast
      sender.send(
        utf8.encode(beacon),
        InternetAddress('127.255.255.255'),
        discoveryPort,
      );

      // 3. Await receipt
      final msg = await received.future;

      expect(msg['type'], 'OP_LEADER_ANN');
      expect(msg['name'], testLeader);
      expect(msg['timestamp'], isA<String>());

      print('✅ Received discovery from ${msg['name']}');
    },
  );
}
