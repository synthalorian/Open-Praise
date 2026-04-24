// Quick smoke test for SyncBridge UDP discovery on localhost
// Run: dart test\sync_bridge_discovery_smoke_test.dart

import 'dart:async';
import 'dart:io';
import 'dart:convert';

const int discoveryPort = 8084;
const String testLeader = 'SMOKE_TEST_LEADER';
final testAddr = InternetAddress('127.255.255.255');

Future<void> main() async {
  print('🎹🦞 SyncBridge UDP Discovery Smoke Test');
  print('Listening on UDP port $discoveryPort ...');

  // 1. Bind listener (Follower mode)
  final receiver = await RawDatagramSocket.bind(InternetAddress.anyIPv4, discoveryPort);
  receiver.broadcastEnabled = true;

  final completer = Completer<bool>();
  int foundCount = 0;

  receiver.listen((event) {
    if (event == RawSocketEvent.read) {
      final dg = receiver.receive();
      if (dg != null) {
        try {
          final msg = jsonDecode(utf8.decode(dg.data)) as Map<String, dynamic>;
          if (msg['type'] == 'OP_LEADER_ANN') {
            foundCount++;
            print('  ✅ Received: ${msg['name']} from ${dg.address.address}');
            if (msg['name'] == testLeader && !completer.isCompleted) {
              completer.complete(true);
            }
          }
        } catch (e) {
          print('  ❌ Decode error: $e');
        }
      }
    }
  });

  // 2. Send broadcast (Leader mode) after a short delay
  final sender = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
  sender.broadcastEnabled = true;

  final beacon = jsonEncode({
    'type': 'OP_LEADER_ANN',
    'name': testLeader,
    'timestamp': DateTime.now().toIso8601String(),
  });

  // Allow listener to be ready
  await Future.delayed(Duration(milliseconds: 200));

  print('  📡 Broadcasting discovery packet...');
  sender.send(utf8.encode(beacon), testAddr, discoveryPort);

  // 3. Wait for result (5s timeout)
  Future<bool> timedFuture = completer.future.timeout(Duration(seconds: 5));
  bool success;
  try {
    success = await timedFuture;
  } on TimeoutException {
    success = false;
  }
  if (!success) {
    print('  ⏰ Timeout — no discovery packet received.');
  }

  sender.close();
  receiver.close();

  if (success) {
    print('\n✅ PASS — SyncBridge UDP discovery works on this machine.');
  } else {
    print('\n❌ FAIL — Discovery packet was not received.');
  }

  exit(success ? 0 : 1);
}
