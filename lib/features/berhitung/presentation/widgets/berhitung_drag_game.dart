import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class BerhitungDragGame extends FlameGame with DragCallbacks {
  final String emoji;
  final int totalSpawned;
  final int initialInBox;
  final ValueChanged<int> onCountChanged;

  BerhitungDragGame({
    required this.emoji,
    required this.totalSpawned,
    required this.initialInBox,
    required this.onCountChanged,
  });

  late DropZoneComponent _boxZone;
  final List<EmojiDragItem> _items = [];
  final Random _rng = Random();
  int _inBoxCount = 0;
  EmojiDragItem? _dragging;

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    _inBoxCount = initialInBox;

    final zoneW = size.x * 0.45;
    final zoneH = size.y * 0.85;
    final zonePosY = (size.y - zoneH) / 2;

    // Box Zone (Kanan)
    _boxZone = DropZoneComponent(
      size: Vector2(zoneW, zoneH),
      position: Vector2(size.x * 0.525, zonePosY),
      label: 'Di Dalam Kotak',
      color: AppColors.berhitungColor,
    );
    add(_boxZone);

    // Bounding area for outside spawn (Kiri)
    final outsideAreaX = size.x * 0.025;
    final outsideAreaY = zonePosY;
    final outsideAreaW = zoneW;
    final outsideAreaH = zoneH;

    const itemSize = 44.0;
    for (int i = 0; i < totalSpawned; i++) {
      final isInBox = i < initialInBox;
      
      double px, py;
      if (isInBox) {
        px = _boxZone.position.x + itemSize / 2 + _rng.nextDouble() * (_boxZone.size.x - itemSize);
        py = _boxZone.position.y + itemSize / 2 + _rng.nextDouble() * (_boxZone.size.y - itemSize);
      } else {
        px = outsideAreaX + itemSize / 2 + _rng.nextDouble() * (outsideAreaW - itemSize);
        py = outsideAreaY + itemSize / 2 + _rng.nextDouble() * (outsideAreaH - itemSize);
      }
      
      final item = EmojiDragItem(
        emoji: emoji,
        itemSize: itemSize,
        initialPosition: Vector2(px, py),
        isInBox: isInBox,
      );
      _items.add(item);
      add(item);
    }
  }

  @override
  bool onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    final pos = event.canvasPosition;
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
    final inBox = itemCenter.x >= _boxZone.position.x &&
        itemCenter.x <= _boxZone.position.x + _boxZone.size.x &&
        itemCenter.y >= _boxZone.position.y &&
        itemCenter.y <= _boxZone.position.y + _boxZone.size.y;

    if (inBox && !item.isInBox) {
      item.isInBox = true;
      _inBoxCount++;
      onCountChanged(_inBoxCount);
    } else if (!inBox && item.isInBox) {
      item.isInBox = false;
      _inBoxCount = (_inBoxCount - 1).clamp(0, totalSpawned);
      onCountChanged(_inBoxCount);
    }
  }
}

class EmojiDragItem extends PositionComponent {
  final String emoji;
  final double itemSize;
  bool isInBox;

  late TextComponent _label;
  late CircleComponent _shadow;

  EmojiDragItem({
    required this.emoji,
    required this.itemSize,
    required Vector2 initialPosition,
    required this.isInBox,
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
    scale = Vector2.all(isInBox ? 0.85 : 1.0);
  }
}

class DropZoneComponent extends PositionComponent {
  final String label;
  final Color color;

  late TextComponent _labelText;
  late RectangleComponent _bg;
  late RectangleComponent _border;

  DropZoneComponent({
    required super.size,
    required super.position,
    required this.label,
    required this.color,
  }) {
    _init();
  }

  void _init() {
    _bg = RectangleComponent(
      size: size,
      paint: Paint()..color = color.withOpacity(0.15),
    );

    _border = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
    );

    _labelText = TextComponent(
      text: label,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 10),
    );
  }

  @override
  Future<void> onLoad() async {
    add(_bg);
    add(_border);
    add(_labelText);
  }
}
