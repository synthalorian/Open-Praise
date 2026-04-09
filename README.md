# 🎹 OPEN PRAISE // S6.5

![Status](https://img.shields.io/badge/SIGNAL-ACTIVE-brightgreen?style=for-the-badge)
![Version](https://img.shields.io/badge/VERSION-1.0.0-pink?style=for-the-badge)
![Aesthetic](https://img.shields.io/badge/AESTHETIC-RETRO--FUTURISM-blue?style=for-the-badge)

> "This is the wave."

**Open Praise** is a high-performance setlist and chord sheet manager designed specifically for worship teams. It’s built on the neon grid of 1984 technology, synth-optimized for precision and speed. No fluff. Just chords, sync, and stage-ready stability.

## ⚡ CORE FEATURES

- **ChordPro Engine**: High-speed parsing and transposition of standard ChordPro format.
- **SyncBridge**: Real-time sync between a leader and multiple followers via WebSockets.
- **Neon UI**: High-contrast, stage-optimized interface that won't blind you in the dark.
- **Lightweight**: Zero bloat. Fast as a Ferrari Testarossa.

## 📡 SYNC BRIDGE

Open Praise is designed for synchronous performance. One **Leader** broadcasts the current song and page state to all **Followers** on the local network.

- **Discovery**: Uses UDP broadcasting (Port 8084) to find the Leader.
- **Sync**: WebSocket connection for real-time state management.

## 🛠️ TECH STACK

- **Framework**: Flutter / Dart
- **State Management**: Riverpod (the only way)
- **Local Storage**: Hive (fast, efficient, reliable)
- **Networking**: WebSockets + UDP Broadcast

## 🚀 GETTING STARTED

1.  **Clone the grid**: `git clone https://github.com/synthalorian/open-praise`
2.  **Initialize**: `flutter pub get`
3.  **Run**: `flutter run`

## ⌨️ KEY COMMANDS (S6.5)

- **[T]**: Transpose menu
- **[S]**: Sync status
- **[SPACE]**: Next song in setlist

---

_Developed by **synth** and **synthclaw** — a digital entity from the neon grid of 1984._
