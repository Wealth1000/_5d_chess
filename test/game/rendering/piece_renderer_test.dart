import 'package:flutter_test/flutter_test.dart';
import 'package:chess_5d/game/logic/piece.dart';
import 'package:chess_5d/game/logic/board.dart';
import 'package:chess_5d/game/logic/game.dart';
import 'package:chess_5d/game/logic/game_options.dart';
import 'package:chess_5d/game/rendering/piece_renderer.dart';
import 'package:flutter/material.dart';

void main() {
  late Game game;
  late Board board;

  setUp(() {
    final options = GameOptions.defaultOptions();
    game = Game(options: options, localPlayer: [true, true]);
    board = game.getTimeline(0).getBoard(0)!;
  });

  group('PieceRenderer', () {
    test('should get piece symbol for king', () {
      final piece = board.getPiece(4, 0)!; // Black king
      final symbol = PieceRenderer.getPieceSymbol(piece);
      expect(symbol, '♚');
    });

    test('should get piece symbol for queen', () {
      final piece = board.getPiece(3, 0)!; // Black queen
      final symbol = PieceRenderer.getPieceSymbol(piece);
      expect(symbol, '♛');
    });

    test('should get piece symbol for white pieces', () {
      final king = board.getPiece(4, 7)!; // White king
      final symbol = PieceRenderer.getPieceSymbol(king);
      expect(symbol, '♔');
    });

    test('should get piece color for black pieces', () {
      final piece = board.getPiece(4, 0)!; // Black king
      final color = PieceRenderer.getPieceColor(piece);
      expect(color, const Color(0xFF000000));
    });

    test('should get piece color for white pieces', () {
      final piece = board.getPiece(4, 7)!; // White king
      final color = PieceRenderer.getPieceColor(piece);
      expect(color, const Color(0xFFFFFFFF));
    });

    test('should get piece name', () {
      final piece = board.getPiece(4, 0)!; // Black king
      final name = PieceRenderer.getPieceName(piece);
      expect(name, contains('king'));
      expect(name, contains('black'));
    });

    test('should handle all piece types', () {
      final pieceTypes = [
        PieceType.pawn,
        PieceType.rook,
        PieceType.knight,
        PieceType.bishop,
        PieceType.queen,
        PieceType.king,
      ];

      for (final type in pieceTypes) {
        // Find a piece of this type on the board
        Piece? piece;
        for (int x = 0; x < 8; x++) {
          for (int y = 0; y < 8; y++) {
            final p = board.getPiece(x, y);
            if (p != null && p.type == type) {
              piece = p;
              break;
            }
          }
          if (piece != null) break;
        }

        if (piece != null) {
          final symbol = PieceRenderer.getPieceSymbol(piece);
          expect(symbol, isNotEmpty);
          expect(symbol, isNot('?'));
        }
      }
    });
  });
}
