import 'package:con_cidadania/controller/user_controller.dart';
import 'package:con_cidadania/model/lawsuit_model.dart';
import 'package:con_cidadania/view/components/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LawsuitController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void addLawsuit(context, Lawsuit lawsuit) {
    _firestore
        .collection('lawsuits')
        .add(lawsuit.toFirestore())
        .then(
          (value) => showMessage(context, 'Ação adicionada com suceso'),
        )
        .catchError((error) => showMessage(context, 'Erro ao adicionar ação'));
  }

  Stream<QuerySnapshot> fetchUserLawsuits(String field) {
    var result = _firestore
        .collection('lawsuits')
        .where('owner', isEqualTo: UserController().getCurrentUserId())
        .orderBy(field);

    return result.snapshots();
  }

  Stream<QuerySnapshot> fetchAllLawsuits(String field) {
    var result = _firestore.collection('lawsuits').where('uid').orderBy(field);

    return result.snapshots();
  }
}
