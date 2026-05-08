import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/menulis_provider.dart';
import './tracing_painter.dart';


class TracingCanvas extends ConsumerWidget {
  const TracingCanvas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(menulisProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasSize =
            Size(constraints.maxWidth, constraints.maxHeight);

        return GestureDetector(
          onPanStart: (details) {
            final normalized = _normalize(details.localPosition, canvasSize);
            ref.read(menulisProvider.notifier).startStroke(normalized);
          },
          onPanUpdate: (details) {
            final normalized = _normalize(details.localPosition, canvasSize);
            ref.read(menulisProvider.notifier).updateStroke(normalized);
          },
          onPanEnd: (_) {
            ref.read(menulisProvider.notifier).endStroke(canvasSize);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              color: Colors.white,
              child: CustomPaint(
                painter: TracingPainter(state: state, size: canvasSize),
                child: Container(),
              ),
            ),
          ),
        );
      },
    );
  }

  Offset _normalize(Offset local, Size size) {
    return Offset(
      (local.dx / size.width).clamp(0.0, 1.0),
      (local.dy / size.height).clamp(0.0, 1.0),
    );
  }
}
