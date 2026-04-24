import 'package:flutter/material.dart';
import 'backend/database/local_database.dart';
import 'backend/models/medicine.dart';
import 'backend/models/history_entry.dart';
import 'backend/models/user.dart';
import 'backend/services/auth_service.dart';
import 'backend/services/medicine_service.dart';
import 'backend/repositories/user_repository.dart';

class AppState extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final MedicineService _medicineService = MedicineService();
  final UserRepository _userRepo = UserRepository();

  List<Medicine> _medicines = [];
  List<HistoryEntry> _history = [];
  User _user = User.defaultUser;
  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _onboardingDone = false;
  String? _error;
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  String _reminderSound = 'Default';

  List<Medicine> get medicines => List.unmodifiable(_medicines);
  List<HistoryEntry> get history => List.unmodifiable(_history);
  User get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  bool get onboardingDone => _onboardingDone;
  String? get error => _error;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get darkMode => _darkMode;
  String get reminderSound => _reminderSound;

  int get takenCount =>
      _medicines.where((m) => m.isTaken || m.isTakenLate).length;
  int get totalCount => _medicines.length;
  double get progress => totalCount == 0 ? 0 : takenCount / totalCount;
  bool get hasMissedDose => _medicines.any((m) => m.isMissed);
  List<Medicine> get pendingMedicines =>
      _medicines.where((m) => m.isPending).toList();
  List<Medicine> get completedMedicines =>
      _medicines.where((m) => m.isDone).toList();

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    try {
      await LocalDatabase.instance.init();
      await _medicineService.init();
      _onboardingDone = await LocalDatabase.instance.isOnboardingDone();
      _isLoggedIn = await _authService.isLoggedIn();
      if (_isLoggedIn) await _loadData();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadData() async {
    _medicines = await _medicineService.getMedicines();
    _history = await _medicineService.getHistory();
    _user = await _userRepo.getUser();
    final settings = await LocalDatabase.instance.getSettings();
    _notificationsEnabled = settings['notifications'] as bool? ?? true;
    _darkMode = settings['darkMode'] as bool? ?? false;
    _reminderSound = settings['reminderSound'] as String? ?? 'Default';
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _authService.login(email, password);
      if (result.success) {
        _isLoggedIn = true;
        await _loadData();
        return true;
      }
      _error = result.error;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _authService.signup(name, email, password);
      if (result.success) {
        _isLoggedIn = true;
        await _loadData();
        return true;
      }
      _error = result.error;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    _medicines = [];
    _history = [];
    notifyListeners();
  }

  Future<bool> addMedicine({
    required String name,
    required String dose,
    required String time,
    required List<String> repeatDays,
    MedicineType type = MedicineType.tablet,
    String? notes,
    int colorIndex = 0,
  }) async {
    final result = await _medicineService.addMedicine(
      name: name,
      dose: dose,
      time: time,
      repeatDays: repeatDays,
      type: type,
      notes: notes,
      colorIndex: colorIndex,
    );
    if (result.success) {
      _medicines = await _medicineService.getMedicines();
      _error = null;
      notifyListeners();
      return true;
    }
    _error = result.error;
    notifyListeners();
    return false;
  }

  Future<void> updateMedicineStatus(String id, MedicineStatus status) async {
    await _medicineService.updateStatus(id, status);
    _medicines = await _medicineService.getMedicines();
    _history = await _medicineService.getHistory();
    _user = await _userRepo.getUser();
    notifyListeners();
  }

  Future<void> deleteMedicine(String id) async {
    await _medicineService.deleteMedicine(id);
    _medicines = await _medicineService.getMedicines();
    _history = await _medicineService.getHistory();
    notifyListeners();
  }

  Future<void> updateUser(User updated) async {
    _user = updated;
    await _userRepo.saveUser(updated);
    notifyListeners();
  }

  Future<void> setOnboardingDone() async {
    await LocalDatabase.instance.setOnboardingDone();
    _onboardingDone = true;
    notifyListeners();
  }

  Future<void> updateSettings({
    bool? notifications,
    bool? darkMode,
    String? reminderSound,
  }) async {
    if (notifications != null) _notificationsEnabled = notifications;
    if (darkMode != null) _darkMode = darkMode;
    if (reminderSound != null) _reminderSound = reminderSound;
    await LocalDatabase.instance.saveSettings({
      'notifications': _notificationsEnabled,
      'darkMode': _darkMode,
      'reminderSound': _reminderSound,
    });
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    _medicines = await _medicineService.getMedicines();
    _history = await _medicineService.getHistory();
    _user = await _userRepo.getUser();
    notifyListeners();
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState appState,
    required super.child,
  }) : super(notifier: appState);

  static AppState of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'No AppStateScope found in widget tree');
    return scope!.notifier!;
  }
}
