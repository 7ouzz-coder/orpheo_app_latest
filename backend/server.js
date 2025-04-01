const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const dotenv = require('dotenv');
const { PrismaClient } = require('@prisma/client');

// Cargar variables de entorno
dotenv.config();

// Inicializar prisma
const prisma = new PrismaClient();

// Configurar express
const app = express();
app.use(cors());
app.use(helmet());
app.use(express.json());

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
  res.json({ message: 'API de Orpheo App funcionando correctamente' });
});

// Iniciar servidor
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Servidor ejecutándose en puerto ${PORT}`);
});

// Manejador para cerrar la conexión de Prisma al detener el servidor
process.on('SIGINT', async () => {
  await prisma.$disconnect();
  process.exit(0);
});