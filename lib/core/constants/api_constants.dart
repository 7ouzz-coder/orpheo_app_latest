class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // Para emulador Android
  // static const String baseUrl = 'http://localhost:3000/api'; // Para dispositivos iOS

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  
  // Miembros endpoints
  static const String miembros = '/miembros';
  
  // Documentos endpoints
  static const String documentos = '/documentos';
  
  // Programas endpoints
  static const String programas = '/programas';
  
  // Asistencia endpoints
  static const String asistencia = '/asistencia';
  
  // Notificaciones endpoints
  static const String notificaciones = '/notificaciones';
}