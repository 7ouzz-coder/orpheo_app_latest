const jwt = require('jsonwebtoken');
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

// Middleware para verificar autenticación mediante JWT
module.exports = async (req, res, next) => {
  try {
    // Obtener token del header de autorización
    const authHeader = req.headers.authorization;
    
    if (!authHeader) {
      return res.status(401).json({ message: 'No se proporcionó token de autenticación' });
    }
    
    // El formato típico es "Bearer <token>"
    const token = authHeader.split(' ')[1];
    
    if (!token) {
      return res.status(401).json({ message: 'Formato de token inválido' });
    }
    
    // Verificar y decodificar token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Verificar si el usuario existe y está activo
    const user = await prisma.user.findUnique({
      where: { id: decoded.id },
    });
    
    if (!user || !user.isActive) {
      return res.status(401).json({ message: 'Usuario no válido o inactivo' });
    }
    
    // Añadir información del usuario decodificada a la request para uso posterior
    req.user = {
      id: decoded.id,
      username: decoded.username,
      role: decoded.role,
      grado: decoded.grado,
    };
    
    // Añadir verificación de permisos según el grado del usuario
    // Por ejemplo, un aprendiz solo puede ver contenido de aprendices
    
    // Pasar al siguiente middleware
    next();
  } catch (error) {
    console.error('Error en middleware de autenticación:', error);
    
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({ message: 'Token inválido' });
    }
    
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ message: 'Token expirado' });
    }
    
    res.status(500).json({ message: 'Error interno del servidor' });
  }
};