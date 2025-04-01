// lib/presentation/pages/documentos/documento_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:orpheo_app/core/di/injection_container.dart';
import 'package:orpheo_app/domain/entities/documento.dart';
import 'package:orpheo_app/presentation/bloc/documentos/documentos_bloc.dart';
import 'package:orpheo_app/presentation/bloc/documentos/documentos_event.dart';
import 'package:orpheo_app/presentation/bloc/documentos/documentos_state.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';

class DocumentoDetailPage extends StatelessWidget {
  final int documentoId;
  
  const DocumentoDetailPage({
    Key? key,
    required this.documentoId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DocumentosBloc>()..add(GetDocumentoDetails(documentoId: documentoId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalle del Documento'),
          actions: [
            BlocBuilder<DocumentosBloc, DocumentosState>(
              builder: (context, state) {
                if (state is DocumentoDetailsLoaded) {
                  return PopupMenuButton<String>(
                    onSelected: (value) {
                      _handleMenuSelection(context, value, state.documento);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<String>(
                        value: 'download',
                        child: ListTile(
                          leading: Icon(Icons.download),
                          title: Text('Descargar'),
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'share',
                        child: ListTile(
                          leading: Icon(Icons.share),
                          title: Text('Compartir'),
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<DocumentosBloc, DocumentosState>(
          builder: (context, state) {
            if (state is DocumentosLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is DocumentosError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<DocumentosBloc>().add(GetDocumentoDetails(documentoId: documentoId));
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }
            
            if (state is DocumentoDetailsLoaded) {
              return _buildDocumentoDetails(context, state.documento);
            }
            
            if (state is DocumentoDownloading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Descargando documento...'),
                  ],
                ),
              );
            }
            
            if (state is DocumentoDownloaded) {
              // Mostrar detalles con mensaje de descarga exitosa
              // Podríamos hacer algo más interesante aquí, como un snackbar o dialog
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    action: SnackBarAction(
                      label: 'Abrir',
                      onPressed: () async {
                        final uri = Uri.file(state.localPath);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No se pudo abrir el archivo')),
                            );
                          }
                        }
                      },
                    ),
                  ),
                );
              });
              
              // Volver a cargar los detalles para mostrar la vista normal
              context.read<DocumentosBloc>().add(GetDocumentoDetails(documentoId: documentoId));
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is DocumentoDeleted) {
              // Mostrar mensaje de eliminación exitosa y volver atrás
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
                
                Navigator.pop(context); // Volver a la lista de documentos
              });
              
              return const Center(child: CircularProgressIndicator());
            }
            
            return const Center(child: Text('Estado no manejado'));
          },
        ),
      ),
    );
  }
  
  void _handleMenuSelection(BuildContext context, String value, Documento documento) {
    switch (value) {
      case 'download':
        context.read<DocumentosBloc>().add(DownloadDocumento(documentoId: documento.id));
        break;
      case 'share':
        // No implementado aún, podríamos usar el paquete share_plus
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compartir no implementado aún')),
        );
        break;
      case 'delete':
        _showDeleteConfirmationDialog(context, documento);
        break;
    }
  }
  
  void _showDeleteConfirmationDialog(BuildContext context, Documento documento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro que desea eliminar el documento "${documento.nombre}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              context.read<DocumentosBloc>().add(DeleteDocumento(documentoId: documento.id));
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDocumentoDetails(BuildContext context, Documento documento) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta principal con información básica
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icono y nombre del documento
                  Row(
                    children: [
                      _getTipoDocumentoIcon(documento.tipo),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          documento.nombre,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  const Divider(),
                  
                  // Categoría e información básica
                  _buildInfoRow('Categoría', _capitalizeFirstLetter(documento.categoria), Icons.folder),
                  
                  if (documento.subcategoria != null && documento.subcategoria!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow('Subcategoría', documento.subcategoria!, Icons.folder_special),
                  ],
                  
                  const SizedBox(height: 12),
                  _buildInfoRow('Tipo', documento.tipo.toUpperCase(), Icons.insert_drive_file),
                  
                  if (documento.tamano != null && documento.tamano!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Tamaño', 
                      _formatFileSize(int.parse(documento.tamano!)), 
                      Icons.data_usage
                    ),
                  ],
                  
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Creado', 
                    dateFormat.format(documento.createdAt), 
                    Icons.calendar_today
                  ),
                  
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Actualizado', 
                    dateFormat.format(documento.updatedAt), 
                    Icons.update
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Descripción si existe
          if (documento.descripcion != null && documento.descripcion!.isNotEmpty)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Descripción',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      documento.descripcion!,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Información sobre autor y subida
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información de Autoría',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  if (documento.autorNombre != null && documento.autorNombre!.isNotEmpty)
                    _buildInfoRow('Autor', documento.autorNombre!, Icons.person),
                  
                  if (documento.subidoPorNombre != null && documento.subidoPorNombre!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow('Subido por', documento.subidoPorNombre!, Icons.upload_file),
                  ],
                ],
              ),
            ),
          ),
          
          // Si es plancha, mostrar información adicional
          if (documento.esPlancha) ...[
            const SizedBox(height: 24),
            
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información de Plancha',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    if (documento.planchaId != null && documento.planchaId!.isNotEmpty)
                      _buildInfoRow('ID de Plancha', documento.planchaId!, Icons.numbers),
                    
                    if (documento.planchaEstado != null && documento.planchaEstado!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.info_outline, size: 20, color: Colors.blue),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Estado',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 2),
                              _getPlanchaEstadoChip(documento.planchaEstado!),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 32),
          
          // Botones de acción
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<DocumentosBloc>().add(DownloadDocumento(documentoId: documento.id));
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Descargar'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                if (documento.url != null && documento.url!.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse(documento.url!);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No se pudo abrir la URL')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.link),
                    label: const Text('Abrir URL'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _getTipoDocumentoIcon(String tipo) {
    IconData iconData;
    Color iconColor;
    
    switch (tipo.toLowerCase()) {
      case 'pdf':
        iconData = Icons.picture_as_pdf;
        iconColor = Colors.red;
        break;
      case 'doc':
      case 'docx':
        iconData = Icons.description;
        iconColor = Colors.blue;
        break;
      case 'xls':
      case 'xlsx':
        iconData = Icons.table_chart;
        iconColor = Colors.green;
        break;
      case 'ppt':
      case 'pptx':
        iconData = Icons.slideshow;
        iconColor = Colors.orange;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
        iconData = Icons.image;
        iconColor = Colors.purple;
        break;
      default:
        iconData = Icons.insert_drive_file;
        iconColor = Colors.grey;
    }
    
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 28,
      ),
    );
  }
  
  Widget _getPlanchaEstadoChip(String estado) {
    Color chipColor;
    String label;
    
    switch (estado.toLowerCase()) {
      case 'aprobada':
        chipColor = Colors.green;
        label = 'Aprobada';
        break;
      case 'rechazada':
        chipColor = Colors.red;
        label = 'Rechazada';
        break;
      case 'pendiente':
      default:
        chipColor = Colors.amber;
        label = 'Pendiente';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: chipColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
  
  String _formatFileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = bytes.toDouble();
    
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }
}