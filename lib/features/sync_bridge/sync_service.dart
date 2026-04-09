import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SyncServer extends ChangeNotifier {
  HttpServer? _server;
  final List<WebSocket> _clients = [];
  bool isRunning = false;

  /// Start the WebSocket server to host the session
  Future<void> start(int port) async {
    _server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    isRunning = true;
    notifyListeners();

    _server!.listen((HttpRequest request) {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        WebSocketTransformer.upgrade(request).then((socket) {
          _clients.add(socket);
          debugPrint('SyncBridge: Follower connected. Total: ${_clients.length}');
          
          socket.listen(
            (message) => _handleMessage(message),
            onDone: () {
              _clients.remove(socket);
              debugPrint('SyncBridge: Follower disconnected. Total: ${_clients.length}');
            },
          );
        });
      }
    });
  }

  /// Broadcast a message to all connected followers
  void broadcast(Map<String, dynamic> data) {
    final message = jsonEncode(data);
    for (var client in _clients) {
      client.add(message);
    }
  }

  void _handleMessage(dynamic message) {
    // Handle incoming messages from followers (e.g., "Requesting song")
    debugPrint('SyncBridge: Received message: $message');
  }

  void stop() {
    _server?.close();
    for (var client in _clients) {
      client.close();
    }
    _clients.clear();
    isRunning = false;
    notifyListeners();
  }
}

typedef SyncStateCallback = void Function(Map<String, dynamic> data);

class SyncClient extends ChangeNotifier {
  WebSocketChannel? _channel;
  bool isConnected = false;
  SyncStateCallback? onSyncState;

  /// Connect to the Leader's WebSocket server
  Future<void> connect(String ip, int port) async {
    final uri = Uri.parse('ws://$ip:$port');
    _channel = WebSocketChannel.connect(uri);
    isConnected = true;
    notifyListeners();

    _channel!.stream.listen(
      (message) => _handleMessage(message),
      onDone: () {
        isConnected = false;
        notifyListeners();
      },
      onError: (error) {
        isConnected = false;
        notifyListeners();
      },
    );
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      if (data['type'] == 'SYNC_STATE') {
        onSyncState?.call(data);
      }
    } catch (e) {
      debugPrint('SyncBridge: Failed to decode sync state: $e');
    }
  }

  void send(Map<String, dynamic> data) {
    _channel?.sink.add(jsonEncode(data));
  }

  void disconnect() {
    _channel?.sink.close();
    onSyncState = null;
    isConnected = false;
    notifyListeners();
  }
}
