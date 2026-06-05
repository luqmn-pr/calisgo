// Data model untuk modul Membaca
// Dataset: Huruf A-Z + 10 kata dasar beserta ilustrasi emoji

class HurufModel {
  final String huruf;
  final String hurufKecil;
  final String contohKata;
  final String emoji;
  final String audio; // placeholder

  const HurufModel({
    required this.huruf,
    required this.hurufKecil,
    required this.contohKata,
    required this.emoji,
    required this.audio,
  });
}

class KataModel {
  final String kata;
  final List<String> sukuKata;
  final String emoji;

  const KataModel({
    required this.kata,
    required this.sukuKata,
    required this.emoji,
  });
}

class KalimatModel {
  final String kalimatUtuh;
  final List<String> potonganKata;
  final String emoji;

  const KalimatModel({
    required this.kalimatUtuh,
    required this.potonganKata,
    required this.emoji,
  });
}
class MembacaData {
  MembacaData._();

  static const List<HurufModel> hurufAZ = [
    HurufModel(huruf: 'A', hurufKecil: 'a', contohKata: 'Apel', emoji: '🍎', audio: ''),
    HurufModel(huruf: 'B', hurufKecil: 'b', contohKata: 'Buku', emoji: '📚', audio: ''),
    HurufModel(huruf: 'C', hurufKecil: 'c', contohKata: 'Ceria', emoji: '😄', audio: ''),
    HurufModel(huruf: 'D', hurufKecil: 'd', contohKata: 'Dadu', emoji: '🎲', audio: ''),
    HurufModel(huruf: 'E', hurufKecil: 'e', contohKata: 'Elang', emoji: '🦅', audio: ''),
    HurufModel(huruf: 'F', hurufKecil: 'f', contohKata: 'Foto', emoji: '📷', audio: ''),
    HurufModel(huruf: 'G', hurufKecil: 'g', contohKata: 'Gitar', emoji: '🎸', audio: ''),
    HurufModel(huruf: 'H', hurufKecil: 'h', contohKata: 'Hujan', emoji: '🌧️', audio: ''),
    HurufModel(huruf: 'I', hurufKecil: 'i', contohKata: 'Ikan', emoji: '🐟', audio: ''),
    HurufModel(huruf: 'J', hurufKecil: 'j', contohKata: 'Jeruk', emoji: '🍊', audio: ''),
    HurufModel(huruf: 'K', hurufKecil: 'k', contohKata: 'Kupu', emoji: '🦋', audio: ''),
    HurufModel(huruf: 'L', hurufKecil: 'l', contohKata: 'Lampu', emoji: '💡', audio: ''),
    HurufModel(huruf: 'M', hurufKecil: 'm', contohKata: 'Meja', emoji: '🪑', audio: ''),
    HurufModel(huruf: 'N', hurufKecil: 'n', contohKata: 'Nasi', emoji: '🍚', audio: ''),
    HurufModel(huruf: 'O', hurufKecil: 'o', contohKata: 'Obat', emoji: '💊', audio: ''),
    HurufModel(huruf: 'P', hurufKecil: 'p', contohKata: 'Pensil', emoji: '✏️', audio: ''),
    HurufModel(huruf: 'Q', hurufKecil: 'q', contohKata: 'Quran', emoji: '📖', audio: ''),
    HurufModel(huruf: 'R', hurufKecil: 'r', contohKata: 'Rumah', emoji: '🏠', audio: ''),
    HurufModel(huruf: 'S', hurufKecil: 's', contohKata: 'Sekolah', emoji: '🏫', audio: ''),
    HurufModel(huruf: 'T', hurufKecil: 't', contohKata: 'Topi', emoji: '🎩', audio: ''),
    HurufModel(huruf: 'U', hurufKecil: 'u', contohKata: 'Udara', emoji: '💨', audio: ''),
    HurufModel(huruf: 'V', hurufKecil: 'v', contohKata: 'Vila', emoji: '🏡', audio: ''),
    HurufModel(huruf: 'W', hurufKecil: 'w', contohKata: 'Wortel', emoji: '🥕', audio: ''),
    HurufModel(huruf: 'X', hurufKecil: 'x', contohKata: 'Xylofon', emoji: '🎵', audio: ''),
    HurufModel(huruf: 'Y', hurufKecil: 'y', contohKata: 'Yogurt', emoji: '🥛', audio: ''),
    HurufModel(huruf: 'Z', hurufKecil: 'z', contohKata: 'Zebra', emoji: '🦓', audio: ''),
  ];

  // Kata dengan suku kata untuk latihan menyusun
  static const List<KataModel> kataLatihan = [
    KataModel(kata: 'MAMA', sukuKata: ['MA', 'MA'], emoji: '👩'),
    KataModel(kata: 'PAPA', sukuKata: ['PA', 'PA'], emoji: '👨'),
    KataModel(kata: 'BOLA', sukuKata: ['BO', 'LA'], emoji: '⚽'),
    KataModel(kata: 'SAPI', sukuKata: ['SA', 'PI'], emoji: '🐄'),
    KataModel(kata: 'BUKU', sukuKata: ['BU', 'KU'], emoji: '📚'),
    KataModel(kata: 'MATA', sukuKata: ['MA', 'TA'], emoji: '👁️'),
    KataModel(kata: 'KAKI', sukuKata: ['KA', 'KI'], emoji: '🦵'),
    KataModel(kata: 'MEJA', sukuKata: ['ME', 'JA'], emoji: '🪑'),
    KataModel(kata: 'TOPI', sukuKata: ['TO', 'PI'], emoji: '🎩'),
    KataModel(kata: 'ROTI', sukuKata: ['RO', 'TI'], emoji: '🍞'),
    KataModel(kata: 'SUSU', sukuKata: ['SU', 'SU'], emoji: '🥛'),
    KataModel(kata: 'KUDA', sukuKata: ['KU', 'DA'], emoji: '🐴'),
  ];

  // Kalimat dengan kata terpisah untuk latihan menyusun gaya Duolingo
  static const List<KalimatModel> kalimatLatihan = [
    KalimatModel(kalimatUtuh: 'SAYA SUKA APEL', potonganKata: ['SAYA', 'SUKA', 'APEL'], emoji: '🍎'),
    KalimatModel(kalimatUtuh: 'BUKU ITU BARU', potonganKata: ['BUKU', 'ITU', 'BARU'], emoji: '📚'),
    KalimatModel(kalimatUtuh: 'MAMA BELI ROTI', potonganKata: ['MAMA', 'BELI', 'ROTI'], emoji: '🍞'),
    KalimatModel(kalimatUtuh: 'SAPI ITU BESAR', potonganKata: ['SAPI', 'ITU', 'BESAR'], emoji: '🐄'),
    KalimatModel(kalimatUtuh: 'ADIK MINUM SUSU', potonganKata: ['ADIK', 'MINUM', 'SUSU'], emoji: '🥛'),
  ];
}
