enum MedicineStatus { taken, pending, missed, takenLate }

enum MedicineType { tablet, capsule, liquid, injection, inhaler, drops }

extension MedicineTypeExt on MedicineType {
  String get label {
    switch (this) {
      case MedicineType.tablet:
        return 'Tablet';
      case MedicineType.capsule:
        return 'Capsule';
      case MedicineType.liquid:
        return 'Liquid';
      case MedicineType.injection:
        return 'Injection';
      case MedicineType.inhaler:
        return 'Inhaler';
      case MedicineType.drops:
        return 'Drops';
    }
  }

  String get icon {
    switch (this) {
      case MedicineType.tablet:
        return '💊';
      case MedicineType.capsule:
        return '💊';
      case MedicineType.liquid:
        return '🧪';
      case MedicineType.injection:
        return '💉';
      case MedicineType.inhaler:
        return '🫁';
      case MedicineType.drops:
        return '💧';
    }
  }
}

extension MedicineStatusExt on MedicineStatus {
  String get label {
    switch (this) {
      case MedicineStatus.taken:
        return 'Taken';
      case MedicineStatus.pending:
        return 'Pending';
      case MedicineStatus.missed:
        return 'Missed';
      case MedicineStatus.takenLate:
        return 'Taken Late';
    }
  }

  String get name {
    switch (this) {
      case MedicineStatus.taken:
        return 'taken';
      case MedicineStatus.pending:
        return 'pending';
      case MedicineStatus.missed:
        return 'missed';
      case MedicineStatus.takenLate:
        return 'takenLate';
    }
  }

  static MedicineStatus fromString(String value) {
    switch (value) {
      case 'taken':
        return MedicineStatus.taken;
      case 'missed':
        return MedicineStatus.missed;
      case 'takenLate':
        return MedicineStatus.takenLate;
      default:
        return MedicineStatus.pending;
    }
  }
}

class Medicine {
  final String id;
  final String name;
  final String dose;
  final String time;
  final List<String> repeatDays;
  final MedicineStatus status;
  final MedicineType type;
  final String? notes;
  final int colorIndex;
  final bool isActive;
  final DateTime createdAt;

  const Medicine({
    required this.id,
    required this.name,
    required this.dose,
    required this.time,
    required this.repeatDays,
    this.status = MedicineStatus.pending,
    this.type = MedicineType.tablet,
    this.notes,
    this.colorIndex = 0,
    this.isActive = true,
    required this.createdAt,
  });

  bool get isPending => status == MedicineStatus.pending;
  bool get isTaken => status == MedicineStatus.taken;
  bool get isMissed => status == MedicineStatus.missed;
  bool get isTakenLate => status == MedicineStatus.takenLate;
  bool get isDone => isTaken || isTakenLate;

  String get repeatSummary {
    if (repeatDays.isEmpty) return 'No repeat';
    if (repeatDays.length == 7) return 'Every day';
    if (repeatDays.length == 5 &&
        !repeatDays.contains('Sat') &&
        !repeatDays.contains('Sun')) {
      return 'Weekdays';
    }
    if (repeatDays.length == 2 &&
        repeatDays.contains('Sat') &&
        repeatDays.contains('Sun')) {
      return 'Weekends';
    }
    return repeatDays.join(', ');
  }

  Medicine copyWith({
    String? name,
    String? dose,
    String? time,
    List<String>? repeatDays,
    MedicineStatus? status,
    MedicineType? type,
    String? notes,
    int? colorIndex,
    bool? isActive,
  }) {
    return Medicine(
      id: id,
      name: name ?? this.name,
      dose: dose ?? this.dose,
      time: time ?? this.time,
      repeatDays: repeatDays ?? this.repeatDays,
      status: status ?? this.status,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      colorIndex: colorIndex ?? this.colorIndex,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dose': dose,
        'time': time,
        'repeatDays': repeatDays,
        'status': status.name,
        'type': type.index,
        'notes': notes,
        'colorIndex': colorIndex,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
        id: json['id'] as String,
        name: json['name'] as String,
        dose: json['dose'] as String? ?? '',
        time: json['time'] as String? ?? '08:00 AM',
        repeatDays: List<String>.from(json['repeatDays'] as List? ?? []),
        status: MedicineStatusExt.fromString(json['status'] as String? ?? 'pending'),
        type: MedicineType.values[json['type'] as int? ?? 0],
        notes: json['notes'] as String?,
        colorIndex: json['colorIndex'] as int? ?? 0,
        isActive: json['isActive'] as bool? ?? true,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
      );

  static String generateId() =>
      'med_${DateTime.now().millisecondsSinceEpoch}';
}
