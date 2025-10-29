import 'package:flutter/material.dart';
import '../../domain/entities/app_user.dart';
import '../../application/use_cases/register_user.dart';
import '../../application/use_cases/login_user.dart';
import '../../application/use_cases/logout_user.dart';
import '../../application/use_cases/reset_password.dart';
import '../../application/use_cases/edit_user.dart';
import '../../application/use_cases/get_current_user.dart';
import '../../application/use_cases/fetch_all_users.dart';
import '../../domain/errors/user_failures.dart';
import '../models/user_registration_data.dart';
import '../services/message_service.dart';
import '../services/navigation_service.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/gender.dart';
import '../../domain/value_objects/civil_status.dart';
import '../../domain/value_objects/state_code.dart';
import '../../domain/value_objects/oab.dart';

class UserStateNotifier extends ChangeNotifier {
  final RegisterUser _registerUser;
  final LoginUser _loginUser;
  final LogoutUser _logoutUser;
  final ResetPassword _resetPassword;
  final EditUser _editUser;
  final GetCurrentUser _getCurrentUser;
  final FetchAllUsers _fetchAllUsers;
  final MessageService _messageService;
  final NavigationService _navigationService;

  AppUser? _currentUser;
  UserRegistrationData _userRegistrationData = UserRegistrationData();
  List<AppUser> _allUsers = [];
  bool _isLoading = false;
  String? _errorMessage;

  UserStateNotifier({
    required RegisterUser registerUser,
    required LoginUser loginUser,
    required LogoutUser logoutUser,
    required ResetPassword resetPassword,
    required EditUser editUser,
    required GetCurrentUser getCurrentUser,
    required FetchAllUsers fetchAllUsers,
    required MessageService messageService,
    required NavigationService navigationService,
  })  : _registerUser = registerUser,
        _loginUser = loginUser,
        _logoutUser = logoutUser,
        _resetPassword = resetPassword,
        _editUser = editUser,
        _getCurrentUser = getCurrentUser,
        _fetchAllUsers = fetchAllUsers,
        _messageService = messageService,
        _navigationService = navigationService;

  // Getters
  AppUser? get currentUser => _currentUser;
  UserRegistrationData get userRegistrationData => _userRegistrationData;
  List<AppUser> get allUsers => _allUsers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  NavigationService get navigationService => _navigationService;

  // Registration data management
  void updatePersonalInfo1({
    required String firstName,
    required String lastName,
    required String profession,
    String? gender,
    String? civilStatus,
  }) {
    try {
      Gender? genderEnum;
      CivilStatus? civilStatusEnum;

      if (gender != null) {
        genderEnum = Gender.fromString(gender);
      }
      if (civilStatus != null) {
        civilStatusEnum = CivilStatus.fromString(civilStatus);
      }

      _userRegistrationData.updatePersonalInfo1(
        firstName: firstName,
        lastName: lastName,
        profession: profession,
        gender: genderEnum,
        civilStatus: civilStatusEnum,
      );
      _notifyListeners();
    } catch (e) {
      _handleError(e);
    }
  }

  void updatePersonalInfo2({
    required DateTime dateOfBirth,
    required String rg,
    required String cpf,
    required String nationality,
    required String naturality,
  }) {
    try {
      _userRegistrationData.updatePersonalInfo2(
        dateOfBirth: dateOfBirth,
        rg: rg,
        cpf: cpf,
        nationality: nationality,
        naturality: naturality,
      );
      _notifyListeners();
    } catch (e) {
      _handleError(e);
    }
  }

  void updateAddressInfo({
    required String street,
    required String number,
    String? complement,
    required String neighborhood,
    required String city,
    required String state,
    required String country,
    required String postalCode,
  }) {
    try {
      _userRegistrationData.updateAddressInfo(
        street: street,
        number: number,
        complement: complement,
        neighborhood: neighborhood,
        city: city,
        state: state,
        country: country,
        postalCode: postalCode,
      );
      _notifyListeners();
    } catch (e) {
      _handleError(e);
    }
  }

