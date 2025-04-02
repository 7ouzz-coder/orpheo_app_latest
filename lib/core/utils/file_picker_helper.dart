// lib/core/utils/file_picker_helper.dart

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class FilePickerHelper {
  /// Intenta seleccionar un archivo utilizando file_picker
  /// Si falla, intenta usar image_picker como alternativa
  /// Devuelve la ruta del archivo seleccionado o null si no se seleccionó ninguno
  static Future<String?> pickFile({
    required BuildContext context,
    List<String>? allowedExtensions,
    String dialogTitle = 'Seleccionar archivo',
  }) async {
    try {
      // Intenta usar file_picker primero
      final result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        dialogTitle: dialogTitle,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.single.path;
      } else {
        return null; // Usuario canceló la selección
      }
    } catch (e) {
      print('Error con file_picker: $e');
      
      // Si estamos en modo debug o mobile, intentamos con image_picker
      if (Platform.isAndroid || Platform.isIOS) {
        return _pickWithImagePicker(context, allowedExtensions);
      } else {
        // Muestra un error si estamos en otra plataforma
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al seleccionar archivo: $e')),
          );
        }
        return null;
      }
    }
  }

  /// Implementación de respaldo usando image_picker
  static Future<String?> _pickWithImagePicker(
    BuildContext context,
    List<String>? allowedExtensions,
  ) async {
    try {
      // Determinar si estamos buscando una imagen o un documento
      bool isImagePick = allowedExtensions == null 
          ? false 
          : allowedExtensions.any((ext) => ['jpg', 'jpeg', 'png'].contains(ext.toLowerCase()));

      if (isImagePick) {
        // Selector de imágenes
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
        
        if (image != null) {
          return image.path;
        }
      } else {
        // Para documentos, intentamos con pickVideo (aunque no sea video, algunos archivos son detectables)
        final ImagePicker picker = ImagePicker();
        final XFile? file = await picker.pickVideo(source: ImageSource.gallery);
        
        if (file != null) {
          // Verificar la extensión si hay restricciones
          if (allowedExtensions != null) {
            String ext = path.extension(file.path).replaceAll('.', '').toLowerCase();
            if (!allowedExtensions.contains(ext)) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tipo de archivo no permitido: $ext. Permitidos: ${allowedExtensions.join(", ")}')),
                );
              }
              return null;
            }
          }
          return file.path;
        }
      }
      
      return null;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar archivo con image_picker: $e')),
        );
      }
      return null;
    }
  }
  
  /// Método simplificado para seleccionar documentos
  static Future<String?> pickDocument(BuildContext context) {
    return pickFile(
      context: context,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'],
      dialogTitle: 'Seleccionar documento',
    );
  }
  
  /// Método simplificado para seleccionar imágenes
  static Future<String?> pickImage(BuildContext context) {
    return pickFile(
      context: context,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      dialogTitle: 'Seleccionar imagen',
    );
  }
}