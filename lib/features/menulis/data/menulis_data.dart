import 'dart:ui';
import 'package:flutter/material.dart';

/// Model untuk mendefinisikan stroke path sebuah huruf/angka.
/// Setiap huruf memiliki daftar [strokes], di mana tiap stroke
/// adalah list [Offset] ternormalisasi dalam coordinate 0.0 – 1.0.
class LetterStroke {
  final String character;
  final List<List<Offset>> strokes;
  late final List<List<Offset>> checkpoints;
  final String displayLabel;

  LetterStroke({
    required this.character,
    required this.strokes,
    required this.displayLabel,
  }) {
    // Generate checkpoints automatically:
    // This reduces the hit detection points to only the main anchor points 
    // (start, middle segments, and end) while keeping the full strokes for visual smoothness.
    checkpoints = strokes.map((stroke) {
      if (stroke.length <= 3) return stroke;
      return [
        stroke.first,
        stroke[(stroke.length * 0.33).floor()],
        stroke[(stroke.length * 0.66).floor()],
        stroke.last,
      ];
    }).toList();
  }
}

class MenulisData {
  MenulisData._();

  // ─── Angka 0-9 ────────────────────────────────────────────
  // Koordinat ternormalisasi [0,1] — akan di-scale ke canvas size
  static final List<LetterStroke> angka = [
    LetterStroke(
      character: '0',
      displayLabel: '0',
      strokes: [
        [
          Offset(0.5, 0.1), Offset(0.7, 0.15), Offset(0.85, 0.3),
          Offset(0.9, 0.5), Offset(0.85, 0.7), Offset(0.7, 0.85),
          Offset(0.5, 0.9), Offset(0.3, 0.85), Offset(0.15, 0.7),
          Offset(0.1, 0.5), Offset(0.15, 0.3), Offset(0.3, 0.15),
          Offset(0.5, 0.1),
        ]
      ],
    ),
    LetterStroke(
      character: '1',
      displayLabel: '1',
      strokes: [
        [Offset(0.35, 0.2), Offset(0.5, 0.1), Offset(0.5, 0.9)],
      ],
    ),
    LetterStroke(
      character: '2',
      displayLabel: '2',
      strokes: [
        [
          Offset(0.25, 0.25), Offset(0.35, 0.15), Offset(0.55, 0.1),
          Offset(0.72, 0.15), Offset(0.78, 0.3), Offset(0.72, 0.45),
          Offset(0.5, 0.6), Offset(0.25, 0.82), Offset(0.22, 0.9),
          Offset(0.78, 0.9),
        ]
      ],
    ),
    LetterStroke(
      character: '3',
      displayLabel: '3',
      strokes: [
        [
          Offset(0.25, 0.15), Offset(0.65, 0.15), Offset(0.75, 0.3),
          Offset(0.65, 0.48), Offset(0.45, 0.5),
        ],
        [
          Offset(0.45, 0.5), Offset(0.68, 0.52), Offset(0.78, 0.68),
          Offset(0.68, 0.85), Offset(0.45, 0.9), Offset(0.25, 0.85),
        ]
      ],
    ),
    LetterStroke(
      character: '4',
      displayLabel: '4',
      strokes: [
        [Offset(0.65, 0.1), Offset(0.2, 0.6), Offset(0.8, 0.6)],
        [Offset(0.65, 0.1), Offset(0.65, 0.9)],
      ],
    ),
    LetterStroke(
      character: '5',
      displayLabel: '5',
      strokes: [
        [
          Offset(0.75, 0.1), Offset(0.25, 0.1), Offset(0.22, 0.45),
          Offset(0.45, 0.38), Offset(0.68, 0.42), Offset(0.78, 0.6),
          Offset(0.7, 0.8), Offset(0.5, 0.9), Offset(0.28, 0.82),
        ]
      ],
    ),
    LetterStroke(
      character: '6',
      displayLabel: '6',
      strokes: [
        [
          Offset(0.72, 0.15), Offset(0.45, 0.1), Offset(0.22, 0.35),
          Offset(0.18, 0.58), Offset(0.22, 0.75), Offset(0.4, 0.88),
          Offset(0.62, 0.85), Offset(0.75, 0.68), Offset(0.7, 0.52),
          Offset(0.52, 0.45), Offset(0.28, 0.48), Offset(0.2, 0.6),
        ]
      ],
    ),
    LetterStroke(
      character: '7',
      displayLabel: '7',
      strokes: [
        [
          Offset(0.22, 0.12), Offset(0.78, 0.12), Offset(0.45, 0.9),
        ]
      ],
    ),
    LetterStroke(
      character: '8',
      displayLabel: '8',
      strokes: [
        [
          Offset(0.5, 0.5), Offset(0.7, 0.35), Offset(0.72, 0.2),
          Offset(0.58, 0.1), Offset(0.38, 0.12), Offset(0.28, 0.28),
          Offset(0.32, 0.44), Offset(0.5, 0.5), Offset(0.72, 0.6),
          Offset(0.78, 0.75), Offset(0.68, 0.9), Offset(0.48, 0.92),
          Offset(0.28, 0.82), Offset(0.22, 0.65), Offset(0.35, 0.52),
          Offset(0.5, 0.5),
        ]
      ],
    ),
    LetterStroke(
      character: '9',
      displayLabel: '9',
      strokes: [
        [
          Offset(0.5, 0.55), Offset(0.72, 0.48), Offset(0.78, 0.32),
          Offset(0.7, 0.15), Offset(0.5, 0.08), Offset(0.3, 0.15),
          Offset(0.22, 0.32), Offset(0.28, 0.5), Offset(0.45, 0.58),
          Offset(0.68, 0.55), Offset(0.78, 0.7), Offset(0.75, 0.9),
        ]
      ],
    ),
  ];

