import 'package:cloud_firestore/cloud_firestore.dart';

class UserRecord {
  const UserRecord({
    required this.id,
    required this.nama,
    required this.email,
    required this.kelas,
    this.invalidFields = const {},
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String nama;
  final String email;
  final String kelas;
  final Set<String> invalidFields;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get needsRepair => invalidFields.isNotEmpty;

  factory UserRecord.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) => UserRecord.fromMap(document.id, document.data());

  factory UserRecord.fromMap(String id, Map<String, dynamic> data) {
    final invalidFields = <String>{};

    String readRequiredString(String field) {
      final value = data[field];
      if (value is! String || value.trim().isEmpty) {
        invalidFields.add(field);
        return '';
      }
      return value.trim();
    }

    return UserRecord(
      id: id,
      nama: readRequiredString('nama'),
      email: readRequiredString('email'),
      kelas: readRequiredString('kelas'),
      invalidFields: Set.unmodifiable(invalidFields),
      createdAt: _dateTime(data['createdAt']),
      updatedAt: _dateTime(data['updatedAt']),
    );
  }

  static DateTime? _dateTime(Object? value) => switch (value) {
    Timestamp timestamp => timestamp.toDate(),
    DateTime dateTime => dateTime,
    _ => null,
  };
}
