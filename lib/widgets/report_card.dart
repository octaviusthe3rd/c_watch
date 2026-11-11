import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils.dart';
import '../models/incident_report.dart';
import '../screens/reports/report_details_screen.dart';
import 'common_widgets.dart';

class ReportCard extends StatelessWidget {
  const ReportCard({super.key, required this.report});
  final IncidentReport report;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ReportDetailsScreen(reportId: report.id))),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            _Thumb(report: report),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(report.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                            color: AppColors.textDark)),
                    const SizedBox(height: 3),
                    Text(report.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 12.5)),
                    const SizedBox(height: 5),
                    Row(children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(timeAgo(report.createdAt),
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 11.5)),
                    ]),
                  ]),
            ),
            const SizedBox(width: 8),
            Column(children: [
              StatusBadge(report.status),
              const SizedBox(height: 6),
              const Icon(Icons.chevron_right,
                  color: AppColors.textMuted, size: 20),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.report});
  final IncidentReport report;

  Widget _fallback() => Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
            color: AppColors.inProgressBg,
            borderRadius: BorderRadius.circular(12)),
        child: Icon(report.category.icon, color: AppColors.primary, size: 24),
      );

  @override
  Widget build(BuildContext context) {
    if (report.photoUrl == null) return _fallback();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(report.photoUrl!,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback()),
    );
  }
}