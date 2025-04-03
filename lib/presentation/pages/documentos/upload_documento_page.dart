// lib/presentation/pages/documentos/upload_documento_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orpheo_app/core/di/injection_container.dart';
import 'package:orpheo_app/core/utils/document_helper.dart';
import 'package:orpheo_app/presentation/bloc/documentos/documentos_bloc.dart';
import 'package:orpheo_app/presentation/bloc/documentos/documentos_event.dart';
import 'package:orpheo_app/presentation/bloc/documentos/documentos_state.dart';
import 'package:path/path.dart' as path;

class UploadDocumentoPage extends StatefulWidget {
  final String categoria;
  final bool esPlancha;
  
  const UploadDocumentoPage({
    Key? key,
    required this.categoria,
    this.esPlancha = false,
  }) : super(key: key);

  @override
  State<UploadDocumentoPage> createState() => _UploadDocumentoPageState();
}

class _UploadDocumentoPageState extends State<UploadDocumentoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  
  FileInfo? _selectedFile;
  
  String _categoria = 'aprendiz';
  String? _subcategoria;
  String _planchaEstado = 'pendiente';
  
  @override
  void initState() {
    super.initState();
    _categoria = widget.categoria;
  }
  
  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }
  
  Future<void> _pickFile() async {
    FileInfo? fileInfo = await DocumentHelper.pickDocument(
      context: context,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'jpg', 'jpeg', 'png', 'txt'],
      title: 'Seleccionar ${widget.esPlancha ? 'plancha' : 'documento'}',
    );
    
    if (fileInfo != null) {
      setState(() {
        _selectedFile = fileInfo;
        
        // Autocompletar el nombre si está vacío
        if (_nombreController.text.isEmpty) {
          _nombreController.text = fileInfo.name;
        }
      });
    }
  }
  
  void _onSubmit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (_selectedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor seleccione un archivo')),
        );
        return;
      }
      
      // Preparar los datos del documento
      final documentoData = {
        'nombre': _nombreController.text,
        'descripcion': _descripcionController.text,
        'categoria': _categoria,
        'subcategoria': _subcategoria,
        'esPlancha': widget.esPlancha.toString(),
      };
      
      if (widget.esPlancha) {
        documentoData['planchaEstado'] = _planchaEstado;
      }
      
      // Disparar evento para subir documento
      context.read<DocumentosBloc>().add(
        UploadDocumento(
          documentoData: documentoData, 
          filePath: _selectedFile!.path,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DocumentosBloc>(),
      child: BlocConsumer<DocumentosBloc, DocumentosState>(
        listener: (context, state) {
          if (state is DocumentoUploaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.pop(context);
          } else if (state is DocumentosError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Subir ${widget.esPlancha ? 'Plancha' : 'Documento'}'),
            ),
            body: state is DocumentoUploading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sección para seleccionar archivo
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Archivo',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  if (_selectedFile != null) ...[
                                    // Mostrar información del archivo seleccionado
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.blue.shade100),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            _getIconForFileType(_selectedFile!.extension),
                                            color: _getColorForFileType(_selectedFile!.extension),
                                            size: 32,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _selectedFile!.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Tipo: ${_selectedFile!.extension.toUpperCase()} - Tamaño: ${_selectedFile!.formattedSize}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () {
                                              setState(() {
                                                _selectedFile = null;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  
                                  ElevatedButton.icon(
                                    onPressed: _pickFile,
                                    icon: const Icon(Icons.attach_file),
                                    label: Text(_selectedFile == null 
                                        ? 'Seleccionar Archivo' 
                                        : 'Cambiar Archivo'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Información del documento
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Información',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  TextFormField(
                                    controller: _nombreController,
                                    decoration: const InputDecoration(
                                      labelText: 'Nombre *',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor ingrese un nombre';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  TextFormField(
                                    controller: _descripcionController,
                                    decoration: const InputDecoration(
                                      labelText: 'Descripción',
                                      border: OutlineInputBorder(),
                                    ),
                                    maxLines: 3,
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Dropdown para la categoría
                                  DropdownButtonFormField<String>(
                                    value: _categoria,
                                    decoration: const InputDecoration(
                                      labelText: 'Categoría *',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'aprendiz',
                                        child: Text('Aprendiz'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'companero',
                                        child: Text('Compañero'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'maestro',
                                        child: Text('Maestro'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'general',
                                        child: Text('General'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _categoria = value!;
                                      });
                                    },
                                  ),
                                  
                                  // Si es plancha, mostrar opciones adicionales
                                  if (widget.esPlancha) ...[
                                    const SizedBox(height: 16),
                                    
                                    DropdownButtonFormField<String>(
                                      value: _planchaEstado,
                                      decoration: const InputDecoration(
                                        labelText: 'Estado de Plancha',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'pendiente',
                                          child: Text('Pendiente'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'aprobada',
                                          child: Text('Aprobada'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'rechazada',
                                          child: Text('Rechazada'),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _planchaEstado = value!;
                                        });
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () => _onSubmit(context),
                              child: const Text('Subir Documento'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
  
  IconData _getIconForFileType(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }
  
  Color _getColorForFileType(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}