import 'package:flutter_test/flutter_test.dart';
import 'package:open_praise/features/chord_engine/models.dart';
import 'package:open_praise/providers/app_providers.dart';

void main() {
  group('PerformanceState', () {
    test('defaults to no active setlist', () {
      const state = PerformanceState();
      expect(state.activeSetlist, isNull);
      expect(state.currentSongIndex, equals(0));
      expect(state.transposeOffset, equals(0));
      expect(state.currentSongId, isNull);
      expect(state.songCount, equals(0));
    });

    test('currentSongId returns correct id', () {
      final setlist = Setlist(name: 'Test', songIds: ['a', 'b', 'c']);
      final state = PerformanceState(activeSetlist: setlist, currentSongIndex: 1);
      expect(state.currentSongId, equals('b'));
    });

    test('currentSongId returns null for out-of-range index', () {
      final setlist = Setlist(name: 'Test', songIds: ['a']);
      final state = PerformanceState(activeSetlist: setlist, currentSongIndex: 5);
      expect(state.currentSongId, isNull);
    });

    test('currentSongId returns null for negative index', () {
      final setlist = Setlist(name: 'Test', songIds: ['a']);
      final state = PerformanceState(activeSetlist: setlist, currentSongIndex: -1);
      expect(state.currentSongId, isNull);
    });

    test('hasPrevious is false at index 0', () {
      final setlist = Setlist(name: 'Test', songIds: ['a', 'b']);
      const state = PerformanceState(currentSongIndex: 0);
      expect(state.hasPrevious, isFalse);
    });

    test('hasPrevious is true at index > 0', () {
      final setlist = Setlist(name: 'Test', songIds: ['a', 'b']);
      final state = PerformanceState(activeSetlist: setlist, currentSongIndex: 1);
      expect(state.hasPrevious, isTrue);
    });

    test('hasNext is true when not at last song', () {
      final setlist = Setlist(name: 'Test', songIds: ['a', 'b', 'c']);
      final state = PerformanceState(activeSetlist: setlist, currentSongIndex: 0);
      expect(state.hasNext, isTrue);
    });

    test('hasNext is false at last song', () {
      final setlist = Setlist(name: 'Test', songIds: ['a', 'b']);
      final state = PerformanceState(activeSetlist: setlist, currentSongIndex: 1);
      expect(state.hasNext, isFalse);
    });

    test('hasNext is false with no setlist', () {
      const state = PerformanceState();
      expect(state.hasNext, isFalse);
    });

    test('songCount returns correct count', () {
      final setlist = Setlist(name: 'Test', songIds: ['a', 'b', 'c']);
      final state = PerformanceState(activeSetlist: setlist);
      expect(state.songCount, equals(3));
    });

    test('copyWith works correctly', () {
      final setlist = Setlist(name: 'Test', songIds: ['a']);
      final state = PerformanceState(
        activeSetlist: setlist,
        currentSongIndex: 0,
        transposeOffset: 3,
      );

      final newState = state.copyWith(currentSongIndex: 1, transposeOffset: 5);
      expect(newState.currentSongIndex, equals(1));
      expect(newState.transposeOffset, equals(5));
      expect(newState.activeSetlist, equals(setlist));
    });
  });
}
