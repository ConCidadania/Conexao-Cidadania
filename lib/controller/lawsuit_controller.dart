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

  String get currentLawsuitId => _currentLawsuitId;

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
    final userType = userCtrl.getCurrentUserType();
    final userId = userCtrl.getCurrentUserId();

    try {
      // Usamos documentName aqui para padronização do nome do arquivo
      final String path =
          'files/users/${userType == 'USER' ? userId : await getCurrentLawsuitOwnerId()}/lawsuits/$_currentLawsuitId/docs/$documentName';
      final Reference ref = _storage.ref().child(path);

      final SettableMetadata metadata = SettableMetadata(
        contentType: getContentType(fileName),
        contentDisposition: 'attachment; filename="$fileName"',
      );

      final UploadTask uploadTask = ref.putData(fileData, metadata);
      final TaskSnapshot snapshot = await uploadTask;

      final String downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint(
          "Upload de documento '$documentName' realizado com sucesso. URL: $downloadUrl");

      // TODO: Validar onde e se realmente necessário salvar documentação
      // Salvar download url na ação (?)
      /*
      _firestore.collection('lawsuits').doc(currentLawsuitId).update({
        documentName: downloadUrl,
      });
      */

      return downloadUrl;
    } on FirebaseException catch (e) {
      debugPrint(
          "Erro no Firebase Storage ao fazer upload de $documentName: ${e.message}");
      return null;
    } catch (e) {
      debugPrint("Erro desconhecido ao fazer upload de $documentName: $e");
      return null;
    }
  }

  /* Obtém a URL de download de um arquivo do Firebase Storage.
   * Esta URL pode ser usada no Flutter Web para abrir o arquivo em uma nova aba,
   * ou disparar o download local do arquivo no dispositivo
   * 
   * Retorna a URL de download (String) ou null em caso de erro.
   */
  Future<String?> getDocumentDownloadURL(String storagePath) async {
    try {
      final Reference ref = _storage.ref().child(storagePath);

      // Obtém a URL pública de download
      final String downloadUrl = await ref.getDownloadURL();

      debugPrint(
          "Download URL obtida com sucesso para o caminho: $storagePath");

      return downloadUrl;
    } on FirebaseException catch (e) {
      debugPrint(
          "Erro no Firebase Storage ao obter URL de $storagePath: ${e.message}");
      return null;
    } catch (e) {
      debugPrint("Erro desconhecido ao obter URL de $storagePath: $e");
      return null;
    }
  }

  Stream<QuerySnapshot> fetchUserLawsuits(String field) {
    var result = _firestore
        .collection('lawsuits')
        .where('ownerId', isEqualTo: userCtrl.getCurrentUserId())
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

  Future<String> getCurrentLawsuitOwnerId() async {
    DocumentSnapshot snapshot =
        await _firestore.collection('lawsuits').doc(_currentLawsuitId).get();

    String ownerId = snapshot.get('ownerId') as String;
    return ownerId;
  }

  void updateLawsuitStatus(String newStatus) {
    _firestore
        .collection('lawsuits')
        .doc(_currentLawsuitId)
        .update({'status': newStatus});
  }

  Future<String> getCurrentLawsuitStatus() async {
    DocumentSnapshot snapshot =
        await _firestore.collection('lawsuits').doc(_currentLawsuitId).get();

    String status = snapshot.get('status') as String;
    return status;
  }

  void updateLawsuitJudicialProcessNumber(String numeroProcesso) {
    _firestore
        .collection('lawsuits')
        .doc(_currentLawsuitId)
        .update({'judicialProcessNumber': numeroProcesso});
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
      return null;
  }
}
