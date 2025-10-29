// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:con_cidadania/core/utils/time.dart';

enum LawsuitType {
  REMEDIO_ALTO_CUSTO,
  VAGA_CRECHE_PUBLICA,
  CIRURGIA_EMERGENCIAL,
  ALTERACAO_NOME_SOCIAL,
  INTERNACAO_ILP
}

enum DocumentType {
  // Em comum
  documento_identidade,
  comprovante_endereco,
  procuracao_assinada,
  // Vaga em creche pública
  protocolo_inscricao_creche,
  documento_identidade_crianca,
  // Remédio de alto custo
  copia_prontuario_medico,
  copia_receituario_medico,
  expediente_administrativo_secretaria_saude,
  tres_ultimos_holerites,
}

class Lawsuit {
  String? uid;
  String name;
  String type;
  String ownerId;
  String ownerFirstName;
  String ownerLastName;
  String ownerPhoneNumber;
  String ownerEmail;
  String judicialProcessNumber;
  String status;

  String createdAt;

  Lawsuit(
      {this.uid,
      required this.name,
      required this.type,
      required this.ownerId,
      required this.ownerFirstName,
      required this.ownerLastName,
      required this.ownerPhoneNumber,
      required this.ownerEmail,
      required this.createdAt,
      required this.judicialProcessNumber,
      required this.status});

  factory Lawsuit.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Lawsuit(
        uid: doc.id,
        name: data['name'] ?? '',
        type: data['type'] ?? '',
        ownerId: data['ownerId'] ?? '',
        ownerFirstName: data['ownerFirstName'] ?? '',
        ownerLastName: data['ownerLastName'] ?? '',
        ownerPhoneNumber: data['ownerPhoneNumber'] ?? '',
        ownerEmail: data['ownerEmail'] ?? '',
        judicialProcessNumber: data['judicialProcessNumber'] ?? '',
        status: data['status'] ?? '',
        createdAt: data['createdAt'] ?? formatDate(DateTime.now()));
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'name': name,
      'type': type,
      'ownerId': ownerId,
      'ownerFirstName': ownerFirstName,
      'ownerLastName': ownerLastName,
      'ownerPhoneNumber': ownerPhoneNumber,
      'ownerEmail': ownerEmail,
      'judicialProcessNumber': judicialProcessNumber,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
