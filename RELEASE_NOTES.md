# 🎹 Open Praise — Release Notes

_Synthwave worship. Neon chords. Zero lag._

---

## v1.4.0+1 — "Production Ready" 🛡️

### Error Handling & Resilience 🛡️

- **Global error handlers** — `FlutterError.onError` + `PlatformDispatcher.onError` catch all uncaught exceptions with themed error widgets.
- **Graceful startup** — Supabase initialization wrapped in try/catch; app works locally even if remote sync config fails.
- **Custom ErrorWidget** — Synthwave-styled error screen matching the app's aesthetic instead of default red debug banner.

### Linting & Code Quality 🧹

- **Stricter lint rules** — Added `prefer_final_locals`, `prefer_const_constructors`, `prefer_single_quotes`, `unnecessary_lambdas`, `require_trailing_commas`, and more.
- **Fixed all warnings** — Removed unused variables, added `const` constructors, cleaned up `print` statements across the codebase.

### CI/CD 🚀

- **GitHub Actions CI** — Automated `flutter analyze` + `flutter test` on every push/PR to `main`.
- **Release pipeline** — Automated APK build and GitHub Release creation.

### Testing 🧪

- **Fixed smoke test** — `sync_bridge_discovery_smoke_test.dart` converted from standalone script to proper `flutter_test` test.
- ✅ All 76 tests pass with zero analysis warnings.

---

## v1.1.0+1 — "Midnight Drive" 🌆

### Chord Engine 🎸

- **ChordPro parser** — Full parse of `{title}`, `{artist}`, `{key}`, `{tempo}`, `{capo}` metadata plus section markers (`{sov}`, `{soc}`, `{sob}`, `{sot}` and their `{e*}` counterparts). Comments rendered as italic/muted text.
- **Hive-backed data model** — `Chord`, `Song`, `SongSection`, `Setlist` all persist as typed Hive boxes with `copyWith` for immutable edits.
- **Transposer** — Chromatic transpose in either direction across all 12 tones. Handles `Gm7`, `C#/D`, slash chords (`F/A`), both sharp and flat root notes.
- **Zero TODOs, zero FIXMEs** across `chord_engine/`, `midi/`, and `sync_bridge/`. Clean build.

### MIDI Integration 🎹

- MIDI input/output layer wired into the feature set (full module in `lib/features/midi/`).

### Sync Bridge 📡

- **UDP Discovery** (port 8084) — Leader broadcasts `OP_LEADER_ANN` packets on the local network; followers discover and connect. Smoke tested and passing on loopback.
- **WebSocket Sync** — `SyncServer` hosts followers via WebSocket; `SyncClient` connects as a follower. Real-time state propagation (`SYNC_STATE` events).
- **Remote Sync via Supabase** — Room-based collaboration with 6-digit alphanumeric codes. `RemoteSyncService` handles leader/follower broadcast channels through Supabase Realtime. Follower join announcements, state broadcast with song index, transpose offset, and timestamp.

### Build & Test 🧪

- ✅ `dart analyze` — clean
- ✅ TODO/FIXME scan — zero findings across all three feature modules
- ✅ SyncBridge UDP discovery smoke test — **PASS** (broadcast + receive on 127.0.0.1:8084)
- ✅ All 8 dart files across `chord_engine/`, `midi/`, `sync_bridge/` accounted for

---

> *This is the wave.* 🌊
