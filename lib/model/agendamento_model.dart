import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String userId;
  final String serviceId;
  final String professionalId;
  final String serviceName;
  final String professionalName;
  final String date;
  final String time;
  final String status;
  final String? document1Url;
  final String? document2Url;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Appointment({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.professionalId,
    required this.serviceName,
    required this.professionalName,
    required this.date,
    required this.time,
    required this.status,
    this.document1Url,
    this.document2Url,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getters para facilitar o acesso nas Views (mantendo compatibilidade)
  String get appointmentDate => date;
  String get appointmentTime => time;

  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Appointment(
      id: doc.id,
      userId: data['userId'] ?? data['user_uid'] ?? '',
      serviceId: data['serviceId'] ?? data['service_id'] ?? '',
      professionalId: data['professionalId'] ?? data['professional_id'] ?? '',
      serviceName: data['serviceName'] ?? data['service_name'] ?? '',
      professionalName:
          data['professionalName'] ?? data['professional_name'] ?? '',
      date: data['date'] ?? data['appointment_date'] ?? '',
      time: data['time'] ?? data['appointment_time'] ?? '',
      status: data['status'] ?? 'agendado',
      document1Url: data['document1Url'] ?? data['document_1_url'],
      document2Url: data['document2Url'] ?? data['document_2_url'],
      createdAt: data['createdAt'] ?? data['created_at'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? data['updated_at'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'user_uid': userId, // Compatibilidade dupla
      'serviceId': serviceId,
      'service_id': serviceId, // Compatibilidade dupla
      'professionalId': professionalId,
      'professional_id': professionalId, // Compatibilidade dupla
      'serviceName': serviceName,
      'service_name': serviceName, // Compatibilidade dupla
      'professionalName': professionalName,
      'professional_name': professionalName, // Compatibilidade dupla
      'date': date,
      'appointment_date': date, // Compatibilidade dupla
      'time': time,
      'appointment_time': time, // Compatibilidade dupla
      'status': status,
      'document1Url': document1Url,
      'document_1_url': document1Url, // Compatibilidade dupla
      'document2Url': document2Url,
      'document_2_url': document2Url, // Compatibilidade dupla
      'createdAt': createdAt,
      'created_at': createdAt, // Compatibilidade dupla
      'updatedAt': updatedAt,
      'updated_at': updatedAt, // Compatibilidade dupla
    };
  }

  Appointment copyWith({
    String? id,
    String? userId,
    String? serviceId,
    String? professionalId,
    String? serviceName,
    String? professionalName,
    String? date,
    String? time,
    String? status,
    String? document1Url,
    String? document2Url,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      serviceId: serviceId ?? this.serviceId,
      professionalId: professionalId ?? this.professionalId,
      serviceName: serviceName ?? this.serviceName,
      professionalName: professionalName ?? this.professionalName,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      document1Url: document1Url ?? this.document1Url,
      document2Url: document2Url ?? this.document2Url,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Appointment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Appointment(id: $id, serviceName: $serviceName, professionalName: $professionalName, date: $date, time: $time)';
  }
}
