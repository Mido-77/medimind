import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_state.dart';
import '../backend/models/medicine.dart';
import '../theme/app_theme.dart';

class AddMedicineScreen extends StatefulWidget {
  static const String routeName = '/add_medicine';

  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _doseCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  TimeOfDay _time = TimeOfDay.now();
  MedicineType _type = MedicineType.tablet;
  int _colorIndex = 0;
  final Set<String> _selectedDays = {'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'};
  bool _loading = false;
  String? _error;

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static const List<Color> _colors = [
    AppColors.primary,
    AppColors.success,
    AppColors.secondary,
    AppColors.warning,
    Color(0xFF4FACFE),
  ];

  static const List<MedicineType> _types = [
    MedicineType.tablet,
    MedicineType.capsule,
    MedicineType.liquid,
    MedicineType.injection,
    MedicineType.inhaler,
    MedicineType.drops,
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _doseCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final h = _time.hourOfPeriod == 0 ? 12 : _time.hourOfPeriod;
    final m = _time.minute.toString().padLeft(2, '0');
    final period = _time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDays.isEmpty) {
      setState(() => _error = 'Select at least one repeat day');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final state = AppStateScope.of(context);
    final ok = await state.addMedicine(
      name: _nameCtrl.text,
      dose: _doseCtrl.text,
      time: _formattedTime,
      repeatDays: _selectedDays.toList(),
      type: _type,
      notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
      colorIndex: _colorIndex,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      Navigator.of(context).pop();
    } else {
      setState(() => _error = state.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(38),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
            title: Text(
              'Add Medicine',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: _loading ? null : _save,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            'Save',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
              ),
            ],
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Section(
                      title: 'Medicine Details',
                      child: Column(
                        children: [
                          _field(
                            controller: _nameCtrl,
                            label: 'Medicine Name',
                            hint: 'e.g. Lisinopril',
                            icon: Icons.medication_rounded,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Medicine name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _field(
                            controller: _doseCtrl,
                            label: 'Dosage (optional)',
                            hint: 'e.g. 10 mg',
                            icon: Icons.science_outlined,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _Section(
                      title: 'Medicine Type',
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _types.map((t) {
                          final selected = _type == t;
                          return GestureDetector(
                            onTap: () => setState(() => _type = t),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.divider,
                                ),
                                boxShadow: selected
                                    ? AppShadows.soft
                                    : [],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(t.icon,
                                      style:
                                          const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 6),
                                  Text(
                                    t.label,
                                    style: GoogleFonts.poppins(
                                      color: selected
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _Section(
                      title: 'Reminder Time',
                      child: GestureDetector(
                        onTap: _pickTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.primary.withAlpha(51)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time_rounded,
                                  color: AppColors.primary),
                              const SizedBox(width: 14),
                              Text(
                                _formattedTime,
                                style: GoogleFonts.poppins(
                                  color: AppColors.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              Icon(Icons.edit_rounded,
                                  color: AppColors.primary.withAlpha(153),
                                  size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _Section(
                      title: 'Repeat Days',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _days.map((day) {
                              final sel = _selectedDays.contains(day);
                              return GestureDetector(
                                onTap: () => setState(() {
                                  if (sel) {
                                    _selectedDays.remove(day);
                                  } else {
                                    _selectedDays.add(day);
                                  }
                                }),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: sel
                                        ? AppColors.primaryGradient
                                        : null,
                                    color: sel
                                        ? null
                                        : Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: sel
                                          ? Colors.transparent
                                          : AppColors.divider,
                                    ),
                                    boxShadow:
                                        sel ? AppShadows.soft : [],
                                  ),
                                  child: Center(
                                    child: Text(
                                      day.substring(0, 1),
                                      style: GoogleFonts.poppins(
                                        color: sel
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _quickSelect('Every Day', () => setState(() {
                                _selectedDays.addAll(_days);
                              })),
                              const SizedBox(width: 8),
                              _quickSelect('Weekdays', () => setState(() {
                                _selectedDays
                                  ..clear()
                                  ..addAll(
                                      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']);
                              })),
                              const SizedBox(width: 8),
                              _quickSelect('Weekends', () => setState(() {
                                _selectedDays
                                  ..clear()
                                  ..addAll(['Sat', 'Sun']);
                              })),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _Section(
                      title: 'Color Label',
                      child: Row(
                        children: List.generate(_colors.length, (i) {
                          final sel = _colorIndex == i;
                          return GestureDetector(
                            onTap: () => setState(() => _colorIndex = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 12),
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: _colors[i],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: sel
                                      ? AppColors.textPrimary
                                      : Colors.transparent,
                                  width: 2.5,
                                ),
                                boxShadow: sel
                                    ? [
                                        BoxShadow(
                                          color: _colors[i].withAlpha(102),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: sel
                                  ? const Icon(Icons.check,
                                      color: Colors.white, size: 18)
                                  : null,
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _Section(
                      title: 'Notes (optional)',
                      child: TextFormField(
                        controller: _notesCtrl,
                        maxLines: 3,
                        style: GoogleFonts.poppins(
                            color: AppColors.textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          hintText:
                              'Any special instructions...',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 32),
                            child: Icon(Icons.notes_rounded,
                                color: AppColors.textLight, size: 20),
                          ),
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.error.withAlpha(26),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _error!,
                          style: GoogleFonts.poppins(
                              color: AppColors.error, fontSize: 13),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: _loading ? null : _save,
                      child: Container(
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppShadows.button,
                        ),
                        child: Center(
                          child: _loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5)
                              : Text(
                                  'Add Medicine',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickSelect(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withAlpha(51)),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: AppColors.primary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style:
          GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon:
            Icon(icon, color: AppColors.textLight, size: 20),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