  // ─── Huruf A-Z (subset, bisa diperluas) ──────────────────
  static final List<LetterStroke> huruf = [
    LetterStroke(
      character: 'A', displayLabel: 'A',
      strokes: [
        [Offset(0.5, 0.1), Offset(0.15, 0.9)],
        [Offset(0.5, 0.1), Offset(0.85, 0.9)],
        [Offset(0.28, 0.6), Offset(0.72, 0.6)],
      ],
    ),
    LetterStroke(
      character: 'B', displayLabel: 'B',
      strokes: [
        [Offset(0.3, 0.1), Offset(0.3, 0.9)],
        [
          Offset(0.3, 0.1), Offset(0.65, 0.12), Offset(0.75, 0.25),
          Offset(0.65, 0.48), Offset(0.3, 0.5),
        ],
        [
          Offset(0.3, 0.5), Offset(0.7, 0.52), Offset(0.8, 0.68),
          Offset(0.7, 0.87), Offset(0.3, 0.9),
        ],
      ],
    ),
    LetterStroke(
      character: 'C', displayLabel: 'C',
      strokes: [
        [
          Offset(0.78, 0.25), Offset(0.62, 0.12), Offset(0.4, 0.1),
          Offset(0.22, 0.28), Offset(0.18, 0.5), Offset(0.22, 0.72),
          Offset(0.4, 0.9), Offset(0.62, 0.88), Offset(0.78, 0.75),
        ]
      ],
    ),
    LetterStroke(
      character: 'D', displayLabel: 'D',
      strokes: [
        [Offset(0.3, 0.1), Offset(0.3, 0.9)],
        [
          Offset(0.3, 0.1), Offset(0.65, 0.12), Offset(0.75, 0.25),
          Offset(0.75, 0.75), Offset(0.65, 0.88), Offset(0.3, 0.9),
        ],
      ],
    ),
    LetterStroke(
      character: 'E', displayLabel: 'E',
      strokes: [
        [Offset(0.3, 0.1), Offset(0.3, 0.9)],
        [Offset(0.3, 0.1), Offset(0.7, 0.1)],
        [Offset(0.3, 0.5), Offset(0.6, 0.5)],
        [Offset(0.3, 0.9), Offset(0.7, 0.9)],
      ],
    ),
    LetterStroke(
      character: 'F', displayLabel: 'F',
      strokes: [
        [Offset(0.3, 0.1), Offset(0.3, 0.9)],
        [Offset(0.3, 0.1), Offset(0.7, 0.1)],
        [Offset(0.3, 0.5), Offset(0.6, 0.5)],
      ],
    ),
    LetterStroke(
      character: 'G', displayLabel: 'G',
      strokes: [
        [
          Offset(0.78, 0.25), Offset(0.62, 0.12), Offset(0.4, 0.1),
          Offset(0.22, 0.28), Offset(0.18, 0.5), Offset(0.22, 0.72),
          Offset(0.4, 0.9), Offset(0.62, 0.88), Offset(0.78, 0.75),
          Offset(0.78, 0.5), Offset(0.5, 0.5),
        ]
      ],
    ),
    LetterStroke(
      character: 'H', displayLabel: 'H',
      strokes: [
        [Offset(0.25, 0.1), Offset(0.25, 0.9)],
        [Offset(0.75, 0.1), Offset(0.75, 0.9)],
        [Offset(0.25, 0.5), Offset(0.75, 0.5)],
      ],
    ),
    LetterStroke(
      character: 'I', displayLabel: 'I',
      strokes: [
        [Offset(0.5, 0.1), Offset(0.5, 0.9)],
        [Offset(0.3, 0.1), Offset(0.7, 0.1)],
        [Offset(0.3, 0.9), Offset(0.7, 0.9)],
      ],
    ),
    LetterStroke(
      character: 'J', displayLabel: 'J',
      strokes: [
        [Offset(0.3, 0.1), Offset(0.7, 0.1)],
        [
          Offset(0.5, 0.1), Offset(0.5, 0.75), Offset(0.4, 0.9),
          Offset(0.2, 0.85),
        ]
      ],
    ),
    LetterStroke(
      character: 'K', displayLabel: 'K',
      strokes: [
        [Offset(0.3, 0.1), Offset(0.3, 0.9)],
        [Offset(0.7, 0.1), Offset(0.3, 0.5)],
        [Offset(0.3, 0.5), Offset(0.7, 0.9)],
      ],
    ),
    LetterStroke(
      character: 'L', displayLabel: 'L',
      strokes: [
        [Offset(0.35, 0.1), Offset(0.35, 0.9)],
        [Offset(0.35, 0.9), Offset(0.75, 0.9)],
      ],
    ),
    LetterStroke(
      character: 'M', displayLabel: 'M',
      strokes: [
        [Offset(0.2, 0.9), Offset(0.2, 0.1)],
        [Offset(0.2, 0.1), Offset(0.5, 0.5)],
        [Offset(0.5, 0.5), Offset(0.8, 0.1)],
        [Offset(0.8, 0.1), Offset(0.8, 0.9)],
      ],
    ),
    LetterStroke(
      character: 'N', displayLabel: 'N',
      strokes: [
        [Offset(0.25, 0.9), Offset(0.25, 0.1)],
        [Offset(0.25, 0.1), Offset(0.75, 0.9)],
        [Offset(0.75, 0.9), Offset(0.75, 0.1)],
      ],
    ),
    LetterStroke(
      character: 'O', displayLabel: 'O',
      strokes: [
        [
          Offset(0.5, 0.1), Offset(0.75, 0.28), Offset(0.82, 0.5),
          Offset(0.75, 0.72), Offset(0.5, 0.9), Offset(0.25, 0.72),
          Offset(0.18, 0.5), Offset(0.25, 0.28), Offset(0.5, 0.1),
        ]
      ],
    ),
    LetterStroke(
      character: 'P', displayLabel: 'P',
      strokes: [
        [Offset(0.3, 0.1), Offset(0.3, 0.9)],
        [
          Offset(0.3, 0.1), Offset(0.65, 0.12), Offset(0.75, 0.25),
          Offset(0.75, 0.35), Offset(0.65, 0.48), Offset(0.3, 0.5),
        ],
      ],
    ),
    LetterStroke(
      character: 'Q', displayLabel: 'Q',
      strokes: [
        [
          Offset(0.5, 0.1), Offset(0.75, 0.28), Offset(0.82, 0.5),
          Offset(0.75, 0.72), Offset(0.5, 0.9), Offset(0.25, 0.72),
          Offset(0.18, 0.5), Offset(0.25, 0.28), Offset(0.5, 0.1),
        ],
        [Offset(0.6, 0.6), Offset(0.85, 0.85)],
      ],
    ),
    LetterStroke(
      character: 'R', displayLabel: 'R',
      strokes: [
        [Offset(0.3, 0.1), Offset(0.3, 0.9)],
        [
          Offset(0.3, 0.1), Offset(0.65, 0.12), Offset(0.75, 0.25),
          Offset(0.75, 0.35), Offset(0.65, 0.48), Offset(0.3, 0.5),
        ],
        [Offset(0.45, 0.5), Offset(0.75, 0.9)],
      ],
    ),
    LetterStroke(
      character: 'S', displayLabel: 'S',
      strokes: [
        [
          Offset(0.78, 0.2), Offset(0.6, 0.1), Offset(0.38, 0.12),
          Offset(0.22, 0.28), Offset(0.3, 0.45), Offset(0.55, 0.5),
          Offset(0.75, 0.58), Offset(0.78, 0.75), Offset(0.62, 0.88),
          Offset(0.4, 0.9), Offset(0.22, 0.78),
        ]
      ],
    ),
    LetterStroke(
      character: 'T', displayLabel: 'T',
      strokes: [
        [Offset(0.2, 0.1), Offset(0.8, 0.1)],
        [Offset(0.5, 0.1), Offset(0.5, 0.9)],
      ],
    ),
    LetterStroke(
      character: 'U', displayLabel: 'U',
      strokes: [
        [
          Offset(0.25, 0.1), Offset(0.25, 0.7), Offset(0.35, 0.85),
          Offset(0.5, 0.9), Offset(0.65, 0.85), Offset(0.75, 0.7),
          Offset(0.75, 0.1),
        ]
      ],
    ),
    LetterStroke(
      character: 'V', displayLabel: 'V',
      strokes: [
        [Offset(0.2, 0.1), Offset(0.5, 0.9)],
        [Offset(0.5, 0.9), Offset(0.8, 0.1)],
      ],
    ),
    LetterStroke(
      character: 'W', displayLabel: 'W',
      strokes: [
        [Offset(0.15, 0.1), Offset(0.3, 0.9)],
        [Offset(0.3, 0.9), Offset(0.5, 0.5)],
        [Offset(0.5, 0.5), Offset(0.7, 0.9)],
        [Offset(0.7, 0.9), Offset(0.85, 0.1)],
      ],
    ),
    LetterStroke(
      character: 'X', displayLabel: 'X',
      strokes: [
        [Offset(0.2, 0.1), Offset(0.8, 0.9)],
        [Offset(0.8, 0.1), Offset(0.2, 0.9)],
      ],
    ),
    LetterStroke(
      character: 'Y', displayLabel: 'Y',
      strokes: [
        [Offset(0.2, 0.1), Offset(0.5, 0.5)],
        [Offset(0.8, 0.1), Offset(0.5, 0.5)],
        [Offset(0.5, 0.5), Offset(0.5, 0.9)],
      ],
    ),
    LetterStroke(
      character: 'Z', displayLabel: 'Z',
      strokes: [
        [Offset(0.2, 0.1), Offset(0.8, 0.1)],
        [Offset(0.8, 0.1), Offset(0.2, 0.9)],
        [Offset(0.2, 0.9), Offset(0.8, 0.9)],
      ],
    ),
  ];

  static List<LetterStroke> get allItems => [...angka, ...huruf];
}
