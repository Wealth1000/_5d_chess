import 'package:flutter_test/flutter_test.dart';
import 'package:chess_5d/game/logic/checkmate/checkmate_worker.dart';
import 'package:chess_5d/game/logic/game_options.dart';
import 'dart:isolate';

void main() {
  group('CheckmateWorker', () {
    late GameOptions options;

    setUp(() {
      options = GameOptions.defaultOptions();
    });

    test('should create checkmate worker', () {
      final receivePort = ReceivePort();
      final worker = CheckmateWorker(receivePort.sendPort);

      expect(worker, isNotNull);
      expect(worker.sendPort, receivePort.sendPort);
    });

    test('should start and stop mate search', () {
      final receivePort = ReceivePort();
      final worker = CheckmateWorker(receivePort.sendPort);

      expect(() {
        worker.startMateSearch(options, null);
        worker.stopMateSearch();
      }, returnsNormally);
    });

    test('should handle start mate search with options', () {
      final receivePort = ReceivePort();
      final worker = CheckmateWorker(receivePort.sendPort);

      expect(() {
        worker.startMateSearch(options, []);
      }, returnsNormally);
    });

    test('should handle stop mate search when not searching', () {
      final receivePort = ReceivePort();
      final worker = CheckmateWorker(receivePort.sendPort);

      expect(() {
        worker.stopMateSearch();
      }, returnsNormally);
    });

    test('should handle multiple start/stop cycles', () {
      final receivePort = ReceivePort();
      final worker = CheckmateWorker(receivePort.sendPort);

      expect(() {
        worker.startMateSearch(options, null);
        worker.stopMateSearch();
        worker.startMateSearch(options, null);
        worker.stopMateSearch();
      }, returnsNormally);
    });

    test('should handle stop during search', () {
      final receivePort = ReceivePort();
      final worker = CheckmateWorker(receivePort.sendPort);

      expect(() {
        worker.startMateSearch(options, null);
        // Immediately stop
        worker.stopMateSearch();
      }, returnsNormally);
    });
  });

  group('checkmateWorkerMain', () {
    test('should be a top-level function', () {
      expect(checkmateWorkerMain, isA<Function>());
    });

    test('should accept SendPort parameter', () {
      final receivePort = ReceivePort();
      final sendPort = receivePort.sendPort;

      // This would actually start an isolate, so we just test that
      // the function signature is correct
      expect(() {
        // We can't actually call this in a unit test without starting an isolate
        // So we just verify the function exists and has the right signature
        checkmateWorkerMain(sendPort);
      }, returnsNormally);
    });
  });
}
