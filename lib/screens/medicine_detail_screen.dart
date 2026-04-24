import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../backend/models/medicine.dart';
import '../app_state.dart';
import '../theme/app_theme.dart';

class MedicineDetailScreen extends StatelessWidget {
  static const String routeName = '/medicine_detail';

  const MedicineDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final medicine = ModalRoute.of(context)!.settings.arguments as Medicine?;
    if (medicine == null) {
      return const Scaffold(
        body: Center(child: Text('No medicine selected')),
      );
    }
    return _MedicineDetailView(medicine: medicine);
  }
}

class _MedicineDetailView extends StatelessWidget {
  final Medicine medicine;

  const _MedicineDetailView({required this.medicine});

  static const List<Color> _cardColors = [
    Color(0xFFEEF0FF),
    Color(0xFFE8FFF8),
    Color(0xFFFFF0F5),
    Color(0xFFFFF8E8),
    Color(0xFFF0F8FF),
  ];

  static const List<Color> _accentColors = [
    AppColors.primary,
    AppColors.success,
    AppColors.secondary,
    AppColors.warning,
    Color(0xFF4FACFE),
  ];

  Color get _accent =>
      _accentColors[medicine.colorIndex % _accentColors.length];
  Color get _bg => _cardColors[medicine.colorIndex % _cardColors.length];

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: _accent,
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
            actions: [
              GestureDetector(
                onTap: () => _showDeleteDialog(context, state),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(38),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: Colors.white, size: 20),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_accent, _accent.withAlpha(204)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48),
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(38),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                            color: Colors.white.withAlpha(77), width: 2),
                      ),
                      child: Center(
                        child: Text(
                          medicine.type.icon,
                          style: const TextStyle(fontSize: 44),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      medicine.name,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (medicine.dose.isNotEmpty)
                      Text(
                        medicine.dose,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withAlpha(204),
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StatusBanner(medicine: medicine),
                  const SizedBox(height: 20),
                  _InfoGrid(medicine: medicine),
                  if (medicine.notes != null &&
                      medicine.notes!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _NotesCard(notes: medicine.notes!),
                  ],
                  const SizedBox(height: 20),
                  if (medicine.isPending) ...[
                    _ActionButtons(
                      onTaken: () => _updateStatus(
                          context, state, MedicineStatus.taken),
                      onMissed: () => _updateStatus(
                          context, state, MedicineStatus.missed),
                      onLate: () => _updateStatus(
                          context, state, MedicineStatus.takenLate),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateStatus(
      BuildContext context, AppState state, MedicineStatus status) async {
    await state.updateMedicineStatus(medicine.id, status);
    if (context.mounted) Navigator.of(context).pop();
  }

  void _showDeleteDialog(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Medicine',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Remove "${medicine.name}" permanently?',
          style: GoogleFonts.poppins(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              await state.deleteMedicine(medicine.id);
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: Text('Delete',
                style: GoogleFonts.poppins(
                    color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final Medicine medicine;

  const _StatusBanner({required this.medicine});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;
    String label;

    switch (medicine.status) {
      case MedicineStatus.taken:
        bg = AppColors.success.withAlpha(26);
        fg = AppColors.success;
        icon = Icons.check_circle_rounded;
        label = 'Taken on time — Great job! 🎉';
        break;
      case MedicineStatus.missed:
        bg = AppColors.error.withAlpha(26);
        fg = AppColors.error;
        icon = Icons.cancel_rounded;
        label = 'This dose was missed';
        break;
      case MedicineStatus.takenLate:
        bg = AppColors.warning.withAlpha(38);
        fg = AppColors.warningDark;
        icon = Icons.watch_later_rounded;
        label = 'Taken late — try to be on time next time';
        break;
      case MedicineStatus.pending:
        bg = AppColors.primary.withAlpha(20);
        fg = AppColors.primary;
        icon = Icons.access_time_rounded;
        label = 'Scheduled for ${medicine.time}';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                  color: fg, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final Medicine medicine;

  const _InfoGrid({required this.medicine});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _InfoTile(
          icon: Icons.access_time_rounded,
          label: 'Time',
          value: medicine.time,
          color: AppColors.primary,
        ),
        _InfoTile(
          icon: Icons.medication_rounded,
          label: 'Type',
          value: medicine.type.label,
          color: AppColors.success,
        ),
        _InfoTile(
          icon: Icons.repeat_rounded,
          label: 'Schedule',
          value: medicine.repeatSummary,
          color: AppColors.secondary,
        ),
        _InfoTile(
          icon: Icons.medical_services_outlined,
          label: 'Dose',
          value: medicine.dose.isNotEmpty ? medicine.dose : 'Not set',
          color: AppColors.warning,
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: AppColors.textLight,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  final String notes;

  const _NotesCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notes_rounded,
                  color: AppColors.textSecondary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Notes',
                style: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            notes,
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onTaken;
  final VoidCallback onMissed;
  final VoidCallback onLate;

  const _ActionButtons({
    required this.onTaken,
    required this.onMissed,
    required this.onLate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Mark as',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTaken,
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              gradient: AppColors.tealGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withAlpha(77),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Taken on Time',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onLate,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withAlpha(38),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.warning.withAlpha(102)),
                  ),
                  child: Center(
                    child: Text(
                      'Taken Late',
                      style: GoogleFonts.poppins(
                        color: AppColors.warningDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: onMissed,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(20),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.error.withAlpha(77)),
                  ),
                  child: Center(
                    child: Text(
                      'Missed',
                      style: GoogleFonts.poppins(
                        color: AppColors.error,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
