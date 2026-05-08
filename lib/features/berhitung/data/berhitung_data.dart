// Dataset untuk modul Berhitung
// Tipe soal: Menghitung objek, penjumlahan visual, pengurangan visual

import 'package:flutter/material.dart';

class BerhitungItem {
  final String emoji;
  final String nama;
  final Color color;

  const BerhitungItem({
    required this.emoji,
    required this.nama,
    required this.color,
  });
}

enum SoalType { menghitung, penjumlahan, pengurangan }

class BerhitungSoal {
  final SoalType type;
  final int angkaA;
  final int angkaB; // 0 jika tipe menghitung
  final BerhitungItem item;
  final String pertanyaan;

  const BerhitungSoal({
    required this.type,
    required this.angkaA,
    required this.item,
    this.angkaB = 0,
    required this.pertanyaan,
  });

  int get jawaban {
    switch (type) {
      case SoalType.menghitung:
        return angkaA;
      case SoalType.penjumlahan:
        return angkaA + angkaB;
      case SoalType.pengurangan:
        return angkaA - angkaB;
    }
  }
}

class BerhitungData {
  BerhitungData._();

  static const List<BerhitungItem> items = [
    BerhitungItem(emoji: '🍎', nama: 'apel', color: Color(0xFFE53935)),
    BerhitungItem(emoji: '⭐', nama: 'bintang', color: Color(0xFFFFCA28)),
    BerhitungItem(emoji: '🌸', nama: 'bunga', color: Color(0xFFF48FB1)),
    BerhitungItem(emoji: '🎈', nama: 'balon', color: Color(0xFF42A5F5)),
    BerhitungItem(emoji: '🍭', nama: 'permen', color: Color(0xFFAB47BC)),
    BerhitungItem(emoji: '🚀', nama: 'roket', color: Color(0xFF26C6DA)),
    BerhitungItem(emoji: '🌈', nama: 'pelangi', color: Color(0xFF66BB6A)),
    BerhitungItem(emoji: '🎵', nama: 'not', color: Color(0xFFFF7043)),
  ];

  static List<BerhitungSoal> generateSoalList() {
    return [
      // Menghitung (1-5)
      BerhitungSoal(
        type: SoalType.menghitung,
        angkaA: 3,
        item: items[0],
        pertanyaan: 'Ada berapa apel di sini?',
      ),
      BerhitungSoal(
        type: SoalType.menghitung,
        angkaA: 5,
        item: items[1],
        pertanyaan: 'Hitung bintang berikut!',
      ),
      BerhitungSoal(
        type: SoalType.menghitung,
        angkaA: 4,
        item: items[2],
        pertanyaan: 'Ada berapa bunga?',
      ),
      BerhitungSoal(
        type: SoalType.menghitung,
        angkaA: 2,
        item: items[3],
        pertanyaan: 'Hitung balon ini!',
      ),
      // Penjumlahan sederhana
      BerhitungSoal(
        type: SoalType.penjumlahan,
        angkaA: 2,
        angkaB: 3,
        item: items[4],
        pertanyaan: '2 + 3 permen = ?',
      ),
      BerhitungSoal(
        type: SoalType.penjumlahan,
        angkaA: 1,
        angkaB: 4,
        item: items[5],
        pertanyaan: '1 + 4 roket = ?',
      ),
      BerhitungSoal(
        type: SoalType.penjumlahan,
        angkaA: 3,
        angkaB: 2,
        item: items[6],
        pertanyaan: '3 + 2 pelangi = ?',
      ),
      // Pengurangan sederhana
      BerhitungSoal(
        type: SoalType.pengurangan,
        angkaA: 5,
        angkaB: 2,
        item: items[0],
        pertanyaan: '5 - 2 apel = ?',
      ),
      BerhitungSoal(
        type: SoalType.pengurangan,
        angkaA: 4,
        angkaB: 1,
        item: items[7],
        pertanyaan: '4 - 1 not = ?',
      ),
      BerhitungSoal(
        type: SoalType.pengurangan,
        angkaA: 3,
        angkaB: 3,
        item: items[1],
        pertanyaan: '3 - 3 bintang = ?',
      ),
    ];
  }
}
