import 'dart:typed_data';
import 'package:con_cidadania/controller/user_controller.dart';
import 'package:con_cidadania/model/lawsuit_model.dart';
import 'package:con_cidadania/utils/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class LawsuitController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final userCtrl = GetIt.I.get<UserController>();

  String _currentLawsuitId = '';

  void setCurrentLawsuitId(String? id) {
    _currentLawsuitId = id!;
  }

  void addLawsuit(context, Lawsuit lawsuit) {
    _firestore.collection('lawsuits').add(lawsuit.toFirestore()).then((result) {
      result.set({'uid': result.id}, SetOptions(merge: true));
      showMessage(context, 'Ação adicionada com suceso');
    }).catchError((error) {
      showMessage(context, 'Erro ao adicionar ação');
    });
  }

  Future<String?> uploadDocument(
      String documentName, String fileName, Uint8List fileData) async {
    final userId = userCtrl.getCurrentUserId();

    try {
      // Define o caminho no Firebase Storage
      final String path = 'files/users/$userId/docs/$documentName';
      final Reference ref = _storage.ref().child(path);

      // Metadados para a extensão do arquivo
      final metadata = SettableMetadata(contentType: getContentType(fileName));

      // Realiza o upload do arquivo
      final UploadTask uploadTask = ref.putData(fileData, metadata);
      final TaskSnapshot snapshot = await uploadTask;

      // Retorna a URL de download
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint(
          "Upload de documento '$documentName' realizado com sucesso. URL: $downloadUrl");
      return downloadUrl;
    } on FirebaseException catch (e) {
      debugPrint(
          "Erro no Firebase Storage ao fazer upload de $documentName: ${e.message}");
      // Você pode adicionar um tratamento de erro mais específico aqui (e.g., showMessage)
      return null;
    } catch (e) {
      debugPrint("Erro desconhecido ao fazer upload de $documentName: $e");
      return null;
    }
  }

  Stream<QuerySnapshot> fetchUserLawsuits(String field) {
    var result = _firestore
        .collection('lawsuits')
        .where('ownerId', isEqualTo: UserController().getCurrentUserId())
        .orderBy(field);

    return result.snapshots();
  }

  Stream<QuerySnapshot> fetchAllLawsuits(String field) {
    var result = _firestore.collection('lawsuits').where('uid').orderBy(field);

    return result.snapshots();
  }

  Future<DocumentSnapshot<Object?>> getCurrentLawsuit() async {
    CollectionReference lawsuits = _firestore.collection('lawsuits');

    Future<DocumentSnapshot<Object?>> result =
        lawsuits.doc(_currentLawsuitId).get();

    return result;
  }
}

String? getContentType(String fileName) {
  final extension = fileName.split('.').last.toLowerCase();
  switch (extension) {
    case 'png':
      return 'image/png';
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'pdf':
      return 'application/pdf';
    default:
      return null; // Let Firebase infer or set a default
  }
}
