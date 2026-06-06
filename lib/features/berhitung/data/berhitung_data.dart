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
      // Menghitung (1-10)
      BerhitungSoal(type: SoalType.menghitung, angkaA: 3, item: items[0], pertanyaan: 'Masukkan 3 apel ke dalam kotak!'),
      BerhitungSoal(type: SoalType.menghitung, angkaA: 5, item: items[1], pertanyaan: 'Masukkan 5 bintang ke dalam kotak!'),
      BerhitungSoal(type: SoalType.menghitung, angkaA: 4, item: items[2], pertanyaan: 'Masukkan 4 bunga ke dalam kotak!'),
      BerhitungSoal(type: SoalType.menghitung, angkaA: 2, item: items[3], pertanyaan: 'Masukkan 2 balon ke dalam kotak!'),
      BerhitungSoal(type: SoalType.menghitung, angkaA: 6, item: items[4], pertanyaan: 'Masukkan 6 permen ke dalam kotak!'),
      BerhitungSoal(type: SoalType.menghitung, angkaA: 8, item: items[5], pertanyaan: 'Masukkan 8 roket ke dalam kotak!'),
      BerhitungSoal(type: SoalType.menghitung, angkaA: 7, item: items[6], pertanyaan: 'Masukkan 7 pelangi ke dalam kotak!'),
      BerhitungSoal(type: SoalType.menghitung, angkaA: 10, item: items[7], pertanyaan: 'Masukkan 10 not ke dalam kotak!'),
      BerhitungSoal(type: SoalType.menghitung, angkaA: 9, item: items[0], pertanyaan: 'Masukkan 9 apel ke dalam kotak!'),
      BerhitungSoal(type: SoalType.menghitung, angkaA: 1, item: items[1], pertanyaan: 'Masukkan 1 bintang ke dalam kotak!'),
      
      // Penjumlahan (Hasil s.d 10)
      BerhitungSoal(type: SoalType.penjumlahan, angkaA: 2, angkaB: 3, item: items[4], pertanyaan: '2 + 3 permen = ?'),
      BerhitungSoal(type: SoalType.penjumlahan, angkaA: 1, angkaB: 4, item: items[5], pertanyaan: '1 + 4 roket = ?'),
      BerhitungSoal(type: SoalType.penjumlahan, angkaA: 3, angkaB: 2, item: items[6], pertanyaan: '3 + 2 pelangi = ?'),
      BerhitungSoal(type: SoalType.penjumlahan, angkaA: 4, angkaB: 4, item: items[2], pertanyaan: '4 + 4 bunga = ?'),
      BerhitungSoal(type: SoalType.penjumlahan, angkaA: 5, angkaB: 5, item: items[3], pertanyaan: '5 + 5 balon = ?'),
      BerhitungSoal(type: SoalType.penjumlahan, angkaA: 6, angkaB: 3, item: items[0], pertanyaan: '6 + 3 apel = ?'),
      BerhitungSoal(type: SoalType.penjumlahan, angkaA: 7, angkaB: 1, item: items[1], pertanyaan: '7 + 1 bintang = ?'),
      BerhitungSoal(type: SoalType.penjumlahan, angkaA: 2, angkaB: 6, item: items[7], pertanyaan: '2 + 6 not = ?'),

      // Pengurangan (Angka awal s.d 10)
      BerhitungSoal(type: SoalType.pengurangan, angkaA: 5, angkaB: 2, item: items[0], pertanyaan: '5 - 2 apel = ?'),
      BerhitungSoal(type: SoalType.pengurangan, angkaA: 4, angkaB: 1, item: items[7], pertanyaan: '4 - 1 not = ?'),
      BerhitungSoal(type: SoalType.pengurangan, angkaA: 3, angkaB: 3, item: items[1], pertanyaan: '3 - 3 bintang = ?'),
      BerhitungSoal(type: SoalType.pengurangan, angkaA: 8, angkaB: 4, item: items[4], pertanyaan: '8 - 4 permen = ?'),
      BerhitungSoal(type: SoalType.pengurangan, angkaA: 10, angkaB: 3, item: items[5], pertanyaan: '10 - 3 roket = ?'),
      BerhitungSoal(type: SoalType.pengurangan, angkaA: 7, angkaB: 5, item: items[2], pertanyaan: '7 - 5 bunga = ?'),
      BerhitungSoal(type: SoalType.pengurangan, angkaA: 9, angkaB: 6, item: items[6], pertanyaan: '9 - 6 pelangi = ?'),
    ];
  }
}
