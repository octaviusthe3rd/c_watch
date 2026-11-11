import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/enums.dart';
import '../models/incident_report.dart';
import '../services/report_service.dart';
import '../services/storage_service.dart';
import 'auth_providers.dart';

final reportServiceProvider =
    Provider((ref) => ReportService(FirebaseFirestore.instance));
final storageServiceProvider =
    Provider((ref) => StorageService(FirebaseStorage.instance));

final allReportsProvider = StreamProvider<List<IncidentReport>>(
    (ref) => ref.watch(reportServiceProvider).watchAll());

final myReportsProvider = StreamProvider<List<IncidentReport>>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(reportServiceProvider).watchMine(uid);
});

// ---------- Derived stats ----------
class ReportStats {
  const ReportStats(
      {this.total = 0, this.submitted = 0, this.inProgress = 0, this.resolved = 0});
  final int total, submitted, inProgress, resolved;

  factory ReportStats.from(List<IncidentReport> reports) => ReportStats(
        total: reports.length,
        submitted:
            reports.where((r) => r.status == ReportStatus.submitted).length,
        inProgress:
            reports.where((r) => r.status == ReportStatus.inProgress).length,
        resolved: reports.where((r) => r.status == ReportStatus.resolved).length,
      );
}

final myStatsProvider = Provider<ReportStats>((ref) =>
    ReportStats.from(ref.watch(myReportsProvider).valueOrNull ?? const []));

// ---------- Search & filters ----------
class ReportFilter {
  const ReportFilter({this.query = '', this.status, this.category});
  final String query;
  final ReportStatus? status;
  final ReportCategory? category;

  ReportFilter copyWith({
    String? query,
    ReportStatus? status,
    ReportCategory? category,
    bool clearStatus = false,
    bool clearCategory = false,
  }) =>
      ReportFilter(
        query: query ?? this.query,
        status: clearStatus ? null : (status ?? this.status),
        category: clearCategory ? null : (category ?? this.category),
      );
}

class ReportFilterNotifier extends Notifier<ReportFilter> {
  @override
  ReportFilter build() => const ReportFilter();

  void setQuery(String q) => state = state.copyWith(query: q);
  void setStatus(ReportStatus? s) =>
      state = state.copyWith(status: s, clearStatus: s == null);
  void setCategory(ReportCategory? c) =>
      state = state.copyWith(category: c, clearCategory: c == null);
  void reset() => state = const ReportFilter();
}

final reportFilterProvider =
    NotifierProvider<ReportFilterNotifier, ReportFilter>(
        ReportFilterNotifier.new);

final filteredAllReportsProvider = Provider<List<IncidentReport>>((ref) {
  final reports = ref.watch(allReportsProvider).valueOrNull ?? const [];
  final f = ref.watch(reportFilterProvider);
  final q = f.query.trim().toLowerCase();
  return reports.where((r) {
    if (f.status != null && r.status != f.status) return false;
    if (f.category != null && r.category != f.category) return false;
    if (q.isEmpty) return true;
    return r.title.toLowerCase().contains(q) ||
        r.description.toLowerCase().contains(q) ||
        r.location.toLowerCase().contains(q) ||
        r.reporterName.toLowerCase().contains(q);
  }).toList();
});

// ---------- Submission ---------------
class ReportSubmissionController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> submit({
    required String title,
    required String description,
    required ReportCategory category,
    required String location,
    XFile? photo,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final reporter = ref.read(appUserProvider).valueOrNull;
      if (reporter == null) {
        throw Exception('You must be signed in to submit a report.');
      }
      String? photoUrl;
      if (photo != null) {
        photoUrl = await ref
            .read(storageServiceProvider)
            .uploadReportPhoto(uid: reporter.uid, photo: photo);
      }
      await ref.read(reportServiceProvider).create(
            reporter: reporter,
            title: title,
            description: description,
            category: category,
            location: location,
            photoUrl: photoUrl,
          );
    });
    state = result;
    return !result.hasError;
  }
}

final reportSubmissionProvider =
    AutoDisposeAsyncNotifierProvider<ReportSubmissionController, void>(
        ReportSubmissionController.new);