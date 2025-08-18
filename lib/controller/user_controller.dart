import 'dart:io';
import 'package:app_mobile2/model/agendamento_model.dart';
import 'package:app_mobile2/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class UserController extends ChangeNotifier {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Método para registrar um novo usuário
  Future<bool> registerUser(
      String name, String email, String phoneNumber, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Criar usuário no Firebase Authentication
      auth.UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Criar documento do usuário no Firestore
      Timestamp now = Timestamp.now();
      User newUser = User(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(newUser.toFirestore());

      _currentUser = newUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _handleAuthError(e);
      notifyListeners();
      return false;
    }
  }

  // Método para fazer login
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Autenticar usuário no Firebase Authentication
      auth.UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Buscar dados do usuário no Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        _currentUser = User.fromFirestore(userDoc);
      } else {
        throw Exception('Usuário não encontrado no banco de dados');
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _handleAuthError(e);
      notifyListeners();
      return false;
    }
  }

  // Método para recuperar senha
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _auth.sendPasswordResetEmail(email: email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _handleAuthError(e);
      notifyListeners();
      return false;
    }
  }

  // Método para fazer logout
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // Método para verificar se o usuário está logado
  Future<bool> checkUserLoggedIn() async {
    auth.User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (userDoc.exists) {
          _currentUser = User.fromFirestore(userDoc);
          notifyListeners();
          return true;
        }
      } catch (e) {
        debugPrint('Erro ao buscar dados do usuário: $e');
      }
    }
    return false;
  }

  // Método para buscar agendamentos do usuário
  Future<List<Appointment>> fetchUserAppointments() async {
    if (_currentUser == null) {
      throw Exception('Usuário não está logado');
    }

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('appointments')
          .where('user_uid', isEqualTo: _currentUser!.uid)
          .orderBy('created_at', descending: true)
          .get();

      List<Appointment> appointments = [];
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        Appointment appointment = Appointment.fromFirestore(doc);
        appointments.add(appointment);
      }

      return appointments;
    } catch (e) {
      debugPrint('Erro ao buscar agendamentos: $e');
      throw Exception('Erro ao buscar agendamentos: $e');
    }
  }

  // Método para criar um novo agendamento
  Future<bool> createAppointment({
    required String serviceId,
    required String serviceName,
    required String professionalId,
    required String professionalName,
    required String date,
    required String time,
    String? document1Url,
    String? document2Url,
  }) async {
    if (_currentUser == null) return false;

    try {
      Timestamp now = Timestamp.now();

      Map<String, dynamic> appointmentData = {
        'userId': _currentUser!.uid,
        'user_uid': _currentUser!.uid,
        'serviceId': serviceId,
        'service_id': serviceId,
        'serviceName': serviceName,
        'service_name': serviceName,
        'professionalId': professionalId,
        'professional_id': professionalId,
        'professionalName': professionalName,
        'professional_name': professionalName,
        'date': date,
        'appointment_date': date,
        'time': time,
        'appointment_time': time,
        'status': 'agendado',
        'document1Url': document1Url,
        'document_1_url': document1Url,
        'document2Url': document2Url,
        'document_2_url': document2Url,
        'createdAt': now,
        'created_at': now,
        'updatedAt': now,
        'updated_at': now,
      };

      await _firestore.collection('appointments').add(appointmentData);
      return true;
    } catch (e) {
      debugPrint('Erro ao criar agendamento: $e');
      return false;
    }
  }

  // Método para atualizar data e hora de um agendamento
  Future<bool> updateAppointmentDateTime(
      String appointmentId, String newDate, String newTime) async {
    try {
      Timestamp now = Timestamp.now();
      await _firestore.collection('appointments').doc(appointmentId).update({
        'date': newDate,
        'appointment_date': newDate,
        'time': newTime,
        'appointment_time': newTime,
        'updatedAt': now,
        'updated_at': now,
      });
      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar agendamento: $e');
      return false;
    }
  }

  // Método para cancelar um agendamento
  Future<bool> cancelAppointment(String appointmentId) async {
    try {
      Timestamp now = Timestamp.now();
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'cancelado',
        'updatedAt': now,
        'updated_at': now,
      });
      return true;
    } catch (e) {
      debugPrint('Erro ao cancelar agendamento: $e');
      return false;
    }
  }

  // Método para fazer upload de documentos
  Future<String?> uploadDocument(File file, String fileName) async {
    try {
      if (_currentUser == null) return null;

      String filePath =
          'documents/${_currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      Reference ref = _storage.ref().child(filePath);

      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Erro ao fazer upload do documento: $e');
      return null;
    }
  }

  // Método para atualizar perfil do usuário
  Future<bool> updateUserProfile({
    String? name,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
    String? rgCpfDocumentUrl,
    String? cnhDocumentUrl,
  }) async {
    if (_currentUser == null) return false;

    try {
      Timestamp now = Timestamp.now();
      Map<String, dynamic> updateData = {
        'updatedAt': now,
        'updated_at': now,
      };

      if (name != null) updateData['name'] = name;
      if (phoneNumber != null) {
        updateData['phoneNumber'] = phoneNumber;
        updateData['phone_number'] = phoneNumber;
      }
      if (address != null) updateData['address'] = address;
      if (profileImageUrl != null) {
        updateData['profilePictureUrl'] = profileImageUrl;
        updateData['profile_picture_url'] = profileImageUrl;
        updateData['profile_image_url'] = profileImageUrl;
      }
      if (rgCpfDocumentUrl != null) {
        updateData['rgCpfDocumentUrl'] = rgCpfDocumentUrl;
        updateData['rg_cpf_document_url'] = rgCpfDocumentUrl;
        updateData['rg_url'] = rgCpfDocumentUrl;
      }
      if (cnhDocumentUrl != null) {
        updateData['cnhDocumentUrl'] = cnhDocumentUrl;
        updateData['cnh_document_url'] = cnhDocumentUrl;
        updateData['cnh_url'] = cnhDocumentUrl;
      }

      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .update(updateData);

      // Atualizar o usuário local
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(_currentUser!.uid).get();

      if (userDoc.exists) {
        _currentUser = User.fromFirestore(userDoc);
        notifyListeners();
      }

      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar perfil: $e');
      return false;
    }
  }

  // Método para tratar erros de autenticação
  String _handleAuthError(dynamic e) {
    String message = 'Ocorreu um erro. Tente novamente.';
    if (e is auth.FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          message = 'Usuário não encontrado.';
          break;
        case 'wrong-password':
          message = 'Senha incorreta.';
          break;
        case 'email-already-in-use':
          message = 'Este e-mail já está em uso.';
          break;
        case 'weak-password':
          message = 'A senha é muito fraca.';
          break;
        case 'invalid-email':
          message = 'E-mail inválido.';
          break;
        default:
          message = 'Erro: ${e.code}';
      }
    }
    return message;
  }
}
