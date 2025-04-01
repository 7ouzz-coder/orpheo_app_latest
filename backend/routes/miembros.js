const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

// Obtener todos los miembros
router.get('/', async (req, res) => {
  try {
    // Obtener parámetros de consulta
    const { grado, vigente } = req.query;
    
    // Construir filtro
    const where = {};
    if (grado && grado !== 'todos') {
      where.grado = grado;
    }
    
    if (vigente !== undefined) {
      where.vigente = vigente === 'true';
    }
    
    // Obtener miembros con filtros
    const miembros = await prisma.miembro.findMany({
      where,
      orderBy: {
        apellidos: 'asc',
      },
    });
    
    res.json(miembros);
  } catch (error) {
    console.error('Error al obtener miembros:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
});

// Búsqueda de miembros
router.get('/search', async (req, res) => {
  try {
    const { query, grado } = req.query;
    
    if (!query) {
      return res.status(400).json({ message: 'Parámetro de búsqueda requerido' });
    }
    
    // Construir condición de búsqueda
    const searchCondition = {
      OR: [
        { nombres: { contains: query, mode: 'insensitive' } },
        { apellidos: { contains: query, mode: 'insensitive' } },
        { email: { contains: query, mode: 'insensitive' } },
        { rut: { contains: query, mode: 'insensitive' } },
      ],
    };
    
    // Añadir filtro por grado si se proporciona
    if (grado && grado !== 'todos') {
      searchCondition.AND = { grado };
    }
    
    const miembros = await prisma.miembro.findMany({
      where: searchCondition,
      orderBy: {
        apellidos: 'asc',
      },
    });
    
    res.json(miembros);
  } catch (error) {
    console.error('Error en búsqueda de miembros:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
});

// Obtener miembros por grado
router.get('/grado/:grado', async (req, res) => {
  try {
    const { grado } = req.params;
    
    const miembros = await prisma.miembro.findMany({
      where: { grado },
      orderBy: {
        apellidos: 'asc',
      },
    });
    
    res.json(miembros);
  } catch (error) {
    console.error('Error al obtener miembros por grado:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
});

// Obtener un miembro por ID
router.get('/:id', async (req, res) => {
  try {
    const miembro = await prisma.miembro.findUnique({
      where: { id: parseInt(req.params.id) }
    });
    
    if (!miembro) {
      return res.status(404).json({ message: 'Miembro no encontrado' });
    }
    
    res.json(miembro);
  } catch (error) {
    console.error('Error al obtener miembro:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
});

// Crear un nuevo miembro
router.post('/', async (req, res) => {
  try {
    // Validar datos obligatorios
    const { nombres, apellidos, rut, grado } = req.body;
    
    if (!nombres || !apellidos || !rut) {
      return res.status(400).json({ message: 'Nombre, apellidos y RUT son campos obligatorios' });
    }
    
    // Verificar si ya existe un miembro con el mismo RUT
    const existingMiembro = await prisma.miembro.findUnique({
      where: { rut },
    });
    
    if (existingMiembro) {
      return res.status(400).json({ message: 'Ya existe un miembro con este RUT' });
    }
    
    // Crear miembro
    const miembro = await prisma.miembro.create({
      data: {
        nombres,
        apellidos,
        rut,
        grado: grado || 'aprendiz',
        // Datos opcionales
        cargo: req.body.cargo,
        vigente: req.body.vigente !== undefined ? req.body.vigente : true,
        email: req.body.email,
        telefono: req.body.telefono,
        direccion: req.body.direccion,
        profesion: req.body.profesion,
        ocupacion: req.body.ocupacion,
        trabajoNombre: req.body.trabajoNombre,
        trabajoDireccion: req.body.trabajoDireccion,
        trabajoTelefono: req.body.trabajoTelefono,
        trabajoEmail: req.body.trabajoEmail,
        parejaNombre: req.body.parejaNombre,
        parejaTelefono: req.body.parejaTelefono,
        contactoEmergenciaNombre: req.body.contactoEmergenciaNombre,
        contactoEmergenciaTelefono: req.body.contactoEmergenciaTelefono,
        fechaNacimiento: req.body.fechaNacimiento ? new Date(req.body.fechaNacimiento) : null,
        fechaIniciacion: req.body.fechaIniciacion ? new Date(req.body.fechaIniciacion) : null,
        fechaAumentoSalario: req.body.fechaAumentoSalario ? new Date(req.body.fechaAumentoSalario) : null,
        fechaExaltacion: req.body.fechaExaltacion ? new Date(req.body.fechaExaltacion) : null,
        situacionSalud: req.body.situacionSalud,
      },
    });
    
    res.status(201).json(miembro);
  } catch (error) {
    console.error('Error al crear miembro:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
});

// Actualizar un miembro
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    // Verificar si el miembro existe
    const existingMiembro = await prisma.miembro.findUnique({
      where: { id: parseInt(id) },
    });
    
    if (!existingMiembro) {
      return res.status(404).json({ message: 'Miembro no encontrado' });
    }
    
    // Si se actualiza el RUT, verificar que no exista otro miembro con el mismo RUT
    if (req.body.rut && req.body.rut !== existingMiembro.rut) {
      const rutExists = await prisma.miembro.findUnique({
        where: { rut: req.body.rut },
      });
      
      if (rutExists) {
        return res.status(400).json({ message: 'Ya existe un miembro con este RUT' });
      }
    }
    
    // Crear objeto con datos a actualizar
    const updateData = {};
    
    // Campos básicos
    if (req.body.nombres !== undefined) updateData.nombres = req.body.nombres;
    if (req.body.apellidos !== undefined) updateData.apellidos = req.body.apellidos;
    if (req.body.rut !== undefined) updateData.rut = req.body.rut;
    if (req.body.grado !== undefined) updateData.grado = req.body.grado;
    if (req.body.cargo !== undefined) updateData.cargo = req.body.cargo;
    if (req.body.vigente !== undefined) updateData.vigente = req.body.vigente;
    
    // Contacto
    if (req.body.email !== undefined) updateData.email = req.body.email;
    if (req.body.telefono !== undefined) updateData.telefono = req.body.telefono;
    if (req.body.direccion !== undefined) updateData.direccion = req.body.direccion;
    
    // Profesional
    if (req.body.profesion !== undefined) updateData.profesion = req.body.profesion;
    if (req.body.ocupacion !== undefined) updateData.ocupacion = req.body.ocupacion;
    if (req.body.trabajoNombre !== undefined) updateData.trabajoNombre = req.body.trabajoNombre;
    if (req.body.trabajoDireccion !== undefined) updateData.trabajoDireccion = req.body.trabajoDireccion;
    if (req.body.trabajoTelefono !== undefined) updateData.trabajoTelefono = req.body.trabajoTelefono;
    if (req.body.trabajoEmail !== undefined) updateData.trabajoEmail = req.body.trabajoEmail;
    
    // Familiar
    if (req.body.parejaNombre !== undefined) updateData.parejaNombre = req.body.parejaNombre;
    if (req.body.parejaTelefono !== undefined) updateData.parejaTelefono = req.body.parejaTelefono;
    if (req.body.contactoEmergenciaNombre !== undefined) updateData.contactoEmergenciaNombre = req.body.contactoEmergenciaNombre;
    if (req.body.contactoEmergenciaTelefono !== undefined) updateData.contactoEmergenciaTelefono = req.body.contactoEmergenciaTelefono;
    
    // Fechas
    if (req.body.fechaNacimiento !== undefined) updateData.fechaNacimiento = req.body.fechaNacimiento ? new Date(req.body.fechaNacimiento) : null;
    if (req.body.fechaIniciacion !== undefined) updateData.fechaIniciacion = req.body.fechaIniciacion ? new Date(req.body.fechaIniciacion) : null;
    if (req.body.fechaAumentoSalario !== undefined) updateData.fechaAumentoSalario = req.body.fechaAumentoSalario ? new Date(req.body.fechaAumentoSalario) : null;
    if (req.body.fechaExaltacion !== undefined) updateData.fechaExaltacion = req.body.fechaExaltacion ? new Date(req.body.fechaExaltacion) : null;
    
    // Salud
    if (req.body.situacionSalud !== undefined) updateData.situacionSalud = req.body.situacionSalud;
    
    // Actualizar miembro
    const miembro = await prisma.miembro.update({
      where: { id: parseInt(id) },
      data: updateData,
    });
    
    res.json(miembro);
  } catch (error) {
    console.error('Error al actualizar miembro:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
});

// Eliminar un miembro
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    // Verificar si el miembro existe
    const existingMiembro = await prisma.miembro.findUnique({
      where: { id: parseInt(id) },
    });
    
    if (!existingMiembro) {
      return res.status(404).json({ message: 'Miembro no encontrado' });
    }
    
    // Verificar si hay usuario asociado
    const user = await prisma.user.findUnique({
      where: { miembroId: parseInt(id) },
    });
    
    if (user) {
      return res.status(400).json({ 
        message: 'No se puede eliminar el miembro porque tiene un usuario asociado',
        suggestion: 'Si desea desactivar el miembro, utilice la función de actualización y cambie el estado "vigente" a false'
      });
    }
    
    // Eliminar miembro
    await prisma.miembro.delete({
      where: { id: parseInt(id) },
    });
    
    res.json({ message: 'Miembro eliminado correctamente' });
  } catch (error) {
    console.error('Error al eliminar miembro:', error);
    
    // Manejo de errores específicos de Prisma
    if (error.code === 'P2003') {
      return res.status(400).json({ 
        message: 'No se puede eliminar el miembro porque tiene registros asociados',
        suggestion: 'Si desea desactivar el miembro, utilice la función de actualización y cambie el estado "vigente" a false'
      });
    }
    
    res.status(500).json({ message: 'Error interno del servidor' });
  }
});

module.exports = router;