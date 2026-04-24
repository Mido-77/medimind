import 'medicine.dart';

class HistoryEntry {
  final String id;
  final String medicineId;
  final String medicineName;
  final String dose;
  final String time;
  final MedicineStatus status;
  final DateTime occurredAt;
  final String? notes;

  const HistoryEntry({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.dose,
    required this.time,
    required this.status,
    required this.occurredAt,
    this.notes,
  });

  bool get isTaken => status == MedicineStatus.taken;
  bool get isMissed => status == MedicineStatus.missed;
  bool get isTakenLate => status == MedicineStatus.takenLate;

  String get statusLabel => status.label;

  Map<String, dynamic> toJson() => {
        'id': id,
        'medicineId': medicineId,
        'medicineName': medicineName,
        'dose': dose,
        'time': time,
        'status': status.name,
        'occurredAt': occurredAt.toIso8601String(),
        'notes': notes,
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      id: json['id'] as String? ?? 'h_${DateTime.now().millisecondsSinceEpoch}',
      medicineId: json['medicineId'] as String? ?? '',
      medicineName: json['medicineName'] as String? ??
          (json['message'] as String? ?? 'Unknown'),
      dose: json['dose'] as String? ?? '',
      time: json['time'] as String? ?? '',
      status: MedicineStatusExt.fromString(json['status'] as String? ?? 'taken'),
      occurredAt: json['occurredAt'] != null
          ? DateTime.parse(json['occurredAt'] as String)
          : DateTime.now(),
      notes: json['notes'] as String?,
    );
  }

  static String generateId() =>
      'hist_${DateTime.now().millisecondsSinceEpoch}';
}
