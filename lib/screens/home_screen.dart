import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_state.dart';
import '../backend/models/medicine.dart';
import '../theme/app_theme.dart';
import 'add_medicine_screen.dart';
import 'history_screen.dart';
import 'statistics_screen.dart';
import 'profile_screen.dart';
import 'medicine_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  static const _navScreens = [
    _HomeContent(),
    HistoryScreen(embedded: true),
    StatisticsScreen(embedded: true),
    ProfileScreen(embedded: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _navIndex, children: _navScreens),
      floatingActionButton: _navIndex == 0 ? _Fab() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}

class _Fab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(AddMedicineScreen.routeName),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: AppShadows.button,
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_rounded, 'Home'),
      (Icons.history_rounded, 'History'),
      (Icons.bar_chart_rounded, 'Stats'),
      (Icons.person_rounded, 'Profile'),
    ];

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final selected = i == currentIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withAlpha(20)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    items[i].$1,
                    color: selected ? AppColors.primary : AppColors.textLight,
                    size: 24,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.poppins(
                      color:
                          selected ? AppColors.primary : AppColors.textLight,
                      fontSize: 11,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _listCtrl;

  @override
  void initState() {
    super.initState();
    _listCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _listCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(state)),
        SliverToBoxAdapter(child: _buildProgressCard(state)),
        if (state.hasMissedDose)
          SliverToBoxAdapter(child: _buildMissedAlert()),
        SliverToBoxAdapter(child: _buildSectionTitle('Today\'s Medicines')),
        if (state.medicines.isEmpty)
          SliverToBoxAdapter(child: _buildEmpty())
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final med = state.medicines[i];
                final delay = i * 0.08;
                return AnimatedBuilder(
                  animation: _listCtrl,
                  builder: (_, __) {
                    final t = (_listCtrl.value - delay).clamp(0.0, 1.0);
                    return Opacity(
                      opacity: t,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - t)),
                        child: _MedicineCard(
                          medicine: med,
                          onStatusChange: (status) {
                            state.updateMedicineStatus(med.id, status);
                          },
                          onDelete: () => _confirmDelete(context, state, med),
                          onTap: () => Navigator.of(context).pushNamed(
                            MedicineDetailScreen.routeName,
                            arguments: med,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              childCount: state.medicines.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildHeader(AppState state) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting 👋',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withAlpha(204),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.user.name,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withAlpha(102), width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      state.user.initials,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(AppState state) {
    return Container(
      color: Colors.transparent,
      child: Stack(
        children: [
          Container(
            height: 48,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppShadows.card,
              ),
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today\'s Progress',
                          style: GoogleFonts.poppins(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${state.takenCount}',
                                style: GoogleFonts.poppins(
                                  color: AppColors.primary,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(
                                text: '/${state.totalCount}',
                                style: GoogleFonts.poppins(
                                  color: AppColors.textLight,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text: '  taken',
                                style: GoogleFonts.poppins(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: state.progress,
                            minHeight: 8,
                            backgroundColor:
                                AppColors.primary.withAlpha(26),
                            valueColor: const AlwaysStoppedAnimation(
                                AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  _ProgressRing(progress: state.progress),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissedAlert() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: AppColors.pinkGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withAlpha(51),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'You have missed doses. Please mark them or consult your doctor.',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w700,
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
                child: Text('💊', style: TextStyle(fontSize: 44))),
          ),
          const SizedBox(height: 20),
          Text(
            'No medicines yet',
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first medicine',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, AppState state, Medicine medicine) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _DeleteSheet(
        medicineName: medicine.name,
        onConfirm: () => state.deleteMedicine(medicine.id),
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final double progress;

  const _ProgressRing({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 7,
            backgroundColor: AppColors.primary.withAlpha(26),
            valueColor:
                const AlwaysStoppedAnimation(AppColors.primary),
            strokeCap: StrokeCap.round,
          ),
          Center(
            child: Text(
              '${(progress * 100).round()}%',
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final ValueChanged<MedicineStatus> onStatusChange;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _MedicineCard({
    required this.medicine,
    required this.onStatusChange,
    required this.onDelete,
    required this.onTap,
  });

  static const List<Color> _cardColors = [
    Color(0xFFEEF0FF),
    Color(0xFFE8FFF8),
    Color(0xFFFFF0F5),
    Color(0xFFFFF8E8),
    Color(0xFFF0F8FF),
  ];

  static const List<Color> _iconColors = [
    AppColors.primary,
    AppColors.success,
    AppColors.secondary,
    AppColors.warning,
    Color(0xFF4FACFE),
  ];

  Color get _bg =>
      _cardColors[medicine.colorIndex % _cardColors.length];
  Color get _accent =>
      _iconColors[medicine.colorIndex % _iconColors.length];

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(medicine.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(26),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline,
            color: AppColors.error, size: 26),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppShadows.soft,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      medicine.type.icon,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicine.name,
                        style: GoogleFonts.poppins(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        medicine.dose.isNotEmpty
                            ? '${medicine.dose} · ${medicine.time}'
                            : medicine.time,
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.repeat,
                              size: 12, color: AppColors.textLight),
                          const SizedBox(width: 4),
                          Text(
                            medicine.repeatSummary,
                            style: GoogleFonts.poppins(
                              color: AppColors.textLight,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _StatusChip(
                  medicine: medicine,
                  onStatusChange: onStatusChange,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final Medicine medicine;
  final ValueChanged<MedicineStatus> onStatusChange;

  const _StatusChip(
      {required this.medicine, required this.onStatusChange});

  Color get _bg {
    switch (medicine.status) {
      case MedicineStatus.taken:
        return AppColors.success.withAlpha(26);
      case MedicineStatus.missed:
        return AppColors.error.withAlpha(26);
      case MedicineStatus.takenLate:
        return AppColors.warning.withAlpha(38);
      case MedicineStatus.pending:
        return AppColors.primary.withAlpha(20);
    }
  }

  Color get _fg {
    switch (medicine.status) {
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

  IconData get _icon {
    switch (medicine.status) {
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
    if (medicine.isPending) {
      return GestureDetector(
        onTap: () => _showStatusSheet(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(51),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            'Take',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, color: _fg, size: 14),
          const SizedBox(width: 4),
          Text(
            medicine.status.label,
            style: GoogleFonts.poppins(
              color: _fg,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _StatusSheet(onSelect: onStatusChange),
    );
  }
}

class _StatusSheet extends StatelessWidget {
  final ValueChanged<MedicineStatus> onSelect;

  const _StatusSheet({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Mark as',
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          _sheetOption(
            context,
            icon: Icons.check_circle_rounded,
            label: 'Taken on Time',
            color: AppColors.success,
            status: MedicineStatus.taken,
          ),
          const SizedBox(height: 12),
          _sheetOption(
            context,
            icon: Icons.watch_later_rounded,
            label: 'Taken Late',
            color: AppColors.warning,
            status: MedicineStatus.takenLate,
          ),
          const SizedBox(height: 12),
          _sheetOption(
            context,
            icon: Icons.cancel_rounded,
            label: 'Missed',
            color: AppColors.error,
            status: MedicineStatus.missed,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _sheetOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required MedicineStatus status,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onSelect(status);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(51)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteSheet extends StatelessWidget {
  final String medicineName;
  final VoidCallback onConfirm;

  const _DeleteSheet(
      {required this.medicineName, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.error.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.delete_outline,
                color: AppColors.error, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            'Delete Medicine',
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Remove "$medicineName" from your list?',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    onConfirm();
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        'Delete',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
