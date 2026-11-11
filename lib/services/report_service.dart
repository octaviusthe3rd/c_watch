import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../models/enums.dart';
import '../models/incident_report.dart';

class ReportService {
  ReportService(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('reports');

  Stream<List<IncidentReport>> watchAll() => _col
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(IncidentReport.fromDoc).toList());

  /// Requires composite index: reporterId ASC + createdAt DESC (see end).
  Stream<List<IncidentReport>> watchMine(String uid) => _col
      .where('reporterId', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(IncidentReport.fromDoc).toList());

  Future<void> create({
    required AppUser reporter,
    required String title,
    required String description,
    required ReportCategory category,
    required String location,
    String? photoUrl,
  }) async {
    await _col.add({
      'title': title.trim(),
      'description': description.trim(),
      'category': category.name,
      'location': location,
      'status': ReportStatus.submitted.name,
      'reporterId': reporter.uid,
      'reporterName': reporter.name,
      'photoUrl': photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'statusHistory': [
        StatusEvent(
          status: ReportStatus.submitted,
          at: DateTime.now(),
          byName: reporter.name,
        ).toMap(),
      ],
    });
  }

  Future<void> updateStatus({
    required IncidentReport report,
    required ReportStatus status,
    required AppUser staff,
    String? note,
  }) async {
    final event = StatusEvent(
      status: status,
      at: DateTime.now(),
      byName: staff.name,
      note: note?.trim(),
    );
    await _col.doc(report.id).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
      'statusHistory': FieldValue.arrayUnion([event.toMap()]),
    });
  }

  Future<void> delete(String id) => _col.doc(id).delete();
}