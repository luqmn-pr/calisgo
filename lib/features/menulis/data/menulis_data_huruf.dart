import 'dart:ui';
import 'menulis_data.dart';

// Helper to provide all 26 letters to avoid making menulis_data.dart too long.
class MenulisHuruf {
  static final List<LetterStroke> aToZ = [
    LetterStroke(character: 'A', displayLabel: 'A', strokes: [
      [Offset(0.15, 0.9), Offset(0.5, 0.1), Offset(0.85, 0.9)],
      [Offset(0.28, 0.6), Offset(0.72, 0.6)],
    ]),
    LetterStroke(character: 'B', displayLabel: 'B', strokes: [
      [Offset(0.3, 0.1), Offset(0.3, 0.9)],
      [Offset(0.3, 0.1), Offset(0.65, 0.12), Offset(0.75, 0.25), Offset(0.65, 0.48), Offset(0.3, 0.5)],
      [Offset(0.3, 0.5), Offset(0.7, 0.52), Offset(0.8, 0.68), Offset(0.7, 0.87), Offset(0.3, 0.9)],
    ]),
    LetterStroke(character: 'C', displayLabel: 'C', strokes: [
      [Offset(0.78, 0.25), Offset(0.62, 0.12), Offset(0.4, 0.1), Offset(0.22, 0.28), Offset(0.18, 0.5), Offset(0.22, 0.72), Offset(0.4, 0.9), Offset(0.62, 0.88), Offset(0.78, 0.75)]
    ]),
    LetterStroke(character: 'D', displayLabel: 'D', strokes: [
      [Offset(0.3, 0.1), Offset(0.3, 0.9)],
      [Offset(0.3, 0.1), Offset(0.65, 0.15), Offset(0.78, 0.35), Offset(0.78, 0.65), Offset(0.65, 0.85), Offset(0.3, 0.9)],
    ]),
    LetterStroke(character: 'E', displayLabel: 'E', strokes: [
      [Offset(0.3, 0.1), Offset(0.3, 0.9)],
      [Offset(0.3, 0.1), Offset(0.75, 0.1)],
      [Offset(0.3, 0.5), Offset(0.65, 0.5)],
      [Offset(0.3, 0.9), Offset(0.75, 0.9)],
    ]),
    LetterStroke(character: 'F', displayLabel: 'F', strokes: [
      [Offset(0.3, 0.1), Offset(0.3, 0.9)],
      [Offset(0.3, 0.1), Offset(0.75, 0.1)],
      [Offset(0.3, 0.5), Offset(0.65, 0.5)],
    ]),
    LetterStroke(character: 'G', displayLabel: 'G', strokes: [
      [Offset(0.78, 0.25), Offset(0.62, 0.12), Offset(0.4, 0.1), Offset(0.22, 0.28), Offset(0.18, 0.5), Offset(0.22, 0.72), Offset(0.4, 0.9), Offset(0.62, 0.88), Offset(0.78, 0.75), Offset(0.78, 0.55), Offset(0.55, 0.55)]
    ]),
    LetterStroke(character: 'H', displayLabel: 'H', strokes: [
      [Offset(0.3, 0.1), Offset(0.3, 0.9)],
      [Offset(0.7, 0.1), Offset(0.7, 0.9)],
      [Offset(0.3, 0.5), Offset(0.7, 0.5)],
    ]),
    LetterStroke(character: 'I', displayLabel: 'I', strokes: [
      [Offset(0.3, 0.1), Offset(0.7, 0.1)],
      [Offset(0.5, 0.1), Offset(0.5, 0.9)],
      [Offset(0.3, 0.9), Offset(0.7, 0.9)],
    ]),
    LetterStroke(character: 'J', displayLabel: 'J', strokes: [
      [Offset(0.7, 0.1), Offset(0.7, 0.75), Offset(0.6, 0.9), Offset(0.4, 0.9), Offset(0.3, 0.75)],
    ]),
    LetterStroke(character: 'K', displayLabel: 'K', strokes: [
      [Offset(0.3, 0.1), Offset(0.3, 0.9)],
      [Offset(0.7, 0.1), Offset(0.3, 0.5)],
      [Offset(0.3, 0.5), Offset(0.7, 0.9)],
    ]),
    LetterStroke(character: 'L', displayLabel: 'L', strokes: [
      [Offset(0.35, 0.1), Offset(0.35, 0.9), Offset(0.75, 0.9)]
    ]),
    LetterStroke(character: 'M', displayLabel: 'M', strokes: [
      [Offset(0.2, 0.9), Offset(0.2, 0.1), Offset(0.5, 0.5), Offset(0.8, 0.1), Offset(0.8, 0.9)],
    ]),
    LetterStroke(character: 'N', displayLabel: 'N', strokes: [
      [Offset(0.25, 0.9), Offset(0.25, 0.1), Offset(0.75, 0.9), Offset(0.75, 0.1)],
    ]),
    LetterStroke(character: 'O', displayLabel: 'O', strokes: [
      [Offset(0.5, 0.1), Offset(0.75, 0.28), Offset(0.82, 0.5), Offset(0.75, 0.72), Offset(0.5, 0.9), Offset(0.25, 0.72), Offset(0.18, 0.5), Offset(0.25, 0.28), Offset(0.5, 0.1)]
    ]),
    LetterStroke(character: 'P', displayLabel: 'P', strokes: [
      [Offset(0.3, 0.1), Offset(0.3, 0.9)],
      [Offset(0.3, 0.1), Offset(0.65, 0.12), Offset(0.75, 0.25), Offset(0.65, 0.48), Offset(0.3, 0.5)],
    ]),
    LetterStroke(character: 'Q', displayLabel: 'Q', strokes: [
      [Offset(0.5, 0.1), Offset(0.75, 0.28), Offset(0.82, 0.5), Offset(0.75, 0.72), Offset(0.5, 0.9), Offset(0.25, 0.72), Offset(0.18, 0.5), Offset(0.25, 0.28), Offset(0.5, 0.1)],
      [Offset(0.6, 0.65), Offset(0.85, 0.9)],
    ]),
    LetterStroke(character: 'R', displayLabel: 'R', strokes: [
      [Offset(0.3, 0.1), Offset(0.3, 0.9)],
      [Offset(0.3, 0.1), Offset(0.65, 0.12), Offset(0.75, 0.25), Offset(0.65, 0.48), Offset(0.3, 0.5)],
      [Offset(0.45, 0.5), Offset(0.75, 0.9)],
    ]),
    LetterStroke(character: 'S', displayLabel: 'S', strokes: [
      [Offset(0.78, 0.2), Offset(0.6, 0.1), Offset(0.38, 0.12), Offset(0.22, 0.28), Offset(0.3, 0.45), Offset(0.55, 0.5), Offset(0.75, 0.58), Offset(0.78, 0.75), Offset(0.62, 0.88), Offset(0.4, 0.9), Offset(0.22, 0.78)]
    ]),
    LetterStroke(character: 'T', displayLabel: 'T', strokes: [
      [Offset(0.2, 0.1), Offset(0.8, 0.1)],
      [Offset(0.5, 0.1), Offset(0.5, 0.9)],
    ]),
    LetterStroke(character: 'U', displayLabel: 'U', strokes: [
      [Offset(0.25, 0.1), Offset(0.25, 0.7), Offset(0.35, 0.85), Offset(0.5, 0.9), Offset(0.65, 0.85), Offset(0.75, 0.7), Offset(0.75, 0.1)]
    ]),
    LetterStroke(character: 'V', displayLabel: 'V', strokes: [
      [Offset(0.2, 0.1), Offset(0.5, 0.9), Offset(0.8, 0.1)],
    ]),
    LetterStroke(character: 'W', displayLabel: 'W', strokes: [
      [Offset(0.15, 0.1), Offset(0.3, 0.9), Offset(0.5, 0.4), Offset(0.7, 0.9), Offset(0.85, 0.1)],
    ]),
    LetterStroke(character: 'X', displayLabel: 'X', strokes: [
      [Offset(0.25, 0.1), Offset(0.75, 0.9)],
      [Offset(0.75, 0.1), Offset(0.25, 0.9)],
    ]),
    LetterStroke(character: 'Y', displayLabel: 'Y', strokes: [
      [Offset(0.25, 0.1), Offset(0.5, 0.5)],
      [Offset(0.75, 0.1), Offset(0.5, 0.5)],
      [Offset(0.5, 0.5), Offset(0.5, 0.9)],
    ]),
    LetterStroke(character: 'Z', displayLabel: 'Z', strokes: [
      [Offset(0.25, 0.1), Offset(0.75, 0.1), Offset(0.25, 0.9), Offset(0.75, 0.9)],
    ]),
  ];
}
