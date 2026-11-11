import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils.dart';
import '../../models/app_user.dart';
import '../../models/enums.dart';
import '../../models/incident_report.dart';
import '../../providers/auth_providers.dart';
import '../../providers/report_providers.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/status_timeline.dart';

class ReportDetailsScreen extends ConsumerWidget {
  const ReportDetailsScreen({super.key, required this.reportId});
  final String reportId;

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, IncidentReport report) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete report?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFDC2626)),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    try {
      await ref.read(reportServiceProvider).delete(report.id);
      if (report.photoUrl != null) {
        await ref.read(storageServiceProvider).deletePhotoByUrl(report.photoUrl!);
      }
      if (!context.mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(const SnackBar(content: Text('Report deleted')));
    } catch (e) {
      if (context.mounted) context.showSnack('Could not delete: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(allReportsProvider);
    final user = ref.watch(appUserProvider).valueOrNull;

    // Look up by id from the live stream so status updates appear instantly.
    IncidentReport? report;
    final list = async.valueOrNull;
    if (list != null) {
      for (final r in list) {
        if (r.id == reportId) { report = r; break; }
      }
    }

    if (report == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Incident Details')),
        body: async.hasError
            ? const Center(child: Text('Could not load this report.'))
            : async.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : const EmptyState(
                    icon: Icons.delete_outline_rounded,
                    title: 'Report not found',
                    message: 'It may have been deleted.'),
      );
    }

    final r = report;
    final canDelete = user != null &&
        (user.isStaff ||
            (r.reporterId == user.uid && r.status == ReportStatus.submitted));
    final note = r.latestNote;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Details'),
        actions: [
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => _confirmDelete(context, ref, r),
            ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
        if (r.photoUrl != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(r.photoUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink()),
          ),
          const SizedBox(height: 16),
        ],
        Text(r.title,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _InfoChip(icon: r.category.icon, label: r.category.label),
          _InfoChip(icon: Icons.place_outlined, label: r.location),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          StatusBadge(r.status),
          const SizedBox(width: 10),
          Text('Updated ${timeAgo(r.updatedAt)}',
              style:
                  const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ]),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            AppAvatar(name: r.reporterName, radius: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.reporterName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                Text('Reported ${formatDateTime(r.createdAt)}',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 11.5)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Status Timeline'),
        const SizedBox(height: 12),
        StatusTimeline(report: r),
        if (note != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppColors.inProgressBg,
                borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Note from ${note.byName}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
              const SizedBox(height: 4),
              Text(note.note!,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textDark, height: 1.4)),
            ]),
          ),
        ],
        const SizedBox(height: 20),
        const SectionHeader(title: 'Description'),
        const SizedBox(height: 6),
        Text(r.description,
            style: const TextStyle(
                fontSize: 14, height: 1.5, color: AppColors.textDark)),
        const SizedBox(height: 24),
        if (user != null && user.isStaff) ...[
          ElevatedButton.icon(
            icon: const Icon(Icons.edit_calendar_outlined),
            label: const Text('Update Status'),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => _UpdateStatusSheet(report: r, staff: user),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (canDelete)
          Center(
            child: TextButton.icon(
              style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626)),
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text('Delete Report'),
              onPressed: () => _confirmDelete(context, ref, r),
            ),
          ),
      ]),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
        ]),
      );
}

class _UpdateStatusSheet extends ConsumerStatefulWidget {
  const _UpdateStatusSheet({required this.report, required this.staff});
  final IncidentReport report;
  final AppUser staff;

  @override
  ConsumerState<_UpdateStatusSheet> createState() => _UpdateStatusSheetState();
}

class _UpdateStatusSheetState extends ConsumerState<_UpdateStatusSheet> {
  late ReportStatus _selected = widget.report.status;
  final _noteCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selected == widget.report.status) {
      Navigator.pop(context);
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(reportServiceProvider).updateStatus(
            report: widget.report,
            status: _selected,
            staff: widget.staff,
            note: _noteCtrl.text,
          );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(SnackBar(
          content: Text('Status updated to "${_selected.label}"')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      context.showSnack('Could not update status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Update Status',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('Report: ${widget.report.title}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
        const SizedBox(height: 16),
        SegmentedButton<ReportStatus>(
          segments: [
            for (final s in ReportStatus.values)
              ButtonSegment(
                  value: s,
                  label: Text(s.label, style: const TextStyle(fontSize: 12))),
          ],
          selected: {_selected},
          showSelectedIcon: false,
          onSelectionChanged: (v) => setState(() => _selected = v.first),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _noteCtrl,
          maxLines: 2,
          maxLength: 200,
          decoration: const InputDecoration(
              labelText: 'Note for the reporter (optional)',
              hintText: 'e.g. Technician assigned, fix expected by Friday'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : const Text('Save Update'),
        ),
      ]),
    );
  }
}