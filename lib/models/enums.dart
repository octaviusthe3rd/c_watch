import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

enum UserRole {
  student('Student'),
  staff('Staff');

  const UserRole(this.label);
  final String label;

  static UserRole fromName(String? n) => UserRole.values
      .firstWhere((r) => r.name == n, orElse: () => UserRole.student);
}

enum ReportCategory {
  facilities('Facilities', Icons.apartment_rounded),
  water('Water', Icons.water_drop_outlined),
  electricity('Electricity', Icons.bolt_rounded),
  safety('Safety', Icons.shield_outlined),
  sanitation('Sanitation', Icons.delete_outline_rounded),
  furniture('Furniture', Icons.chair_outlined);

  const ReportCategory(this.label, this.icon);
  final String label;
  final IconData icon;

  static ReportCategory fromName(String? n) => ReportCategory.values
      .firstWhere((c) => c.name == n, orElse: () => ReportCategory.facilities);
}

enum ReportStatus {
  submitted('Submitted', AppColors.submitted, AppColors.submittedBg),
  inProgress('In Progress', AppColors.inProgress, AppColors.inProgressBg),
  resolved('Resolved', AppColors.resolved, AppColors.resolvedBg);

  const ReportStatus(this.label, this.color, this.background);
  final String label;
  final Color color;
  final Color background;

  static ReportStatus fromName(String? n) => ReportStatus.values
      .firstWhere((s) => s.name == n, orElse: () => ReportStatus.submitted);
}