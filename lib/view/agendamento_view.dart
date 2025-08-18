import 'dart:io';
import 'package:app_mobile2/controller/professional_controller.dart';
import 'package:app_mobile2/controller/service_controller.dart';
import 'package:app_mobile2/controller/user_controller.dart';
import 'package:app_mobile2/model/service_model.dart';
import 'package:app_mobile2/model/professional_model.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AgendamentoView extends StatefulWidget {
  const AgendamentoView({super.key});

  @override
  State<AgendamentoView> createState() => _AgendamentoViewState();
}

class _AgendamentoViewState extends State<AgendamentoView> {
  final userController = GetIt.I.get<UserController>();
  final professionalController = GetIt.I.get<ProfessionalController>();
  final serviceController = GetIt.I.get<ServiceController>();
  final Color primaryColor = const Color(0xFF00796B);
  final Color accentColor = const Color(0xFFB2DFDB);

  Service? _selectedService;
  Professional? _selectedProfessional;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _document1;
  File? _document2;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    // Carregar serviços e profissionais
    serviceController.fetchServices();
    professionalController.fetchProfessionals();

    // Verificar se há serviço ou profissional já selecionado
    setState(() {
      _selectedService = serviceController.selectedService;
      _selectedProfessional = professionalController.selectedProfessional;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _pickDocument(int documentNumber) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          if (documentNumber == 1) {
            _document1 = File(image.path);
          } else {
            _document2 = File(image.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar documento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createAppointment() async {
    if (_selectedService == null) {
      setState(() {
        _errorMessage = 'Por favor, selecione um serviço';
      });
      return;
    }

    if (_selectedProfessional == null) {
      setState(() {
        _errorMessage = 'Por favor, selecione um profissional';
      });
      return;
    }

    if (_selectedDate == null) {
      setState(() {
        _errorMessage = 'Por favor, selecione uma data';
      });
      return;
    }

    if (_selectedTime == null) {
      setState(() {
        _errorMessage = 'Por favor, selecione um horário';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Upload dos documentos se existirem
      String? document1Url;
      String? document2Url;

      if (_document1 != null) {
        document1Url = await userController.uploadDocument(
          _document1!,
          'documento_1_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      if (_document2 != null) {
        document2Url = await userController.uploadDocument(
          _document2!,
          'documento_2_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      // Criar agendamento
      bool success = await userController.createAppointment(
        serviceId: _selectedService!.id,
        serviceName: _selectedService!.name,
        professionalId: _selectedProfessional!.id,
        professionalName: _selectedProfessional!.name,
        date: DateFormat('dd/MM/yyyy').format(_selectedDate!),
        time: _selectedTime!.format(context),
        document1Url: document1Url,
        document2Url: document2Url,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agendamento criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao criar agendamento. Tente novamente.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao criar agendamento: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Agendamento de Serviço',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seleção de Serviço
            const Text(
              'Serviço:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Service>(
                  value: _selectedService,
                  hint: const Text('Selecione um serviço'),
                  isExpanded: true,
                  items: serviceController.services.map((Service service) {
                    return DropdownMenuItem<Service>(
                      value: service,
                      child: Text(service.name),
                    );
                  }).toList(),
                  onChanged: (Service? newValue) {
                    setState(() {
                      _selectedService = newValue;
                    });
                    serviceController.setSelectedService(newValue);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Seleção de Profissional
            const Text(
              'Profissional:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Professional>(
                  value: _selectedProfessional,
                  hint: const Text('Selecione um profissional'),
                  isExpanded: true,
                  items: professionalController.professionals
                      .map((Professional professional) {
                    return DropdownMenuItem<Professional>(
                      value: professional,
                      child: Text(
                          '${professional.name} - ${professional.specialty}'),
                    );
                  }).toList(),
                  onChanged: (Professional? newValue) {
                    setState(() {
                      _selectedProfessional = newValue;
                    });
                    professionalController.setSelectedProfessional(newValue);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Seleção de Data
            const Text(
              'Data:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.grey),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate != null
                          ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                          : 'Selecione uma data',
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            _selectedDate != null ? Colors.black : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Seleção de Horário
            const Text(
              'Horário:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectTime(context),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.grey),
                    const SizedBox(width: 12),
                    Text(
                      _selectedTime != null
                          ? _selectedTime!.format(context)
                          : 'Selecione um horário',
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            _selectedTime != null ? Colors.black : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Upload de Documentos
            const Text(
              'Documentos:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Documento 1
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickDocument(1),
                    icon: const Icon(Icons.upload_file),
                    label: Text(
                        _document1 != null ? 'Documento 1 ✓' : 'Documento 1'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _document1 != null ? Colors.green : Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickDocument(2),
                    icon: const Icon(Icons.upload_file),
                    label: Text(
                        _document2 != null ? 'Documento 2 ✓' : 'Documento 2'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _document2 != null ? Colors.green : Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Mensagem de erro
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),

            // Botão de Confirmar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Confirmar Agendamento'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
