// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

enum LawsuitType {
  REMEDIO_ALTO_CUSTO,
  VAGA_CRECHE_PUBLICA,
  CIRURGIA_EMERGENCIAL,
  ALTERACAO_NOME_SOCIAL,
  INTER_INST_LONGA_PERM
}

class Lawsuit {
  String owner;
  String type;

  Timestamp createdAt;

  Lawsuit({required this.owner, required this.type, required this.createdAt});

  factory Lawsuit.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Lawsuit(
        owner: data['owner'] ?? '',
        type: data['type'] ?? '',
        createdAt: data['createdAt'] ?? Timestamp.now());
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'owner': owner,
      'type': type,
      'createdAt': createdAt,
    };
  }
}
