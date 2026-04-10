import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/supabase_config.dart';
import '../features/sync_bridge/discovery_service.dart';
import '../features/sync_bridge/sync_service.dart';
import '../features/sync_bridge/remote_sync_service.dart';
import 'app_providers.dart';

// ══════════════════════════════════════════════════════════
//  SYNC STATE
// ══════════════════════════════════════════════════════════

enum SyncRole { none, leader, follower }
enum SyncMode { local, remote }

class SyncState {
  final SyncRole role;
  final SyncMode mode;
  final bool isConnected;
  final int followerCount;
  final String? leaderName;
  final String? leaderIp;
  final String? roomCode;

  const SyncState({
    this.role = SyncRole.none,
    this.mode = SyncMode.local,
    this.isConnected = false,
    this.followerCount = 0,
    this.leaderName,
    this.leaderIp,
    this.roomCode,
  });

  SyncState copyWith({
    SyncRole? role,
    SyncMode? mode,
    bool? isConnected,
    int? followerCount,
    String? leaderName,
    String? leaderIp,
    String? roomCode,
  }) {
    return SyncState(
      role: role ?? this.role,
      mode: mode ?? this.mode,
      isConnected: isConnected ?? this.isConnected,
      followerCount: followerCount ?? this.followerCount,
      leaderName: leaderName ?? this.leaderName,
      leaderIp: leaderIp ?? this.leaderIp,
      roomCode: roomCode ?? this.roomCode,
    );
  }

  bool get isRemote => mode == SyncMode.remote;
}

class SyncNotifier extends StateNotifier<SyncState> {
  final Ref ref;
  final SyncDiscovery _discovery = SyncDiscovery();
  final SyncServer _server = SyncServer();
  final RemoteSyncService _remote = RemoteSyncService();
  SyncClient? _client;

  static const int syncPort = 8085;

  SyncNotifier(this.ref) : super(const SyncState());

  /// Whether remote sync is available (Supabase configured)
  bool get remoteAvailable => SupabaseConfig.isConfigured;

  // ══════════════════════════════════════════════════════
  //  LOCAL SYNC (LAN)
  // ══════════════════════════════════════════════════════

  Future<void> startAsLeader(String name) async {
    await _server.start(syncPort);
    _discovery.startLeaderBroadcast(name);
    state = state.copyWith(
      role: SyncRole.leader,
      mode: SyncMode.local,
      isConnected: true,
      leaderName: name,
    );
  }

  void broadcastState() {
    final perf = ref.read(performanceProvider);
    if (state.isRemote) {
      _remote.broadcastState(
        songId: perf.currentSongId,
        songIndex: perf.currentSongIndex,
        transposeOffset: perf.transposeOffset,
      );
    } else {
      _server.broadcast({
        'type': 'SYNC_STATE',
        'songId': perf.currentSongId,
        'songIndex': perf.currentSongIndex,
        'transposeOffset': perf.transposeOffset,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> startAsFollower() async {
    _discovery.startFollowerDiscovery((ip, name) {
      if (state.role == SyncRole.follower && !state.isConnected) {
        _connectToLeader(ip, name);
      }
    });
    state = state.copyWith(role: SyncRole.follower, mode: SyncMode.local);
  }

  Future<void> _connectToLeader(String ip, String name) async {
    _client = SyncClient();

    _client!.onSyncState = (data) {
      _applyRemoteState(data);
    };

    await _client!.connect(ip, syncPort);
    state = state.copyWith(
      isConnected: true,
      leaderName: name,
      leaderIp: ip,
    );

    _client!.addListener(() {
      if (!_client!.isConnected) {
        state = state.copyWith(isConnected: false);
      }
    });
  }

  // ══════════════════════════════════════════════════════
  //  REMOTE SYNC (Supabase)
  // ══════════════════════════════════════════════════════

  /// Start a remote room as leader. Returns the room code.
  String startRemoteLeader(String name) {
    final code = _remote.createRoom(name);

    _remote.onFollowerJoined = (followerName) {
      state = state.copyWith(followerCount: state.followerCount + 1);
    };

    state = state.copyWith(
      role: SyncRole.leader,
      mode: SyncMode.remote,
      isConnected: true,
      leaderName: name,
      roomCode: code,
    );

    return code;
  }

  /// Join a remote room as follower.
  void joinRemoteRoom(String code, String followerName) {
    _remote.onSyncState = (data) {
      _applyRemoteState(data);
    };

    _remote.joinRoom(code, followerName);

    state = state.copyWith(
      role: SyncRole.follower,
      mode: SyncMode.remote,
      isConnected: true,
      roomCode: code,
    );

    // Watch for disconnection
    _remote.addListener(() {
      if (!_remote.isConnected && state.isConnected) {
        state = state.copyWith(isConnected: false);
      }
    });
  }

  // ══════════════════════════════════════════════════════
  //  SHARED
  // ══════════════════════════════════════════════════════

  void _applyRemoteState(Map<String, dynamic> data) {
    final perf = ref.read(performanceProvider.notifier);
    final songIndex = data['songIndex'] as int?;
    final transposeOffset = data['transposeOffset'] as int?;

    if (songIndex != null) {
      perf.goToSong(songIndex);
    }
    if (transposeOffset != null) {
      perf.setTranspose(transposeOffset);
    }
  }

  void disconnect() {
    _discovery.stop();
    _server.stop();
    _client?.disconnect();
    _client = null;
    _remote.disconnect();
    state = const SyncState();
  }
}

final syncProvider =
    StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  return SyncNotifier(ref);
});
