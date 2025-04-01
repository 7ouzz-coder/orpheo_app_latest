const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const prisma = new PrismaClient();

// Configuración de multer para subida de archivos
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    // Directorio de destino para los archivos subidos
    const uploadDir = process.env.UPLOAD_DIR || './uploads';
    
    // Crear el directorio si no existe
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    // Generar un nombre único para el archivo
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    cb(null, uniqueSuffix + ext);
  }
});

const upload = multer({ 
  storage: storage,
  limits: {
    fileSize: process.env.MAX_FILE_SIZE || 10 * 1024 * 1024 // 10MB por defecto
  },
  fileFilter: function (req, file, cb) {
    // Validar tipos de archivo permitidos
    const allowedFileTypes = [
      '.pdf', '.doc', '.docx', '.txt', '.xls', '.xlsx',
      '.ppt', '.pptx', '.jpg', '.jpeg', '.png'
    ];
    const ext = path.extname(file.originalname).toLowerCase();
    
    if (allowedFileTypes.includes(ext)) {
      return cb(null, true);
    }
    
    cb(new Error('Tipo de archivo no permitido. Solo se permiten: ' + allowedFileTypes.join(', ')));
  }
});

// Obtener todos los documentos
router.get('/', async (req, res) => {
  try {
    // Obtener parámetros de consulta
    const { categoria, subcategoria, esPlancha } = req.query;
    
    // Construir filtro
    const where = {};
    if (categoria && categoria !== 'todos') {
      where.categoria = categoria;
    }
    
    if (subcategoria) {
      where.subcategoria = subcategoria;
    }
    
    if (esPlancha !== undefined) {
      where.esPlancha = esPlancha === 'true';
    }
    
    // Obtener documentos con filtros
    const documentos = await prisma.documento.findMany({
      where,
      include: {
        autor: {
          select: {
            id: true,
            nombres: true,
            apellidos: true
          }
        },
        subidoPor: {
          select: {
            id: true,
            username: true,
            memberFullName: true
          }
        }
      },
      orderBy: {
        createdAt: 'desc'
      }
    });
    
    // Transformar los datos para enviar nombres de autor y subido por
    const documentosFormateados = documentos.map(doc => ({
      ...doc,
      autorNombre: doc.autor ? `${doc.autor.nombres} ${doc.autor.apellidos}` : null,
      subidoPorNombre: doc.subidoPor.memberFullName || doc.subidoPor.username
    }));
    
    res.json(documentosFormateados);
  } catch (error) {
    console.error('Error al obtener documentos:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
});

// Obtener documentos por categoría
router.get('/categoria/:categoria', async (req, res) => {
  try {
    const { categoria } = req.params;
    
    const documentos = await prisma.documento.findMany({
      where: { categoria },
      include: {
        autor: {
          select: {
            id: true,
            nombres: true,
            apellidos: true
          }
        },
        subidoPor: {
          select: {
            id: true,
            username: true,
            memberFullName: true
          }
        }
      },
      orderBy: {
        createdAt: 'desc'
      }
    });
    
    // Transformar los datos para enviar nombres de autor y subido por
    const documentosFormateados = documentos.map(doc => ({
      ...doc,
      autorNombre: doc.autor ? `${doc.autor.nombres} ${doc.autor.apellidos}` : null,
      subidoPorNombre: doc.subidoPor.memberFullName || doc.subidoPor.username
    }));
    
    res.json(documentosFormateados);
  } catch (error) {
    console.error('Error al obtener documentos por categoría:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
});

// Búsqueda de documentos
router.get('/search', async (req, res) => {
  try {
    const { query, categoria } = req.query;
    
    if (!query) {
      return res.status(400).json({ message: 'Parámetro de búsqueda requerido' });
    }
    
    // Construir condición de búsqueda
    const searchCondition = {
      OR: [
        { nombre: { contains: query, mode: 'insensitive' } },
        { descripcion: { contains: query, mode: 'insensitive' } },
        { palabrasClave: { contains: query, mode: 'insensitive' } },
      ],
    };
    
    // Añadir filtro por categoría si se proporciona
    if (categoria && categoria !== 'todos') {
      searchCondition.AND = { categoria };
    }
    
    const documentos = await prisma.documento.findMany({
      where: searchCondition,
      include: {
        autor: {
          select: {
            id: true,
            nombres: true,
            apellidos: true
          }
        },
        subidoPor: {
          select: {
            id: true,
            username: true,
            memberFullName: true
          }
        }
      },
      orderBy: {
        createdAt: 'desc'
      }
    });
    
    // Transformar los datos para enviar nombres de autor y subido por
    const documentosFormateados = documentos.map(doc => ({
      ...doc,
      autorNombre: doc.autor ? `${doc.autor.nombres} ${doc.autor.apellidos}` : null,
      subidoPorNombre: doc.subidoPor.memberFullName || doc.subidoPor.username
    }));
    
    res.json(documentosFormateados);
  } catch (error) {
    console.error('Error en búsqueda de documentos:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
});

// Obtener un documento por ID
router.get('/:id', async (req, res) => {
  try {
    const documento = await prisma.documento.findUnique({
      where: { id: parseInt(req.params.id) },
      include: {
        autor: {
          select: {
            id: true,
            nombres: true,
            apellidos: true
          }
        },
        subidoPor: {
          select: {
            id: true,
            username: true,
            memberFullName: true
          }
        }
      }
    });
    
    if (!documento) {
      return res.status(404).json({ message: 'Documento no encontrado' });
    }
    
    // Transformar los datos para enviar nombres de autor y subido por
    const documentoFormateado = {
      ...documento,
      autorNombre: documento.autor ? `${documento.autor.nombres} ${documento.autor.apellidos}` : null,
      subidoPorNombre: documento.subidoPor.memberFullName || documento.subidoPor.username
    };
    
    res.json(documentoFormateado);
  } catch (error) {
    console.error('Error al obtener documento:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
});

// Descargar un documento
router.get('/:id/download', async (req, res) => {
  try {
    const documento = await prisma.documento.findUnique({
      where: { id: parseInt(req.params.id) }
    });
    
    if (!documento) {
      return res.status(404).json({ message: 'Documento no encontrado' });
    }
    
    if (!documento.localPath) {
      return res.status(404).json({ message: 'Archivo no disponible para descarga' });
    }
    
    const filePath = path.resolve(documento.localPath);
    
    if (!fs.existsSync(filePath)) {
      return res.status(404).json({ message: 'Archivo no encontrado en el servidor' });
    }
    
    res.download(filePath, documento.nombre);
  } catch (error) {
    console.error('Error al descargar documento:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
});

// Crear un nuevo documento
router.post('/', upload.single('file'), async (req, res) => {
  try {
    // Validar datos obligatorios
    const { nombre, categoria } = req.body;
    
    if (!nombre || !categoria) {
      return res.status(400).json({ message: 'Nombre y categoría son campos obligatorios' });
    }
    
    // Si no hay archivo y no hay URL, es un error
    if (!req.file && !req.body.url) {
      return res.status(400).json({ message: 'Se requiere un archivo o una URL para el documento' });
    }
    
    // El usuario que sube el documento debería estar disponible a través del middleware de autenticación
    // Pero por ahora simulamos con un ID fijo para pruebas
    const subidoPorId = req.user?.id || 1; // En producción, usar req.user.id
    
    // Preparar datos del documento
    const documentoData = {
      nombre,
      categoria,
      tipo: req.file ? path.extname(req.file.originalname).replace('.', '') : req.body.tipo || 'url',
      descripcion: req.body.descripcion,
      tamano: req.file ? `${req.file.size}` : null,
      url: req.body.url,
      localPath: req.file ? req.file.path : null,
      subcategoria: req.body.subcategoria,
      palabrasClave: req.body.palabrasClave,
      esPlancha: req.body.esPlancha === 'true',
      planchaId: req.body.planchaId,
      planchaEstado: req.body.esPlancha === 'true' ? (req.body.planchaEstado || 'pendiente') : null,
      autorId: req.body.autorId ? parseInt(req.body.autorId) : null,
      subidoPorId,
    };
    
    // Crear documento
    const documento = await prisma.documento.create({
      data: documentoData,
      include: {
        autor: {
          select: {
            id: true,
            nombres: true,
            apellidos: true
          }
        },
        subidoPor: {
          select: {
            id: true,
            username: true,
            memberFullName: true
          }
        }
      }
    });
    
    // Transformar los datos para enviar nombres de autor y subido por
    const documentoFormateado = {
      ...documento,
      autorNombre: documento.autor ? `${documento.autor.nombres} ${documento.autor.apellidos}` : null,
      subidoPorNombre: documento.subidoPor.memberFullName || documento.subidoPor.username
    };
    
    res.status(201).json(documentoFormateado);
  } catch (error) {
    console.error('Error al crear documento:', error);
    
    // Si hay un archivo subido, intentar eliminarlo en caso de error
    if (req.file && req.file.path) {
      try {
        fs.unlinkSync(req.file.path);
      } catch (e) {
        console.error('Error al eliminar archivo:', e);
      }
    }
    
    res.status(500).json({ message: 'Error interno del servidor' });
  }
});

// Actualizar un documento
router.put('/:id', upload.single('file'), async (req, res) => {
  try {
    const { id } = req.params;
    
    // Verificar si el documento existe
    const existingDocumento = await prisma.documento.findUnique({
      where: { id: parseInt(id) }
    });
    
    if (!existingDocumento) {
      return res.status(404).json({ message: 'Documento no encontrado' });
    }
    
    // Crear objeto con datos a actualizar
    const updateData = {};
    
    // Campos básicos
    if (req.body.nombre !== undefined) updateData.nombre = req.body.nombre;
    if (req.body.categoria !== undefined) updateData.categoria = req.body.categoria;
    if (req.body.descripcion !== undefined) updateData.descripcion = req.body.descripcion;
    if (req.body.subcategoria !== undefined) updateData.subcategoria = req.body.subcategoria;
    if (req.body.palabrasClave !== undefined) updateData.palabrasClave = req.body.palabrasClave;
    if (req.body.esPlancha !== undefined) updateData.esPlancha = req.body.esPlancha === 'true';
    if (req.body.planchaId !== undefined) updateData.planchaId = req.body.planchaId;
    if (req.body.planchaEstado !== undefined) updateData.planchaEstado = req.body.planchaEstado;
    if (req.body.autorId !== undefined) updateData.autorId = req.body.autorId ? parseInt(req.body.autorId) : null;
    if (req.body.url !== undefined) updateData.url = req.body.url;
    
    // Si hay un nuevo archivo
    if (req.file) {
      updateData.tipo = path.extname(req.file.originalname).replace('.', '');
      updateData.tamano = `${req.file.size}`;
      updateData.localPath = req.file.path;
      
      // Si existía un archivo anterior, intentar eliminarlo
      if (existingDocumento.localPath) {
        try {
          fs.unlinkSync(existingDocumento.localPath);
        } catch (e) {
          console.error('Error al eliminar archivo anterior:', e);
        }
      }
    }
    
    // Actualizar documento
    const documento = await prisma.documento.update({
      where: { id: parseInt(id) },
      data: updateData,
      include: {
        autor: {
          select: {
            id: true,
            nombres: true,
            apellidos: true
          }
        },
        subidoPor: {
          select: {
            id: true,
            username: true,
            memberFullName: true
          }
        }
      }
    });
    
    // Transformar los datos para enviar nombres de autor y subido por
    const documentoFormateado = {
      ...documento,
      autorNombre: documento.autor ? `${documento.autor.nombres} ${documento.autor.apellidos}` : null,
      subidoPorNombre: documento.subidoPor.memberFullName || documento.subidoPor.username
    };
    
    res.json(documentoFormateado);
  } catch (error) {
    console.error('Error al actualizar documento:', error);
    
    // Si hay un archivo subido, intentar eliminarlo en caso de error
    if (req.file && req.file.path) {
      try {
        fs.unlinkSync(req.file.path);
      } catch (e) {
        console.error('Error al eliminar archivo:', e);
      }
    }
    
    res.status(500).json({ message: 'Error interno del servidor' });
  }
});

// Eliminar un documento
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    // Verificar si el documento existe
    const existingDocumento = await prisma.documento.findUnique({
      where: { id: parseInt(id) }
    });
    
    if (!existingDocumento) {
      return res.status(404).json({ message: 'Documento no encontrado' });
    }
    
    // Eliminar el archivo si existe
    if (existingDocumento.localPath) {
      try {
        fs.unlinkSync(existingDocumento.localPath);
      } catch (e) {
        console.error('Error al eliminar archivo:', e);
      }
    }
    
    // Eliminar documento
    await prisma.documento.delete({
      where: { id: parseInt(id) }
    });
    
    res.json({ message: 'Documento eliminado correctamente' });
  } catch (error) {
    console.error('Error al eliminar documento:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
});

module.exports = router;