import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'berhitung_drag_game.dart';

class BerhitungGameWidget extends StatefulWidget {
  final String emoji;
  final int totalSpawned;
  final int initialInBox;
  final int currentIndex;
  final ValueChanged<int> onCountChanged;

  const BerhitungGameWidget({
    super.key,
    required this.emoji,
    required this.totalSpawned,
    required this.initialInBox,
    required this.currentIndex,
    required this.onCountChanged,
  });

  @override
  State<BerhitungGameWidget> createState() => _BerhitungGameWidgetState();
}

class _BerhitungGameWidgetState extends State<BerhitungGameWidget> {
  late BerhitungDragGame _game;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    _game = BerhitungDragGame(
      emoji: widget.emoji,
      totalSpawned: widget.totalSpawned,
      initialInBox: widget.initialInBox,
      onCountChanged: widget.onCountChanged,
    );
  }

  @override
  void didUpdateWidget(BerhitungGameWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _initGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: _game,
      key: ValueKey(widget.currentIndex),
    );
  }
}
