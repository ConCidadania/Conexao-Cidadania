// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:con_cidadania/view/components/time.dart';

enum LawsuitType {
  REMEDIO_ALTO_CUSTO,
  VAGA_CRECHE_PUBLICA,
  CIRURGIA_EMERGENCIAL,
  ALTERACAO_NOME_SOCIAL,
  INTERNACAO_ILP
}

class Lawsuit {
  String owner;
  String name;
  String type;

  String createdAt;

  Lawsuit(
      {required this.owner,
      required this.name,
      required this.type,
      required this.createdAt});

  factory Lawsuit.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Lawsuit(
        owner: data['owner'] ?? '',
        name: data['name'] ?? '',
        type: data['type'] ?? '',
        createdAt: data['createdAt'] ?? formatDate(DateTime.now()));
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'owner': owner,
      'name': name,
      'type': type,
      'createdAt': createdAt,
    };
  }
}
