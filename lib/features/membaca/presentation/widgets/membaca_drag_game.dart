import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide Image;

import '../../../../core/audio/audio_service.dart';
import '../../../../core/audio/sound_generator.dart';

class MembacaDragGame extends FlameGame with DragCallbacks {
  final List<String> correctSequence;
  final List<String> availablePieces;
  final AudioService audioService;
  final void Function(bool isCorrect) onAnswerSubmitted;

  MembacaDragGame({
    required this.correctSequence,
    required this.availablePieces,
    required this.audioService,
    required this.onAnswerSubmitted,
  });

  final List<DragPieceComponent> _pieces = [];
  final List<DropSlotComponent> _slots = [];
  DragPieceComponent? _dragging;

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    final slotCount = correctSequence.length;
    final pieceCount = availablePieces.length;

    // Slot dimensions
    final slotW = (size.x * 0.75 / slotCount).clamp(60.0, 160.0);
    final slotH = slotW * 0.5;
    final slotSpacing = 16.0;

    final totalSlotW = (slotW * slotCount) + (slotSpacing * (slotCount - 1));
    final startSlotX = (size.x - totalSlotW) / 2;
    final slotY = 0.0; // Move slots to the very top

    for (int i = 0; i < slotCount; i++) {
      final slot = DropSlotComponent(
        index: i,
        size: Vector2(slotW, slotH),
        position: Vector2(startSlotX + i * (slotW + slotSpacing), slotY),
      );
      _slots.add(slot);
      add(slot);
    }

    // Piece dimensions
    final pieceW = (size.x * 0.85 / pieceCount).clamp(50.0, 150.0);
    final pieceH = pieceW * 0.45;
    final pieceSpacing = 12.0;

    final totalPieceW = (pieceW * pieceCount) + (pieceSpacing * (pieceCount - 1));
    final startPieceX = (size.x - totalPieceW) / 2;
    final pieceY = size.y * 0.5; // Bottom area

    for (int i = 0; i < pieceCount; i++) {
      final pos = Vector2(startPieceX + i * (pieceW + pieceSpacing), pieceY);
      final piece = DragPieceComponent(
        id: i,
        text: availablePieces[i],
        size: Vector2(pieceW, pieceH),
        initialPosition: pos,
      );
      _pieces.add(piece);
      add(piece);
    }
  }

  @override
  bool onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    final pos = event.canvasPosition;
    for (final piece in _pieces.reversed) {
      if (piece.containsPoint(pos)) {
        _dragging = piece;
        piece.onPickUp();
        
        if (piece.currentSlot != null) {
          piece.currentSlot!.filledPiece = null;
          piece.currentSlot = null;
        }
        return true;
      }
    }
    return false;
  }

  @override
  bool onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (_dragging == null) return false;
    _dragging!.position += event.localDelta;
    return true;
  }

  @override
  bool onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (_dragging == null) return false;
    _handleDrop(_dragging!);
    _dragging!.onRelease();
    _dragging = null;
    return true;
  }

  void _handleDrop(DragPieceComponent piece) {
    final pieceCenter = piece.position + piece.size / 2;
    DropSlotComponent? targetSlot;

    for (final slot in _slots) {
      final slotRect = slot.toRect();
      if (slotRect.contains(pieceCenter.toOffset())) {
        targetSlot = slot;
        break;
      }
    }

    if (targetSlot != null) {
      // If slot is occupied, send the occupying piece back home
      if (targetSlot.filledPiece != null && targetSlot.filledPiece != piece) {
        targetSlot.filledPiece!.snapToHome();
        targetSlot.filledPiece!.currentSlot = null;
      }

      piece.snapTo(targetSlot.position + (targetSlot.size - piece.size) / 2);
      piece.currentSlot = targetSlot;
      targetSlot.filledPiece = piece;
      
      // Play snap sound effect
      audioService.playSound(SoundType.tap);

      _checkWinCondition();
    } else {
      piece.snapToHome();
    }
  }

  void _checkWinCondition() {
    bool allFilled = true;
    List<String> currentArrangement = [];
    
    for (final slot in _slots) {
      if (slot.filledPiece == null) {
        allFilled = false;
        break;
      }
      currentArrangement.add(slot.filledPiece!.text);
    }

    if (allFilled) {
      bool isCorrect = true;
      for (int i = 0; i < correctSequence.length; i++) {
        if (currentArrangement[i] != correctSequence[i]) {
          isCorrect = false;
          break;
        }
      }
      onAnswerSubmitted(isCorrect);
    }
  }
}

class RoundedRectComponent extends PositionComponent {
  final Paint paint;
  final double radius;
  
  RoundedRectComponent({required super.size, required this.paint, this.radius = 16.0});

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), Radius.circular(radius)),
      paint,
    );
  }
}

class DropSlotComponent extends PositionComponent {
  final int index;
  DragPieceComponent? filledPiece;

  late RoundedRectComponent _bg;
  late RoundedRectComponent _border;

  DropSlotComponent({
    required this.index,
    required super.size,
    required super.position,
  }) {
    _bg = RoundedRectComponent(
      size: size,
      paint: Paint()..color = const Color(0x33000000),
      radius: 18.0,
    );

    _border = RoundedRectComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0x88FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
      radius: 18.0,
    );
  }

  @override
  Future<void> onLoad() async {
    add(_bg);
    add(_border);
  }
}

class DragPieceComponent extends PositionComponent {
  final int id;
  final String text;
  final Vector2 homePosition;
  DropSlotComponent? currentSlot;

  late RoundedRectComponent _bg;
  late TextComponent _label;

  DragPieceComponent({
    required this.id,
    required this.text,
    required super.size,
    required Vector2 initialPosition,
  }) : homePosition = initialPosition.clone(),
       super(position: initialPosition);

  @override
  Future<void> onLoad() async {
    _bg = RoundedRectComponent(
      size: size,
      paint: Paint()..color = const Color(0xFFEF5350), // AppColors.membacaColor equivalent
      radius: 14.0,
    );
    add(_bg);

    _label = TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: size.y * 0.45,
          fontWeight: FontWeight.w900,
          color: const Color(0xFFFFFFFF),
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2),
    );
    add(_label);
  }

  void onPickUp() {
    priority = 99;
    scale = Vector2.all(1.1);
  }

  void onRelease() {
    priority = 0;
    scale = Vector2.all(1.0);
  }

  void snapTo(Vector2 targetPos) {
    position.setFrom(targetPos);
  }

  void snapToHome() {
    position.setFrom(homePosition);
  }
}

class MembacaGameWidget extends StatefulWidget {
  final List<String> correctSequence;
  final List<String> shuffledPieces;
  final int currentIndex;
  final void Function(bool) onAnswerSubmitted;
  final AudioService audioService;

  const MembacaGameWidget({
    super.key,
    required this.correctSequence,
    required this.shuffledPieces,
    required this.currentIndex,
    required this.onAnswerSubmitted,
    required this.audioService,
  });

  @override
  State<MembacaGameWidget> createState() => _MembacaGameWidgetState();
}

class _MembacaGameWidgetState extends State<MembacaGameWidget> {
  late MembacaDragGame _game;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  @override
  void didUpdateWidget(MembacaGameWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex ||
        oldWidget.correctSequence != widget.correctSequence) {
      _initGame();
    }
  }

  void _initGame() {
    _game = MembacaDragGame(
      correctSequence: widget.correctSequence,
      availablePieces: widget.shuffledPieces,
      audioService: widget.audioService,
      onAnswerSubmitted: widget.onAnswerSubmitted,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: _game);
  }
}
