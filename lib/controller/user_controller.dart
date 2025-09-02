import 'package:app_mobile2/model/user_model.dart';
import 'package:app_mobile2/view/components/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

class UserController extends ChangeNotifier {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AppUser? _userRegistrationData;

  // Métodos para coleta de dados cadastrais
  void updatePersonalInfo1(String firstName, String lastName, String profession,
      String? gender, String? civilStatus) {
    // Inicializa o objeto AppUser se ele for nulo
    _userRegistrationData ??= AppUser.createEmpty();

    _userRegistrationData?.firstName = firstName;
    _userRegistrationData?.lastName = lastName;
    _userRegistrationData?.profession = profession;
    _userRegistrationData?.gender = gender;
    _userRegistrationData?.civilStatus = civilStatus;
  }

  void updatePersonalInfo2(String dateOfBirth, String rg, String cpf,
      String nationality, String naturality) {
    _userRegistrationData?.dateOfBirth = dateOfBirth;
    _userRegistrationData?.rg = rg;
    _userRegistrationData?.cpf = cpf;
    _userRegistrationData?.nationality = nationality;
    _userRegistrationData?.naturality = naturality;
  }

  void updateAddressInfo(
      String street,
      String number,
      String? complement,
      String neighborhood,
      String city,
      String state,
      String country,
      String postalCode) {
    _userRegistrationData?.street = street;
    _userRegistrationData?.number = number;
    _userRegistrationData?.complement = complement;
    _userRegistrationData?.neighborhood = neighborhood;
    _userRegistrationData?.city = city;
    _userRegistrationData?.state = state;
    _userRegistrationData?.country = country;
    _userRegistrationData?.postalCode = postalCode;
  }

  // Método para registrar um novo usuário
  void registerUser(context, email, password, phoneNumber) {
    _auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((result) {
      _firestore.collection('users').add({
        'uid': result.user!.uid.toString(),
        'type': _userRegistrationData!.type.toString(),
        'email': email,
        'phoneNumber': phoneNumber,
        'firstName': _userRegistrationData!.firstName,
        'lastName': _userRegistrationData!.lastName,
        'profession': _userRegistrationData!.profession,
        'gender': _userRegistrationData!.gender,
        'civilStatus': _userRegistrationData!.civilStatus,
        'dateOfBirth': _userRegistrationData!.dateOfBirth,
        'rg': _userRegistrationData!.rg,
        'cpf': _userRegistrationData!.cpf,
        'nationality': _userRegistrationData!.nationality,
        'naturality': _userRegistrationData!.naturality,
        'street': _userRegistrationData!.street,
        'number': _userRegistrationData!.number,
        'complement': _userRegistrationData!.complement,
        'neighborhood': _userRegistrationData!.neighborhood,
        'city': _userRegistrationData!.city,
        'state': _userRegistrationData!.state,
        'country': _userRegistrationData!.country,
        'postalCode': _userRegistrationData!.postalCode,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
      showMessage(context, 'Usuário criado com sucesso');
      Navigator.pushReplacementNamed(context, 'login');
    }).catchError((e) {
      showMessage(context, _handleAuthError(e));
    });
  }

  // Método para fazer login
  void login(context, String email, String password) {
    _auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((result) async {
      showMessage(context, "Usuário autenticado com sucesso!");
      Navigator.pushReplacementNamed(context, 'home');
    }).catchError((e) {
      showMessage(context, _handleAuthError(e));
    });
  }

  // Método para recuperar senha
  void resetPassword(context, String email) {
    _auth.sendPasswordResetEmail(email: email).then((result) {
      showMessage(context, "Um email de verificação foi enviado para $email");
    }).catchError((e) {
      showMessage(context, _handleAuthError(e));
    });
  }

  // Método para fazer logout
  void logout() {
    _auth.signOut();
  }

  String getCurrentUserId() {
    final user = _auth.currentUser;
    return user!.uid;
  }

  Future<String> getCurrentUserName() async {
    var userName = '';
    await _firestore
        .collection('users')
        .where('uid', isEqualTo: getCurrentUserId())
        .get()
        .then((result) {
      userName = result.docs[0].data()['firstName'] ?? '';
    });

    return userName;
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
