// lib/core/network/network_info.dart

import 'package:connectivity_plus/connectivity_plus.dart';

/// Interfaz para verificar el estado de la conexión a internet
abstract class NetworkInfo {
  /// Verifica si el dispositivo está conectado a internet
  Future<bool> get isConnected;
  
  /// Obtiene el tipo de conexión actual
  Future<ConnectivityResult> get connectionType;
  
  /// Escucha los cambios en la conectividad
  Stream<ConnectivityResult> get onConnectivityChanged;
}

/// Implementación de [NetworkInfo] utilizando el paquete connectivity_plus
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl({required this.connectivity});

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
  
  @override
  Future<ConnectivityResult> get connectionType async {
    return await connectivity.checkConnectivity();
  }
  
  @override
  Stream<ConnectivityResult> get onConnectivityChanged {
    return connectivity.onConnectivityChanged;
  }
}