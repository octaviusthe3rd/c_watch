import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_providers.dart';
import '../../providers/report_providers.dart';
import '../../providers/ui_providers.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/report_card.dart';
import '../reports/report_form_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openForm(BuildContext context) => Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ReportFormScreen()));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(appUserProvider).valueOrNull;
    final stats = ref.watch(myStatsProvider);
    final mineAsync = ref.watch(myReportsProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 24), children: [
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Hello, ${user?.name.split(' ').first ?? 'there'} 👋',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark)),
                const SizedBox(height: 4),
                const Text('Help make our campus safer.',
                    style:
                        TextStyle(color: AppColors.textMuted, fontSize: 14)),
              ]),
            ),
            AppAvatar(name: user?.name ?? '?'),
          ]),
          const SizedBox(height: 20),
          _HeroCard(onReport: () => _openForm(context)),
          const SizedBox(height: 20),
          SectionHeader(
              title: 'Report Summary',
              actionLabel: 'See all',
              onAction: () => ref.read(shellIndexProvider.notifier).state = 2),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: StatCard(value: stats.total, label: 'My Reports', icon: Icons.description_rounded, color: AppColors.primary, background: AppColors.inProgressBg)),
            const SizedBox(width: 8),
            Expanded(child: StatCard(value: stats.inProgress, label: 'In Progress', icon: Icons.schedule_rounded, color: AppColors.info, background: AppColors.infoBg)),
            const SizedBox(width: 8),
            Expanded(child: StatCard(value: stats.resolved, label: 'Resolved', icon: Icons.check_circle_rounded, color: AppColors.resolved, background: AppColors.resolvedBg)),
            const SizedBox(width: 8),
            Expanded(child: StatCard(value: stats.submitted, label: 'Submitted', icon: Icons.priority_high_rounded, color: AppColors.submitted, background: AppColors.submittedBg)),
          ]),
          const SizedBox(height: 20),
          SectionHeader(
              title: 'Recent Reports',
              actionLabel: 'See all',
              onAction: () => ref.read(shellIndexProvider.notifier).state = 2),
          const SizedBox(height: 8),
          mineAsync.when(
            loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary))),
            error: (e, _) => Text('Could not load reports: $e'),
            data: (reports) => reports.isEmpty
                ? EmptyState(
                    icon: Icons.inbox_rounded,
                    title: 'No reports yet',
                    message:
                        'Spotted an issue on campus? You can report it in under a minute.',
                    actionLabel: 'Report an Issue',
                    onAction: () => _openForm(context))
                : Column(children: [
                    for (final r in reports.take(4))
                      Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ReportCard(report: r)),
                  ]),
          ),
          if (user?.isStaff ?? false) ...[
            const SizedBox(height: 8),
            Material(
              color: AppColors.inProgressBg,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => ref.read(shellIndexProvider.notifier).state = 1,
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Row(children: [
                    Icon(Icons.admin_panel_settings_rounded,
                        color: AppColors.primary),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                          'Staff mode — open Campus Reports to review and update statuses.',
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary)),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.primary),
                  ]),
                ),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onReport});
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(children: [
        Positioned(
          right: -12,
          top: -12,
          child: Icon(Icons.school_rounded,
              size: 120, color: Colors.white.withValues(alpha: 0.15)),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('See an issue\non campus?',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.2)),
          const SizedBox(height: 8),
          Text('Report it and help improve\nour learning environment.',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13.5,
                  height: 1.4)),
          const SizedBox(height: 16),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onReport,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                        color: AppColors.primary, shape: BoxShape.circle),
                    child:
                        const Icon(Icons.add, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text('Report an Issue',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5)),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: AppColors.primary),
                ]),
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}