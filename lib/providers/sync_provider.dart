import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/sync_bridge/discovery_service.dart';
import '../features/sync_bridge/sync_service.dart';
import 'app_providers.dart';

// ══════════════════════════════════════════════════════════
//  SYNC STATE
// ══════════════════════════════════════════════════════════

enum SyncRole { none, leader, follower }

class SyncState {
  final SyncRole role;
  final bool isConnected;
  final int followerCount;
  final String? leaderName;
  final String? leaderIp;

  const SyncState({
    this.role = SyncRole.none,
    this.isConnected = false,
    this.followerCount = 0,
    this.leaderName,
    this.leaderIp,
  });

  SyncState copyWith({
    SyncRole? role,
    bool? isConnected,
    int? followerCount,
    String? leaderName,
    String? leaderIp,
  }) {
    return SyncState(
      role: role ?? this.role,
      isConnected: isConnected ?? this.isConnected,
      followerCount: followerCount ?? this.followerCount,
      leaderName: leaderName ?? this.leaderName,
      leaderIp: leaderIp ?? this.leaderIp,
    );
  }
}

class SyncNotifier extends StateNotifier<SyncState> {
  final Ref ref;
  final SyncDiscovery _discovery = SyncDiscovery();
  final SyncServer _server = SyncServer();
  SyncClient? _client;

  static const int syncPort = 8085;

  SyncNotifier(this.ref) : super(const SyncState());

  // ── Leader Mode ──────────────────────────────────────

  Future<void> startAsLeader(String name) async {
    await _server.start(syncPort);
    _discovery.startLeaderBroadcast(name);
    state = state.copyWith(
      role: SyncRole.leader,
      isConnected: true,
      leaderName: name,
    );
  }

  /// Broadcast current performance state to all followers
  void broadcastState() {
    final perf = ref.read(performanceProvider);
    _server.broadcast({
      'type': 'SYNC_STATE',
      'songId': perf.currentSongId,
      'songIndex': perf.currentSongIndex,
      'transposeOffset': perf.transposeOffset,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // ── Follower Mode ────────────────────────────────────

  Future<void> startAsFollower() async {
    _discovery.startFollowerDiscovery((ip, name) {
      if (state.role == SyncRole.follower && !state.isConnected) {
        _connectToLeader(ip, name);
      }
    });
    state = state.copyWith(role: SyncRole.follower);
  }

  Future<void> _connectToLeader(String ip, String name) async {
    _client = SyncClient();

    // Wire up sync state callback to drive performance on follower
    _client!.onSyncState = (data) {
      final perf = ref.read(performanceProvider.notifier);
      final songIndex = data['songIndex'] as int?;
      final transposeOffset = data['transposeOffset'] as int?;

      if (songIndex != null) {
        perf.goToSong(songIndex);
      }
      if (transposeOffset != null) {
        perf.setTranspose(transposeOffset);
      }
    };

    await _client!.connect(ip, syncPort);
    state = state.copyWith(
      isConnected: true,
      leaderName: name,
      leaderIp: ip,
    );

    // Watch for disconnection
    _client!.addListener(() {
      if (!_client!.isConnected) {
        state = state.copyWith(isConnected: false);
      }
    });
  }

  // ── Disconnect ───────────────────────────────────────

  void disconnect() {
    _discovery.stop();
    _server.stop();
    _client?.disconnect();
    _client = null;
    state = const SyncState();
  }
}

final syncProvider =
    StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  return SyncNotifier(ref);
});
