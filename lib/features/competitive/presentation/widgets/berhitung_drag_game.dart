import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

/// Flame game untuk mekanik drag-and-drop di soal Berhitung kompetisi.
///
/// Layout dalam panel:
///   - Kiri panel : objek emoji tersebar (sumber)
///   - Kanan panel: kotak tujuan (drop zone)
///
/// Jika [isFlipped] = true (tim merah yang rotasi 180°),
/// delta drag di-invert agar kontrol tetap natural.
class BerhitungDragGame extends FlameGame with DragCallbacks {
  final String emoji;
  final int targetCount;
  final int totalSpawned;
  final bool isFlipped;
  final ValueChanged<int> onCountChanged;

  BerhitungDragGame({
    required this.emoji,
    required this.targetCount,
    required this.totalSpawned,
    required this.onCountChanged,
    this.isFlipped = false,
  });

  final List<EmojiDragItem> _items = [];
  late DropZoneComponent _dropZone;
  final Random _rng = Random();
  int _droppedCount = 0;
  EmojiDragItem? _dragging;

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    // ── Drop Zone (kanan panel, 35% lebar) ────────────────
    final zoneW = size.x * 0.34;
    final zoneH = size.y * 0.55;
    final zonePosX = size.x * 0.62;
    final zonePosY = (size.y - zoneH) / 2;

    _dropZone = DropZoneComponent(
      size: Vector2(zoneW, zoneH),
      position: Vector2(zonePosX, zonePosY),
    );
    add(_dropZone);

    // ── Spawn emoji items (kiri panel, 55% lebar) ─────────
    const itemSize = 44.0;
    for (int i = 0; i < totalSpawned; i++) {
      final px = itemSize / 2 + _rng.nextDouble() * (size.x * 0.52 - itemSize);
      final py = itemSize / 2 + _rng.nextDouble() * (size.y - itemSize);
      final item = EmojiDragItem(
        emoji: emoji,
        itemSize: itemSize,
        initialPosition: Vector2(px, py),
      );
      _items.add(item);
      add(item);
    }
  }

  // ─── Drag handling di level game ────────────────────────
  @override
  bool onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    final pos = event.canvasPosition;
    // Temukan item yang paling dekat dengan touch
    for (final item in _items.reversed) {
      if (item.containsPoint(pos)) {
        _dragging = item;
        item.onPickUp();
        return true;
      }
    }
    return false;
  }

  @override
  bool onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (_dragging == null) return false;
    final delta = event.localDelta;
    _dragging!.position += delta;
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

  void _handleDrop(EmojiDragItem item) {
    final itemCenter = item.position + Vector2.all(item.itemSize / 2);
    final inZone = itemCenter.x >= _dropZone.position.x &&
        itemCenter.x <= _dropZone.position.x + _dropZone.size.x &&
        itemCenter.y >= _dropZone.position.y &&
        itemCenter.y <= _dropZone.position.y + _dropZone.size.y;

    if (inZone && !item.isInZone) {
      item.isInZone = true;
      _droppedCount++;
      onCountChanged(_droppedCount);
    } else if (!inZone && item.isInZone) {
      // Item ditarik keluar dari zona
      item.isInZone = false;
      _droppedCount = (_droppedCount - 1).clamp(0, totalSpawned);
      onCountChanged(_droppedCount);
    }
  }
}

// ─── EmojiDragItem ────────────────────────────────────────────
class EmojiDragItem extends PositionComponent {
  final String emoji;
  final double itemSize;
  bool isInZone = false;

  late TextComponent _label;
  late CircleComponent _shadow;

  EmojiDragItem({
    required this.emoji,
    required this.itemSize,
    required Vector2 initialPosition,
  }) : super(
          position: initialPosition,
          size: Vector2.all(itemSize),
        );

  @override
  Future<void> onLoad() async {
    _shadow = CircleComponent(
      radius: itemSize / 2 + 4,
      position: Vector2(-4, -4),
      paint: Paint()..color = const Color(0x22000000),
    );
    add(_shadow);

    _label = TextComponent(
      text: emoji,
      textRenderer: TextPaint(
        style: TextStyle(fontSize: itemSize * 0.8),
      ),
      anchor: Anchor.center,
      position: Vector2(itemSize / 2, itemSize / 2),
    );
    add(_label);
  }

  @override
  bool containsPoint(Vector2 point) {
    final center = position + Vector2.all(itemSize / 2);
    return (point - center).length <= itemSize / 2 + 8;
  }

  void onPickUp() {
    priority = 99;
    scale = Vector2.all(1.15);
  }

  void onRelease() {
    priority = 0;
    scale = Vector2.all(isInZone ? 0.85 : 1.0);
  }
}

// ─── DropZoneComponent ────────────────────────────────────────
class DropZoneComponent extends PositionComponent {
  late TextComponent _labelText;
  late RectangleComponent _bg;
  late RectangleComponent _border;

  DropZoneComponent({
    required super.size,
    required super.position,
  }) {
    _init();
  }

  void _init() {
    // background
    _bg = RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0x2200C853),
    );

    // border dashed (single rect)
    _border = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0xFF00C853)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    _labelText = TextComponent(
      text: '📦 Kotak\nJawaban',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF666666),
          height: 1.4,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2),
    );
  }

  @override
  Future<void> onLoad() async {
    add(_bg);
    add(_border);
    add(_labelText);
  }
}
