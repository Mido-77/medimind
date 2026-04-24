import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../app_state.dart';
import '../backend/models/history_entry.dart';
import '../backend/models/medicine.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  static const String routeName = '/history';
  final bool embedded;

  const HistoryScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final history = state.history;

    // Group by date
    final Map<String, List<HistoryEntry>> grouped = {};
    for (final entry in history) {
      final key = _dateKey(entry.occurredAt);
      grouped.putIfAbsent(key, () => []).add(entry);
    }
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          if (history.isEmpty)
            SliverToBoxAdapter(child: _buildEmpty())
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final key = sortedKeys[i];
                  final entries = grouped[key]!;
                  return _DaySection(dateKey: key, entries: entries);
                },
                childCount: sortedKeys.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.cyanGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Row(
            children: [
              if (!embedded)
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(38),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_ios_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'History',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Your medicine log',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withAlpha(204),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Center(
                child: Text('📋', style: TextStyle(fontSize: 44))),
          ),
          const SizedBox(height: 20),
          Text(
            'No history yet',
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your medicine intake will appear here',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _dateKey(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dt.year, dt.month, dt.day);

    if (date == today) return 'Today';
    if (date == yesterday) return 'Yesterday';
    return DateFormat('MMM d, yyyy').format(dt);
  }
}

class _DaySection extends StatelessWidget {
  final String dateKey;
  final List<HistoryEntry> entries;

  const _DaySection({required this.dateKey, required this.entries});

  @override
  Widget build(BuildContext context) {
    final taken = entries.where((e) => !e.isMissed).length;
    final total = entries.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                dateKey,
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: taken == total
                      ? AppColors.success.withAlpha(26)
                      : AppColors.error.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$taken/$total taken',
                  style: GoogleFonts.poppins(
                    color: taken == total
                        ? AppColors.success
                        : AppColors.error,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppShadows.soft,
            ),
            child: Column(
              children: entries
                  .asMap()
                  .entries
                  .map((e) => Column(
                        children: [
                          _HistoryRow(entry: e.value),
                          if (e.key < entries.length - 1)
                            Divider(
                              height: 1,
                              color: AppColors.divider,
                              indent: 72,
                            ),
                        ],
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final HistoryEntry entry;

  const _HistoryRow({required this.entry});

  Color get _statusColor {
    switch (entry.status) {
      case MedicineStatus.taken:
        return AppColors.success;
      case MedicineStatus.missed:
        return AppColors.error;
      case MedicineStatus.takenLate:
        return AppColors.warningDark;
      case MedicineStatus.pending:
        return AppColors.primary;
    }
  }

  IconData get _statusIcon {
    switch (entry.status) {
      case MedicineStatus.taken:
        return Icons.check_circle_rounded;
      case MedicineStatus.missed:
        return Icons.cancel_rounded;
      case MedicineStatus.takenLate:
        return Icons.watch_later_rounded;
      case MedicineStatus.pending:
        return Icons.radio_button_unchecked_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _statusColor.withAlpha(26),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Icon(_statusIcon, color: _statusColor, size: 22),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.medicineName,
                  style: GoogleFonts.poppins(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.dose.isNotEmpty
                      ? '${entry.dose} · ${entry.time}'
                      : entry.time,
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _statusColor.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              entry.statusLabel,
              style: GoogleFonts.poppins(
                color: _statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