  void updateAuthInfo({
    required String email,
    required String phoneNumber,
    required String password,
    String? registroOAB,
  }) {
    try {
      Oab? oabValue;
      if (registroOAB != null && registroOAB.isNotEmpty) {
        oabValue = Oab.parse(registroOAB);
      }

      _userRegistrationData.updateAuthInfo(
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        registroOAB: oabValue,
      );
      _notifyListeners();
    } catch (e) {
      _handleError(e);
    }
  }

  // Authentication methods
  Future<void> registerUser(String email, String password) async {
    if (!_userRegistrationData.isComplete()) {
      _messageService.showError('Dados de cadastro incompletos');
      return;
    }

    await _executeOperation(() async {
      // Update auth info with email and password
      _userRegistrationData.updateAuthInfo(
        email: email,
        phoneNumber: _userRegistrationData.phoneNumber,
        password: password,
        registroOAB: _userRegistrationData.registroOAB,
      );

      // Convert registration data to AppUser and register
      final userData = _userRegistrationData.toAppUser(
        userId: UserId.fromString(''), // Will be set by auth service
      );
      
      _currentUser = await _registerUser.call(
        userData: userData,
        password: password,
      );
      
      _userRegistrationData.clear();
      _messageService.showSuccess('Usuário cadastrado com sucesso!');
      _navigationService.navigateAndRemoveUntil('home');
    });
  }

  Future<void> loginUser(String email, String password) async {
    await _executeOperation(() async {
      _currentUser = await _loginUser.call(email: email, password: password);
      _messageService.showSuccess('Login realizado com sucesso!');
      _navigationService.navigateAndRemoveUntil('home');
    });
  }

  Future<void> logoutUser() async {
    await _executeOperation(() async {
      await _logoutUser.call();
      _currentUser = null;
      _messageService.showInfo('Logout realizado com sucesso');
      _navigationService.navigateAndRemoveUntil('login');
    });
  }

  Future<void> resetPassword(String email) async {
    await _executeOperation(() async {
      await _resetPassword.call(email: email);
      _messageService.showSuccess('Email de recuperação enviado com sucesso!');
    });
  }

  Future<void> editUser(AppUser updatedUser) async {
    if (_currentUser == null) {
      _messageService.showError('Usuário não encontrado');
      return;
    }

    await _executeOperation(() async {
      _currentUser = await _editUser.call(
        userId: _currentUser!.id,
        updatedUser: updatedUser,
      );
      _messageService.showSuccess('Usuário atualizado com sucesso!');
    });
  }

  Future<void> editUserById(String userId, AppUser updatedUser) async {
    await _executeOperation(() async {
      await _editUser.call(
        userId: UserId.fromString(userId),
        updatedUser: updatedUser,
      );
      _messageService.showSuccess('Usuário atualizado com sucesso!');
      
      // Refresh the users list
      fetchAllUsers();
    });
  }

  Future<void> loadCurrentUser() async {
    await _executeOperation(() async {
      _currentUser = await _getCurrentUser.call();
    });
  }

  void fetchAllUsers({String orderBy = 'createdAt'}) {
    _fetchAllUsers.call(orderBy: orderBy).listen(
      (users) {
        _allUsers = users;
        _notifyListeners();
      },
      onError: (error) {
        _handleError(error);
      },
    );
  }

  // Helper methods
  Future<void> _executeOperation(Future<void> Function() operation) async {
    _setLoading(true);
    _clearError();

    try {
      await operation();
    } catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  void _handleError(dynamic error) {
    String message;
    if (error is UserFailure) {
      message = error.message;
    } else {
      message = 'Erro inesperado: ${error.toString()}';
    }
    
    _setError(message);
    _messageService.showError(message);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    _notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    _notifyListeners();
  }

  void _notifyListeners() {
    notifyListeners();
  }

  // Utility methods for UI
  String getCurrentUserName() {
    return _currentUser?.name.fullName ?? '';
  }

  String getCurrentUserType() {
    return _currentUser?.type.displayName ?? '';
  }

  String getCurrentUserId() {
    return _currentUser?.id.value ?? '';
  }

  // Registration step validation
  bool isStep1Valid() => _userRegistrationData.isStep1Complete();
  bool isStep2Valid() => _userRegistrationData.isStep2Complete();
  bool isStep3Valid() => _userRegistrationData.isStep3Complete();
  bool isStep4Valid() => _userRegistrationData.isStep4Complete();
}
