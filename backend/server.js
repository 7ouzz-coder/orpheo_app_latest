const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const dotenv = require('dotenv');
const { PrismaClient } = require('@prisma/client');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');

// Cargar variables de entorno
dotenv.config();

// Inicializar prisma
const prisma = new PrismaClient();

// Configurar express
const app = express();

// Middlewares de seguridad y utilidad
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*', // En producción, especificar orígenes permitidos
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

app.use(helmet()); // Seguridad para cabeceras HTTP
app.use(express.json({ limit: '10mb' })); // Limitar tamaño de solicitudes JSON
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Logger en desarrollo
if (process.env.NODE_ENV !== 'production') {
  app.use(morgan('dev'));
}

// Rate limiting para prevenir abusos
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 100, // Limitar cada IP a 100 solicitudes por ventana
  standardHeaders: true,
  legacyHeaders: false,
  message: { message: 'Demasiadas solicitudes, por favor intente más tarde' },
});

// Aplicar rate limiting a todas las rutas de la API
app.use('/api', apiLimiter);

// Middleware personalizado para manejo centralizado de errores
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Error interno del servidor' });
});

// Routes
const authRoutes = require('./routes/auth');
const miembrosRoutes = require('./routes/miembros');
const documentosRoutes = require('./routes/documentos');
//const programasRoutes = require('./routes/programas');
//const asistenciaRoutes = require('./routes/asistencia');
//const notificacionesRoutes = require('./routes/notificaciones');

// Usar rutas
app.use('/api/auth', authRoutes);
app.use('/api/miembros', miembrosRoutes);
app.use('/api/documentos', documentosRoutes);
//app.use('/api/programas', programasRoutes);
//app.use('/api/asistencia', asistenciaRoutes);
//app.use('/api/notificaciones', notificacionesRoutes);

// Ruta para comprobar que el servidor está funcionando
app.get('/', (req, res) => {
  res.json({ 
    message: 'API de Orpheo App funcionando correctamente',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

// Middleware para manejar rutas no encontradas
app.use((req, res) => {
  res.status(404).json({ message: 'Ruta no encontrada' });
});

// Iniciar servidor
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Servidor ejecutándose en puerto ${PORT}`);
  console.log(`Ambiente: ${process.env.NODE_ENV || 'desarrollo'}`);
});

// Manejador para cerrar la conexión de Prisma al detener el servidor
process.on('SIGINT', async () => {
  console.log('Cerrando servidor...');
  await prisma.$disconnect();
  process.exit(0);
});

// Manejar excepciones no capturadas
process.on('uncaughtException', (err) => {
  console.error('Excepción no capturada:', err);
  process.exit(1);
});

// Manejar rechazos de promesas no capturados
process.on('unhandledRejection', (reason, promise) => {
  console.error('Rechazo de promesa no capturado:', reason);
});