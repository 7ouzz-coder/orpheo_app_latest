// lib/core/utils/document_helper.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class DocumentHelper {
  /// Selecciona un documento o imagen usando image_picker
  static Future<FileInfo?> pickDocument({
    required BuildContext context,
    List<String>? allowedExtensions,
    bool imageOnly = false,
    String title = 'Seleccionar archivo',
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      XFile? pickedFile;
      
      // Mostrar diálogo para elegir entre cámara y galería si es imagen
      if (imageOnly) {
        await _showSourceDialog(context, title, (source) async {
          if (source == ImageSource.camera) {
            pickedFile = await picker.pickImage(source: ImageSource.camera);
          } else {
            pickedFile = await picker.pickImage(source: ImageSource.gallery);
          }
        });
      } else {
        // Para documentos, intentar con pickImage de galería 
        // (algunos documentos pueden aparecer en la galería)
        pickedFile = await picker.pickImage(source: ImageSource.gallery);
      }
      
      if (pickedFile != null) {
        // Verificar extensión si hay restricciones
        if (allowedExtensions != null && allowedExtensions.isNotEmpty) {
          String fileExt = path.extension(pickedFile!.path).replaceAll('.', '').toLowerCase();
          
          // Si la extensión no está en la lista permitida
          if (!allowedExtensions.contains(fileExt)) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tipo de archivo no permitido: $fileExt. Permitidos: ${allowedExtensions.join(", ")}')),
              );
            }
            return null;
          }
        }
        
        final File file = File(pickedFile!.path);
        final String filename = path.basename(pickedFile!.path);
        final String extension = path.extension(pickedFile!.path).replaceAll('.', '').toLowerCase();
        final int fileSize = await file.length();
        
        return FileInfo(
          file: file,
          name: filename,
          extension: extension,
          size: fileSize,
          path: pickedFile!.path,
        );
      }
      
      return null;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar archivo: $e')),
        );
      }
      return null;
    }
  }
  
  /// Muestra un diálogo para elegir la fuente de la imagen
  static Future<void> _showSourceDialog(
    BuildContext context, 
    String title, 
    Future<void> Function(ImageSource source) onSourceSelected
  ) async {
    ImageSource? source;
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text('Seleccione la fuente'),
        actions: [
          TextButton(
            onPressed: () {
              source = ImageSource.camera;
              Navigator.pop(context);
            },
            child: const Text('Cámara'),
          ),
          TextButton(
            onPressed: () {
              source = ImageSource.gallery;
              Navigator.pop(context);
            },
            child: const Text('Galería'),
          ),
        ],
      ),
    );
    
    if (source != null) {
      await onSourceSelected(source!);
    }
  }

  /// Abre un archivo usando el visor predeterminado del sistema
  static Future<void> openFile(String filePath, {BuildContext? context}) async {
    try {
      final result = await OpenFile.open(filePath);
      
      if (result.type != ResultType.done && context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al abrir archivo: ${result.message}')),
        );
      }
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al abrir archivo: $e')),
        );
      }
    }
  }

  /// Formatea el tamaño del archivo en una cadena legible
  static String formatFileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = bytes.toDouble();
    
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }
  
  /// Verifica si se puede abrir una URL
  static Future<bool> canLaunchUrl(Uri uri) async {
    return await url_launcher.canLaunchUrl(uri);
  }
  
  /// Abre una URL
  static Future<bool> launchUrl(Uri uri, {url_launcher.LaunchMode? mode}) async {
    return await url_launcher.launchUrl(
      uri, 
      mode: mode ?? url_launcher.LaunchMode.platformDefault
    );
  }
}

/// Clase para almacenar la información del archivo seleccionado
class FileInfo {
  final File file;
  final String name;
  final String extension;
  final int size;
  final String path;
  
  FileInfo({
    required this.file,
    required this.name,
    required this.extension,
    required this.size,
    required this.path,
  });
  
  String get formattedSize => DocumentHelper.formatFileSize(size);
}