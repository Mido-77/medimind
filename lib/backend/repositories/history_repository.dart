import '../database/local_database.dart';
import '../models/history_entry.dart';
import '../models/medicine.dart';

class HistoryRepository {
  final LocalDatabase _db = LocalDatabase.instance;

  Future<List<HistoryEntry>> getAll() async {
    final raw = await _db.getHistory();
    return raw.map(HistoryEntry.fromJson).toList()
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  }

  Future<void> add(HistoryEntry entry) async {
    await _db.saveHistoryEntry(entry.toJson());
  }

  Future<void> addFromMedicine(Medicine medicine, MedicineStatus status) async {
    final entry = HistoryEntry(
      id: HistoryEntry.generateId(),
      medicineId: medicine.id,
      medicineName: medicine.name,
      dose: medicine.dose,
      time: medicine.time,
      status: status,
      occurredAt: DateTime.now(),
    );
    await add(entry);
  }

  Future<List<HistoryEntry>> getToday() async {
    final all = await getAll();
    final today = DateTime.now();
    return all.where((e) {
      return e.occurredAt.year == today.year &&
          e.occurredAt.month == today.month &&
          e.occurredAt.day == today.day;
    }).toList();
  }

  Future<List<HistoryEntry>> getForDateRange(
      DateTime start, DateTime end) async {
    final all = await getAll();
    return all.where((e) {
      return e.occurredAt.isAfter(start.subtract(const Duration(seconds: 1))) &&
          e.occurredAt.isBefore(end.add(const Duration(seconds: 1)));
    }).toList();
  }

  Future<Map<DateTime, List<HistoryEntry>>> getGroupedByDate() async {
    final all = await getAll();
    final Map<DateTime, List<HistoryEntry>> grouped = {};
    for (final entry in all) {
      final date = DateTime(
        entry.occurredAt.year,
        entry.occurredAt.month,
        entry.occurredAt.day,
      );
      grouped.putIfAbsent(date, () => []).add(entry);
    }
    return grouped;
  }

  Future<void> deleteByMedicineId(String medicineId) async {
    final all = await getAll();
    final filtered = all.where((e) => e.medicineId != medicineId).toList();
    await _db.saveHistory(filtered.map((e) => e.toJson()).toList());
  }

  Future<void> seedDefaults() async {
    final existing = await getAll();
    if (existing.isNotEmpty) return;

    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final twoDaysAgo = now.subtract(const Duration(days: 2));

    final defaults = [
      HistoryEntry(
        id: 'h_1',
        medicineId: 'med_1',
        medicineName: 'Lisinopril',
        dose: '10 mg',
        time: '08:00 AM',
        status: MedicineStatus.taken,
        occurredAt: DateTime(yesterday.year, yesterday.month, yesterday.day, 8, 5),
      ),
      HistoryEntry(
        id: 'h_2',
        medicineId: 'med_2',
        medicineName: 'Metformin',
        dose: '500 mg',
        time: '01:00 PM',
        status: MedicineStatus.takenLate,
        occurredAt: DateTime(yesterday.year, yesterday.month, yesterday.day, 13, 45),
      ),
      HistoryEntry(
        id: 'h_3',
        medicineId: 'med_3',
        medicineName: 'Vitamin D3',
        dose: '1000 IU',
        time: '09:00 AM',
        status: MedicineStatus.missed,
        occurredAt: DateTime(yesterday.year, yesterday.month, yesterday.day, 9, 0),
      ),
      HistoryEntry(
        id: 'h_4',
        medicineId: 'med_1',
        medicineName: 'Lisinopril',
        dose: '10 mg',
        time: '08:00 AM',
        status: MedicineStatus.taken,
        occurredAt: DateTime(twoDaysAgo.year, twoDaysAgo.month, twoDaysAgo.day, 8, 2),
      ),
      HistoryEntry(
        id: 'h_5',
        medicineId: 'med_4',
        medicineName: 'Aspirin',
        dose: '81 mg',
        time: '07:00 PM',
        status: MedicineStatus.taken,
        occurredAt: DateTime(twoDaysAgo.year, twoDaysAgo.month, twoDaysAgo.day, 19, 10),
      ),
    ];
    await _db.saveHistory(defaults.map((e) => e.toJson()).toList());
  }
}
