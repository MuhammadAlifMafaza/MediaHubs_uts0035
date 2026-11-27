import 'package:cloud_firestore/cloud_firestore.dart';

class UserRecord {
  const UserRecord({
    required this.id,
    required this.nama,
    required this.email,
    required this.kelas,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String nama;
  final String email;
  final String kelas;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserRecord.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    return UserRecord(
      id: document.id,
      nama: _stringField(data, 'nama'),
      email: _stringField(data, 'email'),
      kelas: _stringField(data, 'kelas'),
      createdAt: _dateTime(data['createdAt']),
      updatedAt: _dateTime(data['updatedAt']),
    );
  }

  static String _stringField(Map<String, dynamic> data, String field) {
    final value = data[field];
    if (value is! String) {
      throw FormatException('Field "$field" must be a string.');
    }
    return value.trim();
  }

  static DateTime? _dateTime(Object? value) => switch (value) {
    Timestamp timestamp => timestamp.toDate(),
    DateTime dateTime => dateTime,
    _ => null,
  };
}
