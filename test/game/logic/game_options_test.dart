import 'package:chess_5d/game/logic/game_options.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TimeControl', () {
    test('should create time control with all parameters', () {
      final timeControl = TimeControl(
        start: [300000, 300000], // 5 minutes each
        incr: 5000, // 5 seconds increment
        incrScale: 2500, // 2.5 seconds scaled
        grace: 10000, // 10 seconds grace
        graceScale: 5000, // 5 seconds scaled grace
      );

      expect(timeControl.start, [300000, 300000]);
      expect(timeControl.incr, 5000);
      expect(timeControl.incrScale, 2500);
      expect(timeControl.grace, 10000);
      expect(timeControl.graceScale, 5000);
    });

    test('should create unlimited time control', () {
      final timeControl = TimeControl.unlimited();

      expect(timeControl.start, [0, 0]);
      expect(timeControl.incr, null);
      expect(timeControl.incrScale, null);
      expect(timeControl.grace, null);
      expect(timeControl.graceScale, null);
    });

    test('should create equal time control', () {
      final timeControl = TimeControl.equal(600000, incrementMs: 10000);

      expect(timeControl.start, [600000, 600000]);
      expect(timeControl.incr, 10000);
      expect(timeControl.incrScale, 5000);
    });

    test('should serialize and deserialize time control', () {
      final original = TimeControl(
        start: [300000, 300000],
        incr: 5000,
        incrScale: 2500,
        grace: 10000,
        graceScale: 5000,
      );

      final json = original.toJson();
      final deserialized = TimeControl.fromJson(json);

      expect(deserialized.start, original.start);
      expect(deserialized.incr, original.incr);
      expect(deserialized.incrScale, original.incrScale);
      expect(deserialized.grace, original.grace);
      expect(deserialized.graceScale, original.graceScale);
    });
  });

  group('PlayerInfo', () {
    test('should create player info', () {
      final player = PlayerInfo(name: 'Alice', side: 1);

      expect(player.name, 'Alice');
      expect(player.side, 1);
    });

    test('should serialize and deserialize player info', () {
      final original = PlayerInfo(name: 'Bob', side: 0);

      final json = original.toJson();
      final deserialized = PlayerInfo.fromJson(json);

      expect(deserialized.name, original.name);
      expect(deserialized.side, original.side);
    });
  });

  group('GameOptions', () {
    test('should create game options with all parameters', () {
      final timeControl = TimeControl.unlimited();
      final players = [
        PlayerInfo(name: 'Black', side: 0),
        PlayerInfo(name: 'White', side: 1),
      ];

      final options = GameOptions(
        time: timeControl,
        players: players,
        variant: 'Standard',
        public: false,
        finished: false,
        winner: null,
        winCause: null,
        winReason: null,
        moves: null,
        runningClocks: false,
      );

      expect(options.time, timeControl);
      expect(options.players, players);
      expect(options.variant, 'Standard');
      expect(options.public, false);
      expect(options.finished, false);
      expect(options.winner, null);
    });

    test('should create default game options', () {
      final options = GameOptions.defaultOptions();

      expect(options.variant, 'Standard');
      expect(options.players.length, 2);
      expect(options.players[0].side, 0);
      expect(options.players[1].side, 1);
      expect(options.finished, false);
      expect(options.runningClocks, false);
    });

    test('should create default game options with variant', () {
      final options = GameOptions.defaultOptions(variant: 'NoBishops');

      expect(options.variant, 'NoBishops');
    });

    test('should serialize and deserialize game options', () {
      final timeControl = TimeControl.equal(300000, incrementMs: 5000);
      final players = [
        PlayerInfo(name: 'Black', side: 0),
        PlayerInfo(name: 'White', side: 1),
      ];

      final original = GameOptions(
        time: timeControl,
        players: players,
        variant: 'Standard',
        public: true,
        finished: false,
        runningClocks: true,
        runningClockGraceTime: 10000,
        runningClockTime: 5000,
      );

      final json = original.toJson();
      final deserialized = GameOptions.fromJson(json);

      expect(deserialized.variant, original.variant);
      expect(deserialized.public, original.public);
      expect(deserialized.finished, original.finished);
      expect(deserialized.runningClocks, original.runningClocks);
      expect(
        deserialized.runningClockGraceTime,
        original.runningClockGraceTime,
      );
      expect(deserialized.runningClockTime, original.runningClockTime);
      expect(deserialized.players.length, original.players.length);
      expect(deserialized.players[0].name, original.players[0].name);
      expect(deserialized.players[1].name, original.players[1].name);
    });
  });
}
