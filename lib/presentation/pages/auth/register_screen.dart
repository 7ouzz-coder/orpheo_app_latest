// lib/presentation/pages/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:orpheo_app/core/utils/document_helper.dart';
import 'package:orpheo_app/data/datasources/remote/auth_remote_datasource.dart';
import 'package:intl/intl.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers para identificación personal
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _rutController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();
  
  // Controllers para contacto
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  
  // Controllers para información familiar
  final _parejaNombreController = TextEditingController();
  final _parejaTelefonoController = TextEditingController();
  final _parejaCumpleanosController = TextEditingController();
  
  // Controllers para información profesional
  final _profesionController = TextEditingController();
  final _trabajoNombreController = TextEditingController();
  final _trabajoCargoController = TextEditingController();
  final _trabajoDireccionController = TextEditingController();
  final _trabajoEmailController = TextEditingController();
  final _trabajoTelefonoController = TextEditingController();
  
  // Controllers para información del taller
  final _fechaIniciacionController = TextEditingController();
  final _cargoController = TextEditingController();
  final _contactoEmergenciaNombreController = TextEditingController();
  final _contactoEmergenciaTelefonoController = TextEditingController();
  final _situacionSaludController = TextEditingController();
  
  // Controllers para credenciales
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _currentStep = 0;
  
  // Variable para documento seleccionado (simulación sin file_picker)
  bool _hasSelectedDocument = false;
  String _selectedDocumentName = "";
  
  @override
  void dispose() {
    // Dispose de todos los controllers
    _nombresController.dispose();
    _apellidosController.dispose();
    _rutController.dispose();
    _fechaNacimientoController.dispose();
    
    _emailController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    
    _parejaNombreController.dispose();
    _parejaTelefonoController.dispose();
    _parejaCumpleanosController.dispose();
    
    _profesionController.dispose();
    _trabajoNombreController.dispose();
    _trabajoCargoController.dispose();
    _trabajoDireccionController.dispose();
    _trabajoEmailController.dispose();
    _trabajoTelefonoController.dispose();
    
    _fechaIniciacionController.dispose();
    _cargoController.dispose();
    _contactoEmergenciaNombreController.dispose();
    _contactoEmergenciaTelefonoController.dispose();
    _situacionSaludController.dispose();
    
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    
    super.dispose();
  }
  
  // Método para simular selección de documento
  void _pickDocument() async {
    final fileInfo = await DocumentHelper.pickDocument(
      context: context,
      allowedExtensions: ['pdf'],
      title: 'Seleccionar solicitud firmada',
    );
    
    if (fileInfo != null) {
      setState(() {
        _hasSelectedDocument = true;
        _selectedDocumentName = fileInfo.name;
      });
    }
  }
  
  // Método para seleccionar una fecha
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime now = DateTime.now();
    DateTime initialDate = now;
    
    try {
      if (controller.text.isNotEmpty) {
        initialDate = DateFormat('dd/MM/yyyy').parse(controller.text);
      }
    } catch (e) {
      // Si hay error al parsear, usar la fecha actual
      initialDate = now;
    }
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }
  
  // Validar el paso actual antes de continuar
  bool _validateStep() {
    switch (_currentStep) {
      case 0: // Identificación
        return _validateIdentificacionForm();
      case 1: // Contacto
        return _validateContactoForm();
      case 2: // Familiar (opcional)
        return true;
      case 3: // Profesional
        return _validateProfesionalForm();
      case 4: // Taller
        return true;
      case 5: // Credenciales y documento
        return _validateCredencialesForm();
      default:
        return false;
    }
  }
  
  bool _validateIdentificacionForm() {
    if (_nombresController.text.trim().isEmpty) {
      _showErrorSnackBar('Por favor ingrese sus nombres');
      return false;
    }
    if (_apellidosController.text.trim().isEmpty) {
      _showErrorSnackBar('Por favor ingrese sus apellidos');
      return false;
    }
    if (_rutController.text.trim().isEmpty) {
      _showErrorSnackBar('Por favor ingrese su RUT');
      return false;
    }
    return true;
  }
  
  bool _validateContactoForm() {
    if (_emailController.text.trim().isEmpty) {
      _showErrorSnackBar('Por favor ingrese su correo electrónico');
      return false;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text.trim())) {
      _showErrorSnackBar('Por favor ingrese un correo electrónico válido');
      return false;
    }
    if (_telefonoController.text.trim().isEmpty) {
      _showErrorSnackBar('Por favor ingrese su número de teléfono');
      return false;
    }
    return true;
  }
  
  bool _validateProfesionalForm() {
    if (_profesionController.text.trim().isEmpty) {
      _showErrorSnackBar('Por favor indique su profesión');
      return false;
    }
    return true;
  }
  
  bool _validateCredencialesForm() {
    if (_usernameController.text.trim().isEmpty) {
      _showErrorSnackBar('Por favor ingrese un nombre de usuario');
      return false;
    }
    if (_passwordController.text.isEmpty) {
      _showErrorSnackBar('Por favor ingrese una contraseña');
      return false;
    }
    if (_passwordController.text.length < 6) {
      _showErrorSnackBar('La contraseña debe tener al menos 6 caracteres');
      return false;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar('Las contraseñas no coinciden');
      return false;
    }
    if (!_hasSelectedDocument) {
      _showErrorSnackBar('Debe adjuntar la solicitud firmada por el secretario');
      return false;
    }
    return true;
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  
  // Enviar formulario completo
  Future<void> _register() async {
    if (!_validateStep()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final client = http.Client();
      final authRemoteDataSource = AuthRemoteDataSource(client: client);
      
      // Preparar el mapa de datos para el registro
      final userData = {
        'nombres': _nombresController.text,
        'apellidos': _apellidosController.text,
        'rut': _rutController.text,
        'email': _emailController.text,
        'telefono': _telefonoController.text,
        'direccion': _direccionController.text,
        'profesion': _profesionController.text,
        'username': _usernameController.text,
        'password': _passwordController.text,
      };
      
      // Enviar los datos al servidor
      final response = await authRemoteDataSource.register(userData);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Mostrar mensaje de éxito y volver a la pantalla de login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
        
        // Volver a la pantalla de login después de un breve tiempo
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error en el registro: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Stepper(
            type: StepperType.horizontal,
            currentStep: _currentStep,
            onStepTapped: (step) {
              // Solo permitir ir a pasos anteriores directamente
              if (step < _currentStep) {
                setState(() {
                  _currentStep = step;
                });
              }
            },
            onStepContinue: () {
              bool isLastStep = _currentStep == 5; // 6 pasos en total (0-5)
              
              if (isLastStep) {
                _register();
              } else if (_validateStep()) {
                setState(() {
                  _currentStep += 1;
                });
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() {
                  _currentStep -= 1;
                });
              }
            },
            steps: [
              // Paso 1: Información personal
              Step(
                title: const Text('Datos Personales'),
                content: Column(
                  children: [
                    TextFormField(
                      controller: _nombresController,
                      decoration: const InputDecoration(
                        labelText: 'Nombres *',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese sus nombres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _apellidosController,
                      decoration: const InputDecoration(
                        labelText: 'Apellidos *',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese sus apellidos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _rutController,
                      decoration: const InputDecoration(
                        labelText: 'RUT *',
                        prefixIcon: Icon(Icons.badge),
                        border: OutlineInputBorder(),
                        hintText: 'Ej: 12345678-9',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su RUT';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _fechaNacimientoController,
                      decoration: InputDecoration(
                        labelText: 'Fecha de Nacimiento',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_month),
                          onPressed: () => _selectDate(context, _fechaNacimientoController),
                        ),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context, _fechaNacimientoController),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '* Campos obligatorios',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                isActive: _currentStep >= 0,
                state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              ),
              
              // Paso 2: Información de contacto
              Step(
                title: const Text('Contacto'),
                content: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Correo Electrónico *',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su correo electrónico';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Por favor ingrese un correo electrónico válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _telefonoController,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono Móvil *',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                        hintText: '+56 9 1234 5678',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su número de teléfono';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _direccionController,
                      decoration: const InputDecoration(
                        labelText: 'Dirección',
                        prefixIcon: Icon(Icons.home),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '* Campos obligatorios',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                isActive: _currentStep >= 1,
                state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              ),
              
              // Paso 3: Información familiar
              Step(
                title: const Text('Familiar'),
                content: Column(
                  children: [
                    TextFormField(
                      controller: _parejaNombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de Cónyuge/Pareja',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _parejaTelefonoController,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono de Contacto',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _parejaCumpleanosController,
                      decoration: InputDecoration(
                        labelText: 'Cumpleaños',
                        prefixIcon: const Icon(Icons.cake),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_month),
                          onPressed: () => _selectDate(context, _parejaCumpleanosController),
                        ),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context, _parejaCumpleanosController),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Todos los campos son opcionales',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                isActive: _currentStep >= 2,
                state: _currentStep > 2 ? StepState.complete : StepState.indexed,
              ),
              
              // Paso 4: Información profesional
              Step(
                title: const Text('Profesional'),
                content: Column(
                  children: [
                    TextFormField(
                      controller: _profesionController,
                      decoration: const InputDecoration(
                        labelText: 'Profesión *',
                        prefixIcon: Icon(Icons.work),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor indique su profesión';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _trabajoNombreController,
                      decoration: const InputDecoration(
                        labelText: 'Lugar de Trabajo',
                        prefixIcon: Icon(Icons.business),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _trabajoCargoController,
                      decoration: const InputDecoration(
                        labelText: 'Cargo',
                        prefixIcon: Icon(Icons.assignment_ind),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '* Campos obligatorios',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                isActive: _currentStep >= 3,
                state: _currentStep > 3 ? StepState.complete : StepState.indexed,
              ),
              
              // Paso 5: Información del taller
              Step(
                title: const Text('Taller'),
                content: Column(
                  children: [
                    TextFormField(
                      controller: _fechaIniciacionController,
                      decoration: InputDecoration(
                        labelText: 'Fecha de Iniciación',
                        prefixIcon: const Icon(Icons.date_range),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_month),
                          onPressed: () => _selectDate(context, _fechaIniciacionController),
                        ),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context, _fechaIniciacionController),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cargoController,
                      decoration: const InputDecoration(
                        labelText: 'Cargo',
                        prefixIcon: Icon(Icons.assignment_ind),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _situacionSaludController,
                      decoration: const InputDecoration(
                        labelText: 'Situación de Salud',
                        prefixIcon: Icon(Icons.medical_services),
                        border: OutlineInputBorder(),
                        hintText: 'Indique alergias, condiciones médicas, etc.',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
                isActive: _currentStep >= 4,
                state: _currentStep > 4 ? StepState.complete : StepState.indexed,
              ),
              
              // Paso 6: Credenciales y documento
              Step(
                title: const Text('Credenciales'),
                content: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de Usuario *',
                        prefixIcon: Icon(Icons.account_circle),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese un nombre de usuario';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña *',
                        prefixIcon: const Icon(Icons.lock),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese una contraseña';
                        }
                        if (value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirmar Contraseña *',
                        prefixIcon: const Icon(Icons.lock),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor confirme su contraseña';
                        }
                        if (value != _passwordController.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Documento de solicitud (simulación)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Documento de Solicitud *',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          const Text(
                            'Adjunte su solicitud con la firma del secretario (formato PDF)',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Botón para seleccionar documento
                          ElevatedButton.icon(
                            onPressed: _pickDocument,
                            icon: const Icon(Icons.attach_file),
                            label: const Text('Seleccionar Documento'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade50,
                              foregroundColor: Colors.blue,
                              side: BorderSide(color: Colors.blue),
                            ),
                          ),
                          
                          if (_hasSelectedDocument) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Colors.green),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Documento seleccionado: $_selectedDocumentName',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const Text(
                                          'Tamaño: 215.42 KB',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _hasSelectedDocument = false;
                                        _selectedDocumentName = "";
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    const Text(
                      '* Campos obligatorios',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                isActive: _currentStep >= 5,
                state: _currentStep > 5 ? StepState.complete : StepState.indexed,
              ),
            ],
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: _isLoading ? null : details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading && _currentStep == 5
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(_currentStep == 5 ? 'Registrar' : 'Continuar'),
                    ),
                    if (_currentStep > 0) ...[
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Atrás'),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}