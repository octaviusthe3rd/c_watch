import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

class StatusEvent {
  const StatusEvent({
    required this.status,
    required this.at,
    required this.byName,
    this.note,
  });

  final ReportStatus status;
  final DateTime at;
  final String byName;
  final String? note;

  factory StatusEvent.fromMap(Map<String, dynamic> m) => StatusEvent(
        status: ReportStatus.fromName(m['status']),
        at: (m['at'] as Timestamp?)?.toDate() ?? DateTime.now(),
        byName: m['byName'] ?? '',
        note: m['note'],
      );

  // Note: serverTimestamp() is NOT allowed inside arrays, so we use Timestamp.
  Map<String, dynamic> toMap() => {
        'status': status.name,
        'at': Timestamp.fromDate(at),
        'byName': byName,
        if (note != null && note!.isNotEmpty) 'note': note,
      };
}

class IncidentReport {
  const IncidentReport({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.status,
    required this.reporterId,
    required this.reporterName,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.history,
  });

  final String id;
  final String title;
  final String description;
  final ReportCategory category;
  final String location;
  final ReportStatus status;
  final String reporterId;
  final String reporterName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<StatusEvent> history;

  factory IncidentReport.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return IncidentReport(
      id: doc.id,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      category: ReportCategory.fromName(d['category']),
      location: d['location'] ?? '',
      status: ReportStatus.fromName(d['status']),
      reporterId: d['reporterId'] ?? '',
      reporterName: d['reporterName'] ?? 'Unknown',
      photoUrl: d['photoUrl'],
      // Falls back to now() while the server timestamp is pending locally.
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      history: ((d['statusHistory'] as List?) ?? [])
          .map((e) => StatusEvent.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  StatusEvent? eventFor(ReportStatus s) {
    StatusEvent? found;
    for (final e in history) {
      if (e.status == s) found = e;
    }
    return found;
  }

  StatusEvent? get latestNote {
    StatusEvent? found;
    for (final e in history) {
      if ((e.note ?? '').isNotEmpty) found = e;
    }
    return found;
  }
}