import 'dart:ui';

enum ChallengeType { membaca, menulis, berhitung }

abstract class CompetitiveChallenge {
  const CompetitiveChallenge();
  ChallengeType get type;
}

/// Membaca: susun suku kata dengan drag-and-drop ke kotak yang benar
class MembacaChallenge extends CompetitiveChallenge {
  final String kata;
  final String emoji;
  final List<String> sukuKata; // urutan yang benar

  @override
  ChallengeType get type => ChallengeType.membaca;

  const MembacaChallenge({
    required this.kata,
    required this.emoji,
    required this.sukuKata,
  });
}

/// Menulis: gambar karakter bebas di layar, cek apakah jalur melewati key-points
class MenulisChallenge extends CompetitiveChallenge {
  final String character;
  final String displayLabel;
  final List<Offset> keyPoints; // titik-titik kritis (normalized 0.0–1.0)

  @override
  ChallengeType get type => ChallengeType.menulis;

  const MenulisChallenge({
    required this.character,
    required this.displayLabel,
    required this.keyPoints,
  });
}

/// Berhitung: drag emoji ke kotak sejumlah target (Flame)
class BerhitungChallenge extends CompetitiveChallenge {
  final String emoji;
  final String itemName;
  final int targetCount;
  final String question;
  final int totalSpawned;

  @override
  ChallengeType get type => ChallengeType.berhitung;

  const BerhitungChallenge({
    required this.emoji,
    required this.itemName,
    required this.targetCount,
    required this.question,
    this.totalSpawned = 6,
  });
}

// ─── Question Bank ─────────────────────────────────────────────
class CompetitiveQuestions {
  CompetitiveQuestions._();

  /// 5 soal membaca — susun suku kata
  static List<MembacaChallenge> get membacaList => [
        const MembacaChallenge(kata: 'BOLA', emoji: '⚽', sukuKata: ['BO', 'LA']),
        const MembacaChallenge(kata: 'SAPI', emoji: '🐄', sukuKata: ['SA', 'PI']),
        const MembacaChallenge(kata: 'BUKU', emoji: '📚', sukuKata: ['BU', 'KU']),
        const MembacaChallenge(kata: 'TOPI', emoji: '🎩', sukuKata: ['TO', 'PI']),
        const MembacaChallenge(kata: 'MEJA', emoji: '🪑', sukuKata: ['ME', 'JA']),
      ];

  /// 5 soal menulis — gambar karakter, cek key-points
  static List<MenulisChallenge> get menulisList => [
        const MenulisChallenge(
          character: 'C',
          displayLabel: 'Huruf C',
          keyPoints: [
            Offset(0.70, 0.20),
            Offset(0.30, 0.20),
            Offset(0.30, 0.80),
            Offset(0.70, 0.80),
          ],
        ),
        const MenulisChallenge(
          character: 'V',
          displayLabel: 'Huruf V',
          keyPoints: [
            Offset(0.25, 0.20),
            Offset(0.50, 0.85),
            Offset(0.75, 0.20),
          ],
        ),
        const MenulisChallenge(
          character: '1',
          displayLabel: 'Angka 1',
          keyPoints: [
            Offset(0.35, 0.30),
            Offset(0.50, 0.15),
            Offset(0.50, 0.85),
          ],
        ),
        const MenulisChallenge(
          character: 'L',
          displayLabel: 'Huruf L',
          keyPoints: [
            Offset(0.35, 0.15),
            Offset(0.35, 0.85),
            Offset(0.75, 0.85),
          ],
        ),
        const MenulisChallenge(
          character: 'Z',
          displayLabel: 'Huruf Z',
          keyPoints: [
            Offset(0.25, 0.20),
            Offset(0.75, 0.20),
            Offset(0.25, 0.80),
            Offset(0.75, 0.80),
          ],
        ),
      ];

  /// 5 soal berhitung — drag emoji ke kotak
  static List<BerhitungChallenge> get berhitungList => [
        const BerhitungChallenge(
          emoji: '🍎', itemName: 'apel',
          targetCount: 3, question: 'Seret 3 apel ke kotak!', totalSpawned: 6,
        ),
        const BerhitungChallenge(
          emoji: '⭐', itemName: 'bintang',
          targetCount: 2, question: 'Seret 2 bintang ke kotak!', totalSpawned: 5,
        ),
        const BerhitungChallenge(
          emoji: '🎈', itemName: 'balon',
          targetCount: 4, question: 'Seret 4 balon ke kotak!', totalSpawned: 7,
        ),
        const BerhitungChallenge(
          emoji: '🍭', itemName: 'permen',
          targetCount: 3, question: 'Seret 3 permen ke kotak!', totalSpawned: 6,
        ),
        const BerhitungChallenge(
          emoji: '🐟', itemName: 'ikan',
          targetCount: 2, question: 'Seret 2 ikan ke kotak!', totalSpawned: 5,
        ),
      ];
}
