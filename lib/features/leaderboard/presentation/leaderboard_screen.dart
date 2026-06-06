import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/database/battle_database.dart';
import '../../../core/theme/app_theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<BattleResult> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await BattleDatabase.getHistory();
    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '🏆 Riwayat Pertarungan',
                    style: GoogleFonts.nunito(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _history.isEmpty
                      ? Center(
                          child: Text(
                            'Belum ada pertarungan!\nAyo mulai mode Kompetisi!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMedium,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          itemCount: _history.length,
                          itemBuilder: (context, i) {
                            final res = _history[i];
                            return _ResultCard(res: res);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final BattleResult res;

  const _ResultCard({required this.res});

  @override
  Widget build(BuildContext context) {
    final dateObj = DateTime.parse(res.date);
    final dateStr = '${dateObj.day}/${dateObj.month}/${dateObj.year} ${dateObj.hour}:${dateObj.minute.toString().padLeft(2, '0')}';

    final isBlueWin = res.blueScore > res.redScore;
    final isRedWin = res.redScore > res.blueScore;
    final isDraw = res.blueScore == res.redScore;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Tanggal
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Text(
              dateStr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // Row Score
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Tim Biru
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '🔵 ${res.blueName}',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColors.teamBlue,
                        ),
                      ),
                      Text(
                        '${res.blueScore}',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                          color: AppColors.teamBlue,
                        ),
                      ),
                      if (isBlueWin)
                        const Text('👑 WINNER', style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),

                // VS
                Text(
                  'VS',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: Colors.grey.shade400,
                  ),
                ),

                // Tim Merah
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '🔴 ${res.redName}',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColors.teamRed,
                        ),
                      ),
                      Text(
                        '${res.redScore}',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                          color: AppColors.teamRed,
                        ),
                      ),
                      if (isRedWin)
                        const Text('👑 WINNER', style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isDraw)
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text('🤝 SERI', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}
