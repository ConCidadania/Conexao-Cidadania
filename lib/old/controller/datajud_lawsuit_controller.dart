import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:con_cidadania/old/controller/lawsuit_controller.dart';
import 'package:con_cidadania/old/model/datajud_lawsuit_model.dart';
import 'package:con_cidadania/old/services/datajud_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class DatajudLawsuitController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final lawsuitCtrl = GetIt.I.get<LawsuitController>();
  final DatajudService _datajudService = DatajudService();

  void _updateTimeline(String numeroProcesso) async {
    // Consultar Datajud Service
    DatajudLawsuit? result =
        await _datajudService.consultarProcesso(numeroProcesso);
    // Enviar dados para o firestore
    CollectionReference lawsuitTimeline = _firestore
        .collection('lawsuits')
        .doc(lawsuitCtrl.currentLawsuitId)
        .collection('historico');
    QuerySnapshot timelineSnapshot = await lawsuitTimeline.get();

    if (timelineSnapshot.size < (result?.movimentos.length ?? 0)) {
      // Update records
      for (Movimento movimento in result!.movimentos) {
        await lawsuitTimeline.doc().set({
          'name': movimento.nome,
          'date': movimento.data,
        });
      }
    }
  }

  Stream<QuerySnapshot> fetchAllTimelineItems(String numeroProcesso) {
    _updateTimeline(numeroProcesso);
    // Return documentos da subcoleção "historico"
    var result = _firestore
        .collection('lawsuits')
        .doc(lawsuitCtrl.currentLawsuitId)
        .collection('historico')
        .orderBy("date", descending: true);

    return result.snapshots();
  }
}
