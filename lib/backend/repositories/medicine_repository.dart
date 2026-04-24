import '../database/local_database.dart';
import '../models/medicine.dart';

class MedicineRepository {
  final LocalDatabase _db = LocalDatabase.instance;

  Future<List<Medicine>> getAll() async {
    final raw = await _db.getMedicines();
    return raw.map(Medicine.fromJson).toList();
  }

  Future<void> save(Medicine medicine) async {
    await _db.saveMedicine(medicine.toJson());
  }

  Future<void> saveAll(List<Medicine> medicines) async {
    await _db.saveMedicines(medicines.map((m) => m.toJson()).toList());
  }

  Future<void> delete(String id) async {
    await _db.deleteMedicine(id);
  }

  Future<Medicine?> getById(String id) async {
    final json = await _db.getById(LocalDatabase.instance._medicinesKey ?? '', id);
    return json != null ? Medicine.fromJson(json) : null;
  }

  Future<void> updateStatus(String id, MedicineStatus status) async {
    final all = await getAll();
    final idx = all.indexWhere((m) => m.id == id);
    if (idx >= 0) {
      final updated = all[idx].copyWith(status: status);
      await save(updated);
    }
  }

  Future<bool> exists(String name, String time) async {
    final all = await getAll();
    return all.any(
      (m) =>
          m.name.toLowerCase() == name.toLowerCase() &&
          m.time == time &&
          m.isActive,
    );
  }

  Future<void> seedDefaults() async {
    final existing = await getAll();
    if (existing.isNotEmpty) return;

    final defaults = [
      Medicine(
        id: 'med_1',
        name: 'Lisinopril',
        dose: '10 mg',
        time: '08:00 AM',
        repeatDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        type: MedicineType.tablet,
        colorIndex: 0,
        createdAt: DateTime.now(),
      ),
      Medicine(
        id: 'med_2',
        name: 'Metformin',
        dose: '500 mg',
        time: '01:00 PM',
        repeatDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        type: MedicineType.tablet,
        colorIndex: 1,
        createdAt: DateTime.now(),
      ),
      Medicine(
        id: 'med_3',
        name: 'Vitamin D3',
        dose: '1000 IU',
        time: '09:00 AM',
        repeatDays: ['Mon', 'Wed', 'Fri'],
        type: MedicineType.capsule,
        colorIndex: 2,
        createdAt: DateTime.now(),
      ),
      Medicine(
        id: 'med_4',
        name: 'Aspirin',
        dose: '81 mg',
        time: '07:00 PM',
        repeatDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        type: MedicineType.tablet,
        colorIndex: 3,
        createdAt: DateTime.now(),
      ),
    ];
    await saveAll(defaults);
  }
}

// Make _medicinesKey accessible
extension _DbKey on LocalDatabase {
  String? get _medicinesKey => null; // unused, we use the named methods
}
