import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/enums.dart';
import '../../providers/auth_providers.dart';
import '../../providers/report_providers.dart';
import '../../providers/ui_providers.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/report_card.dart';
import '../reports/report_form_screen.dart';

class MyReportsScreen extends ConsumerStatefulWidget {
  const MyReportsScreen({super.key});

  @override
  ConsumerState<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends ConsumerState<MyReportsScreen> {
  ReportStatus? _filter;

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sign out')),
        ],
      ),
    );
    if (confirm != true) return;
    ref.read(shellIndexProvider.notifier).state = 0;
    ref.read(reportFilterProvider.notifier).reset();
    await ref.read(authServiceProvider).signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(appUserProvider).valueOrNull;
    final stats = ref.watch(myStatsProvider);
    final mineAsync = ref.watch(myReportsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout_rounded), onPressed: _signOut),
        ],
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Row(children: [
            AppAvatar(name: user?.name ?? '?', radius: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(
                    child: Text(user?.name ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: AppColors.inProgressBg,
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(user?.role.label ?? '',
                        style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                  ),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.school_outlined,
                      size: 13, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(user?.department ?? '',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted)),
                ]),
                const SizedBox(height: 2),
                Row(children: [
                  const Icon(Icons.mail_outline_rounded,
                      size: 13, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(user?.email ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                  ),
                ]),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: StatCard(value: stats.total, label: 'Total Reports', icon: Icons.description_rounded, color: AppColors.primary, background: AppColors.inProgressBg)),
          const SizedBox(width: 8),
          Expanded(child: StatCard(value: stats.inProgress, label: 'In Progress', icon: Icons.schedule_rounded, color: AppColors.info, background: AppColors.infoBg)),
          const SizedBox(width: 8),
          Expanded(child: StatCard(value: stats.resolved, label: 'Resolved', icon: Icons.check_circle_rounded, color: AppColors.resolved, background: AppColors.resolvedBg)),
        ]),
        const SizedBox(height: 16),
        StatusFilterChips(
            selected: _filter, onChanged: (s) => setState(() => _filter = s)),
        const SizedBox(height: 16),
        mineAsync.when(
          loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary))),
          error: (e, _) => Text('Could not load your reports: $e'),
          data: (reports) {
            final filtered = _filter == null
                ? reports
                : reports.where((r) => r.status == _filter).toList();
            if (filtered.isEmpty) {
              return EmptyState(
                icon: Icons.inbox_rounded,
                title: 'Nothing here yet',
                message: _filter == null
                    ? 'You have not submitted any reports.'
                    : 'No reports with this status.',
                actionLabel: 'Report an Issue',
                onAction: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const ReportFormScreen())),
              );
            }
            return Column(children: [
              for (final r in filtered)
                Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ReportCard(report: r)),
            ]);
          },
        ),
      ]),
    );
  }
}