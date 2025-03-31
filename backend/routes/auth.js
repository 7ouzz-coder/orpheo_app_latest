const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const prisma = new PrismaClient();

// Login
router.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;
    
    // Buscar usuario
    const user = await prisma.user.findUnique({
      where: { username },
      include: {
        miembro: true
      }
    });
    
    if (!user) {
      return res.status(401).json({ message: 'Credenciales inválidas' });
    }
    
    // Verificar contraseña
    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) {
      return res.status(401).json({ message: 'Credenciales inválidas' });
    }
    
    // Generar token
    const token = jwt.sign(
      { id: user.id, username: user.username, role: user.role, grado: user.grado },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );
    
    // Devolver respuesta
    res.json({
      success: true,
      message: 'Inicio de sesión exitoso',
      token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        role: user.role,
        grado: user.grado,
        cargo: user.cargo,
        memberFullName: user.memberFullName || (user.miembro ? `${user.miembro.nombres} ${user.miembro.apellidos}` : null),
        miembroId: user.miembroId
      }
    });
    
  } catch (error) {
    console.error('Error en login:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
});

// Registro
router.post('/register', async (req, res) => {
  try {
    const userData = req.body;
    
    // Verificar si el usuario ya existe
    const existingUser = await prisma.user.findUnique({
      where: { username: userData.username }
    });
    
    if (existingUser) {
      return res.status(400).json({ message: 'El nombre de usuario ya está en uso' });
    }
    
    // Hash de la contraseña
    const hashedPassword = await bcrypt.hash(userData.password, 10);
    
    // Crear miembro primero si se proporcionan datos
    let miembroId = null;
    if (userData.nombres && userData.apellidos) {
      const miembro = await prisma.miembro.create({
        data: {
          nombres: userData.nombres,
          apellidos: userData.apellidos,
          rut: userData.rut || '',
          email: userData.email,
          telefono: userData.telefono,
          direccion: userData.direccion,
          profesion: userData.profesion,
          ocupacion: userData.ocupacion,
          fechaNacimiento: userData.fechaNacimiento ? new Date(userData.fechaNacimiento) : null,
          fechaIniciacion: userData.fechaIniciacion ? new Date(userData.fechaIniciacion) : null,
        }
      });
      miembroId = miembro.id;
    }
    
    // Crear usuario
    const user = await prisma.user.create({
      data: {
        username: userData.username,
        password: hashedPassword,
        email: userData.email,
        role: 'general', // Por defecto todos son usuarios generales hasta aprobación
        grado: 'aprendiz', // Por defecto todos son aprendices
        memberFullName: userData.nombres && userData.apellidos 
          ? `${userData.nombres} ${userData.apellidos}` 
          : null,
        miembroId: miembroId
      }
    });
    
    res.status(201).json({
      success: true,
      message: 'Usuario registrado correctamente. Pendiente de aprobación.',
      miembro: { id: miembroId }
    });
    
  } catch (error) {
    console.error('Error en registro:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
});

module.exports = router;