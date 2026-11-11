import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
  });

  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String department;

  bool get isStaff => role == UserRole.staff;

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return AppUser(
      uid: doc.id,
      name: d['name'] ?? '',
      email: d['email'] ?? '',
      role: UserRole.fromName(d['role']),
      department: d['department'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'role': role.name,
        'department': department,
        'createdAt': FieldValue.serverTimestamp(),
      };
}