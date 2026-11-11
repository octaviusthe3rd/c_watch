import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../models/enums.dart';
import '../models/incident_report.dart';

class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.report});
  final IncidentReport report;

  @override
  Widget build(BuildContext context) {
    final current = report.status.index;
    final statuses = ReportStatus.values;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < statuses.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(top: 14),
                color: i <= current ? AppColors.primary : AppColors.border,
              ),
            ),
          SizedBox(
            width: 92,
            child: Column(children: [
              _circle(i, current),
              const SizedBox(height: 6),
              Text(statuses[i].label,
                  style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: i <= current
                          ? AppColors.textDark
                          : AppColors.textMuted)),
              const SizedBox(height: 2),
              Text(
                report.eventFor(statuses[i]) != null
                    ? DateFormat('MMM d, h:mm a')
                        .format(report.eventFor(statuses[i])!.at)
                    : '—',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 9.5, color: AppColors.textMuted),
              ),
            ]),
          ),
        ],
      ],
    );
  }

  Widget _circle(int i, int current) {
    if (i < current) {
      return Container(
        width: 30,
        height: 30,
        decoration:
            const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        child: const Icon(Icons.check, size: 16, color: Colors.white),
      );
    }
    if (i == current) {
      return Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryLight, width: 3)),
        child: Icon(
            report.status == ReportStatus.resolved
                ? Icons.check
                : Icons.autorenew,
            size: 14,
            color: Colors.white),
      );
    }
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFD1D5DB), width: 2)),
      child: const Icon(Icons.add, size: 14, color: Color(0xFF9CA3AF)),
    );
  }
}