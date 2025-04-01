// lib/presentation/pages/miembros/miembro_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:orpheo_app/core/di/injection_container.dart';
import 'package:orpheo_app/domain/entities/miembro.dart';
import 'package:orpheo_app/presentation/bloc/miembros/miembros_bloc.dart';
import 'package:orpheo_app/presentation/bloc/miembros/miembros_event.dart';
import 'package:orpheo_app/presentation/bloc/miembros/miembros_state.dart';

class MiembroDetailPage extends StatelessWidget {
  final int miembroId;
  
  const MiembroDetailPage({
    Key? key,
    required this.miembroId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MiembrosBloc>()..add(GetMiembroDetails(miembroId: miembroId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalle de Miembro'),
          actions: [
            BlocBuilder<MiembrosBloc, MiembrosState>(
              builder: (context, state) {
                if (state is MiembroDetailsLoaded) {
                  return IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // Navegar a la página de edición del miembro
                      // Por ahora solo mostramos un mensaje
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Función de editar no implementada aún')),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<MiembrosBloc, MiembrosState>(
          builder: (context, state) {
            if (state is MiembrosLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is MiembrosError) {
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
                        context.read<MiembrosBloc>().add(GetMiembroDetails(miembroId: miembroId));
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }
            
            if (state is MiembroDetailsLoaded) {
              return _buildMiembroDetails(context, state.miembro);
            }
            
            return const Center(child: Text('Estado no manejado'));
          },
        ),
      ),
    );
  }
  
  Widget _buildMiembroDetails(BuildContext context, Miembro miembro) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera con información principal
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: _getColorForGrado(miembro.grado),
                    child: Text(
                      miembro.nombres.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    miembro.nombreCompleto,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildGradoChip(miembro.grado),
                      if (miembro.cargo != null && miembro.cargo!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _buildCargoChip(miembro.cargo!),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.badge, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'RUT: ${miembro.rut}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Información de contacto
          _buildSectionCard(
            title: 'Información de Contacto',
            icon: Icons.contact_phone,
            children: [
              _buildInfoRow('Email', miembro.email ?? 'No disponible', Icons.email),
              const SizedBox(height: 12),
              _buildInfoRow('Teléfono', miembro.telefono ?? 'No disponible', Icons.phone),
              const SizedBox(height: 12),
              _buildInfoRow('Dirección', miembro.direccion ?? 'No disponible', Icons.home),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Información profesional
          _buildSectionCard(
            title: 'Información Profesional',
            icon: Icons.work,
            children: [
              _buildInfoRow('Profesión', miembro.profesion ?? 'No disponible', Icons.school),
              const SizedBox(height: 12),
              _buildInfoRow('Ocupación', miembro.ocupacion ?? 'No disponible', Icons.business_center),
              if (miembro.trabajoNombre != null && miembro.trabajoNombre!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildInfoRow('Lugar de Trabajo', miembro.trabajoNombre!, Icons.business),
              ],
              if (miembro.trabajoTelefono != null && miembro.trabajoTelefono!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildInfoRow('Teléfono Laboral', miembro.trabajoTelefono!, Icons.phone_in_talk),
              ],
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Información masónica
          _buildSectionCard(
            title: 'Información Masónica',
            icon: Icons.account_balance,
            children: [
              _buildInfoRow(
                'Fecha de Iniciación',
                miembro.fechaIniciacion != null
                    ? dateFormat.format(miembro.fechaIniciacion!)
                    : 'No disponible',
                Icons.date_range,
              ),
              if (miembro.grado == 'companero' || miembro.grado == 'maestro') ...[
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Fecha de Aumento de Salario',
                  miembro.fechaAumentoSalario != null
                      ? dateFormat.format(miembro.fechaAumentoSalario!)
                      : 'No disponible',
                  Icons.date_range,
                ),
              ],
              if (miembro.grado == 'maestro') ...[
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Fecha de Exaltación',
                  miembro.fechaExaltacion != null
                      ? dateFormat.format(miembro.fechaExaltacion!)
                      : 'No disponible',
                  Icons.date_range,
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Información de emergencia
          if (miembro.contactoEmergenciaNombre != null || miembro.contactoEmergenciaTelefono != null) ...[
            _buildSectionCard(
              title: 'Contacto de Emergencia',
              icon: Icons.emergency,
              children: [
                _buildInfoRow(
                  'Nombre',
                  miembro.contactoEmergenciaNombre ?? 'No disponible',
                  Icons.person,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Teléfono',
                  miembro.contactoEmergenciaTelefono ?? 'No disponible',
                  Icons.phone,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          
          // Información de salud
          if (miembro.situacionSalud != null && miembro.situacionSalud!.isNotEmpty) ...[
            _buildSectionCard(
              title: 'Información de Salud',
              icon: Icons.medical_services,
              children: [
                Text(miembro.situacionSalud!),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
  
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
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
  
  Widget _buildGradoChip(String grado) {
    Color chipColor;
    
    switch (grado.toLowerCase()) {
      case 'maestro':
        chipColor = Colors.blue;
        break;
      case 'compañero':
      case 'companero':
        chipColor = Colors.green;
        break;
      case 'aprendiz':
      default:
        chipColor = Colors.amber;
        break;
    }
    
    return Chip(
      label: Text(_capitalizeFirstLetter(grado)),
      backgroundColor: chipColor.withOpacity(0.2),
      labelStyle: TextStyle(color: chipColor, fontWeight: FontWeight.bold),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
  
  Widget _buildCargoChip(String cargo) {
    return Chip(
      label: Text(_capitalizeFirstLetter(cargo)),
      backgroundColor: Colors.purple.withOpacity(0.2),
      labelStyle: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
  
  Color _getColorForGrado(String grado) {
    switch(grado) {
      case 'maestro':
        return Colors.blue;
      case 'companero':
        return Colors.green;
      case 'aprendiz':
      default:
        return Colors.amber;
    }
  }
  
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}