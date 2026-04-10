import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


/// Remote sync service using Supabase Realtime Broadcast.
///
/// Leader creates a room (6-digit code), followers join with the code.
/// All sync state flows through the broadcast channel.
class RemoteSyncService extends ChangeNotifier {
  RealtimeChannel? _channel;
  String? _roomCode;
  bool _isConnected = false;

  bool get isConnected => _isConnected;
  String? get roomCode => _roomCode;

  /// Callback for followers to receive sync state from leader
  void Function(Map<String, dynamic> data)? onSyncState;

  /// Callback when a follower joins (leader gets notified)
  void Function(String followerName)? onFollowerJoined;

  // ── Leader: Create Room ──────────────────────────────

  /// Start a room as leader. Returns the room code.
  String createRoom(String leaderName) {
    _roomCode = _generateRoomCode();
    final channelName = 'open-praise-$_roomCode';

    _channel = Supabase.instance.client.channel(channelName);

    _channel!
        .onBroadcast(
          event: 'follower_join',
          callback: (payload) {
            final name = payload['name'] as String? ?? 'Unknown';
            debugPrint('RemoteSync: Follower joined: $name');
            onFollowerJoined?.call(name);
          },
        )
        .subscribe((status, error) {
      if (status == RealtimeSubscribeStatus.subscribed) {
        _isConnected = true;
        notifyListeners();
        debugPrint('RemoteSync: Leader room $_roomCode is live');
      }
    });

    return _roomCode!;
  }

  /// Broadcast current performance state to all followers
  void broadcastState({
    required String? songId,
    required int songIndex,
    required int transposeOffset,
  }) {
    _channel?.sendBroadcastMessage(
      event: 'sync_state',
      payload: {
        'type': 'SYNC_STATE',
        'songId': songId,
        'songIndex': songIndex,
        'transposeOffset': transposeOffset,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // ── Follower: Join Room ──────────────────────────────

  /// Join an existing room as a follower.
  void joinRoom(String code, String followerName) {
    _roomCode = code.toUpperCase().trim();
    final channelName = 'open-praise-$_roomCode';

    _channel = Supabase.instance.client.channel(channelName);

    _channel!
        .onBroadcast(
          event: 'sync_state',
          callback: (payload) {
            if (payload['type'] == 'SYNC_STATE') {
              onSyncState?.call(payload);
            }
          },
        )
        .subscribe((status, error) {
      if (status == RealtimeSubscribeStatus.subscribed) {
        _isConnected = true;
        notifyListeners();
        debugPrint('RemoteSync: Joined room $_roomCode');

        // Announce ourselves to the leader
        _channel!.sendBroadcastMessage(
          event: 'follower_join',
          payload: {'name': followerName},
        );
      }
    });
  }

  // ── Disconnect ───────────────────────────────────────

  void disconnect() {
    _channel?.unsubscribe();
    _channel = null;
    _roomCode = null;
    _isConnected = false;
    onSyncState = null;
    onFollowerJoined = null;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────

  static String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no I/O/0/1 confusion
    final rng = Random.secure();
    return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  }
}
