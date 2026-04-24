import '../models/history_entry.dart';
import '../models/medicine.dart';
import '../repositories/history_repository.dart';
import '../repositories/medicine_repository.dart';

class DayStats {
  final DateTime date;
  final int taken;
  final int missed;
  final int takenLate;
  final int total;

  const DayStats({
    required this.date,
    required this.taken,
    required this.missed,
    required this.takenLate,
    required this.total,
  });

  double get adherenceRate => total == 0 ? 0 : (taken + takenLate) / total;
}

class OverallStats {
  final int totalTaken;
  final int totalMissed;
  final int totalTakenLate;
  final int currentStreak;
  final double weeklyAdherence;
  final List<DayStats> last7Days;

  const OverallStats({
    required this.totalTaken,
    required this.totalMissed,
    required this.totalTakenLate,
    required this.currentStreak,
    required this.weeklyAdherence,
    required this.last7Days,
  });

  int get totalDoses => totalTaken + totalMissed + totalTakenLate;
  double get overallRate =>
      totalDoses == 0 ? 0 : (totalTaken + totalTakenLate) / totalDoses;
}

class StatsService {
  final HistoryRepository _histRepo = HistoryRepository();
  final MedicineRepository _medRepo = MedicineRepository();

  Future<OverallStats> getStats() async {
    final allHistory = await _histRepo.getAll();
    final last7 = await _getLast7DaysStats(allHistory);

    int taken = 0, missed = 0, takenLate = 0;
    for (final e in allHistory) {
      if (e.status == MedicineStatus.taken) taken++;
      if (e.status == MedicineStatus.missed) missed++;
      if (e.status == MedicineStatus.takenLate) takenLate++;
    }

    final streak = await _computeStreak(allHistory);
    final weekAdh = last7.isEmpty
        ? 0.0
        : last7.map((d) => d.adherenceRate).reduce((a, b) => a + b) /
            last7.length;

    return OverallStats(
      totalTaken: taken,
      totalMissed: missed,
      totalTakenLate: takenLate,
      currentStreak: streak,
      weeklyAdherence: weekAdh,
      last7Days: last7,
    );
  }

  Future<List<DayStats>> _getLast7DaysStats(
      List<HistoryEntry> history) async {
    final today = DateTime.now();
    final result = <DayStats>[];

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayEntries = history.where((e) {
        return e.occurredAt.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
            e.occurredAt.isBefore(dayEnd);
      }).toList();

      int t = 0, m = 0, tl = 0;
      for (final e in dayEntries) {
        if (e.status == MedicineStatus.taken) t++;
        if (e.status == MedicineStatus.missed) m++;
        if (e.status == MedicineStatus.takenLate) tl++;
      }

      result.add(DayStats(
        date: dayStart,
        taken: t,
        missed: m,
        takenLate: tl,
        total: dayEntries.length,
      ));
    }
    return result;
  }

  Future<int> _computeStreak(List<HistoryEntry> history) async {
    if (history.isEmpty) return 0;

    final today = DateTime.now();
    int streak = 0;

    for (int i = 0; i < 30; i++) {
      final date = today.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayEntries = history.where((e) {
        return e.occurredAt.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
            e.occurredAt.isBefore(dayEnd);
      }).toList();

      if (dayEntries.isEmpty && i == 0) continue; // today not counted yet
      if (dayEntries.isEmpty) break;

      final hasMissed = dayEntries.any((e) => e.status == MedicineStatus.missed);
      if (hasMissed) break;
      streak++;
    }
    return streak;
  }
}
