const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

// Obtener todos los miembros
router.get('/', async (req, res) => {
  try {
    const miembros = await prisma.miembro.findMany();
    res.json(miembros);
  } catch (error) {
    console.error('Error al obtener miembros:', error);
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

module.exports = router;