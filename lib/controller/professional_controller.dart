import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/professional_model.dart';

class ProfessionalController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Professional> _professionals = [];
  Professional? _selectedProfessional;
  bool _isLoading = false;
  String? _errorMessage;

  List<Professional> get professionals => _professionals;
  Professional? get selectedProfessional => _selectedProfessional;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Método para definir o profissional selecionado
  void setSelectedProfessional(Professional? professional) {
    _selectedProfessional = professional;
    notifyListeners();
  }

  Professional? getSelectedProfessional() {
    return _selectedProfessional;
  }

  // Método para buscar todos os profissionais
  Future<List<Professional>> fetchProfessionals() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      QuerySnapshot querySnapshot =
          await _firestore.collection('professionals').get();

      _professionals = querySnapshot.docs
          .map((doc) => Professional.fromFirestore(doc))
          .toList();

      _isLoading = false;
      notifyListeners();
      return _professionals;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erro ao buscar profissionais: $e';
      notifyListeners();
      debugPrint('Erro ao buscar profissionais: $e');
      return [];
    }
  }

  // Método para buscar profissionais por especialidade
  Future<List<Professional>> fetchProfessionalsBySpecialty(
      String specialty) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      QuerySnapshot querySnapshot = await _firestore
          .collection('professionals')
          .where('specialty', isEqualTo: specialty)
          .get();

      List<Professional> specialtyProfessionals = querySnapshot.docs
          .map((doc) => Professional.fromFirestore(doc))
          .toList();

      _isLoading = false;
      notifyListeners();
      return specialtyProfessionals;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erro ao buscar profissionais por especialidade: $e';
      notifyListeners();
      debugPrint('Erro ao buscar profissionais por especialidade: $e');
      return [];
    }
  }

  // Método para buscar um profissional específico por ID
  Future<Professional?> fetchProfessionalById(String professionalId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      DocumentSnapshot doc = await _firestore
          .collection('professionals')
          .doc(professionalId)
          .get();

      if (doc.exists) {
        Professional professional = Professional.fromFirestore(doc);
        _isLoading = false;
        notifyListeners();
        return professional;
      } else {
        _isLoading = false;
        _errorMessage = 'Profissional não encontrado';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erro ao buscar profissional: $e';
      notifyListeners();
      debugPrint('Erro ao buscar profissional: $e');
      return null;
    }
  }

  // Método para limpar seleção
  void clearSelection() {
    _selectedProfessional = null;
    notifyListeners();
  }

  // Método para verificar se um profissional está selecionado
  bool isProfessionalSelected(Professional professional) {
    return _selectedProfessional?.id == professional.id;
  }
}
