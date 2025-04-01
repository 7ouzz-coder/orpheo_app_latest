// backend/prisma/seed.js

const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcrypt');

const prisma = new PrismaClient();

async function main() {
  try {
    console.log('Iniciando la carga de datos semilla...');

    // Limpiar datos existentes (opcional)
    // await prisma.user.deleteMany();
    // await prisma.miembro.deleteMany();

    // Crear miembros
    console.log('Creando miembros...');
    
    const adminMiembro = await prisma.miembro.upsert({
      where: { rut: '11111111-1' },
      update: {},
      create: {
        nombres: 'Administrador',
        apellidos: 'Del Sistema',
        rut: '11111111-1',
        grado: 'maestro',
        cargo: 'administrador',
        email: 'admin@orpheo.org',
        telefono: '+56 9 1111 1111',
        direccion: 'Av. Ejemplo 1234, Santiago',
        profesion: 'Ingeniero',
        fechaNacimiento: new Date('1980-01-01'),
        fechaIniciacion: new Date('2010-01-01'),
        fechaAumentoSalario: new Date('2012-01-01'),
        fechaExaltacion: new Date('2014-01-01'),
      },
    });
    
    const maestroMiembro = await prisma.miembro.upsert({
      where: { rut: '22222222-2' },
      update: {},
      create: {
        nombres: 'Usuario',
        apellidos: 'Maestro',
        rut: '22222222-2',
        grado: 'maestro',
        email: 'maestro@orpheo.org',
        telefono: '+56 9 2222 2222',
        direccion: 'Av. Maestro 1234, Santiago',
        profesion: 'Arquitecto',
        fechaNacimiento: new Date('1985-02-02'),
        fechaIniciacion: new Date('2012-02-02'),
        fechaAumentoSalario: new Date('2014-02-02'),
        fechaExaltacion: new Date('2016-02-02'),
      },
    });
    
    const companeroMiembro = await prisma.miembro.upsert({
      where: { rut: '33333333-3' },
      update: {},
      create: {
        nombres: 'Usuario',
        apellidos: 'Compañero',
        rut: '33333333-3',
        grado: 'companero',
        email: 'companero@orpheo.org',
        telefono: '+56 9 3333 3333',
        direccion: 'Av. Compañero 1234, Santiago',
        profesion: 'Abogado',
        fechaNacimiento: new Date('1990-03-03'),
        fechaIniciacion: new Date('2018-03-03'),
        fechaAumentoSalario: new Date('2020-03-03'),
      },
    });
    
    const aprendizMiembro = await prisma.miembro.upsert({
      where: { rut: '44444444-4' },
      update: {},
      create: {
        nombres: 'Usuario',
        apellidos: 'Aprendiz',
        rut: '44444444-4',
        grado: 'aprendiz',
        email: 'aprendiz@orpheo.org',
        telefono: '+56 9 4444 4444',
        direccion: 'Av. Aprendiz 1234, Santiago',
        profesion: 'Estudiante',
        fechaNacimiento: new Date('1995-04-04'),
        fechaIniciacion: new Date('2022-04-04'),
      },
    });
    
    const secretarioMiembro = await prisma.miembro.upsert({
      where: { rut: '55555555-5' },
      update: {},
      create: {
        nombres: 'Secretario',
        apellidos: 'Del Taller',
        rut: '55555555-5',
        grado: 'maestro',
        cargo: 'secretario',
        email: 'secretario@orpheo.org',
        telefono: '+56 9 5555 5555',
        direccion: 'Av. Secretario 1234, Santiago',
        profesion: 'Contador',
        fechaNacimiento: new Date('1982-05-05'),
        fechaIniciacion: new Date('2011-05-05'),
        fechaAumentoSalario: new Date('2013-05-05'),
        fechaExaltacion: new Date('2015-05-05'),
      },
    });
    
    const tesoreroMiembro = await prisma.miembro.upsert({
      where: { rut: '66666666-6' },
      update: {},
      create: {
        nombres: 'Tesorero',
        apellidos: 'Del Taller',
        rut: '66666666-6',
        grado: 'maestro',
        cargo: 'tesorero',
        email: 'tesorero@orpheo.org',
        telefono: '+56 9 6666 6666',
        direccion: 'Av. Tesorero 1234, Santiago',
        profesion: 'Economista',
        fechaNacimiento: new Date('1983-06-06'),
        fechaIniciacion: new Date('2012-06-06'),
        fechaAumentoSalario: new Date('2014-06-06'),
        fechaExaltacion: new Date('2016-06-06'),
      },
    });
    
    console.log('Miembros creados correctamente.');
    
    // Crear usuarios
    console.log('Creando usuarios...');
    
    // Generar hash de contraseña
    const saltRounds = 10;
    const adminPasswordHash = await bcrypt.hash('admin123', saltRounds);
    const maestroPasswordHash = await bcrypt.hash('maestro123', saltRounds);
    const companeroPasswordHash = await bcrypt.hash('companero123', saltRounds);
    const aprendizPasswordHash = await bcrypt.hash('aprendiz123', saltRounds);
    const secretarioPasswordHash = await bcrypt.hash('secretario123', saltRounds);
    const tesoreroPasswordHash = await bcrypt.hash('tesorero123', saltRounds);
    
    // Crear usuarios asociados a los miembros
    const adminUser = await prisma.user.upsert({
      where: { username: 'admin' },
      update: {},
      create: {
        username: 'admin',
        password: adminPasswordHash,
        email: 'admin@orpheo.org',
        role: 'admin',
        grado: 'maestro',
        cargo: 'administrador',
        memberFullName: `${adminMiembro.nombres} ${adminMiembro.apellidos}`,
        miembroId: adminMiembro.id,
        isActive: true,
      },
    });
    
    const maestroUser = await prisma.user.upsert({
      where: { username: 'maestro' },
      update: {},
      create: {
        username: 'maestro',
        password: maestroPasswordHash,
        email: 'maestro@orpheo.org',
        role: 'general',
        grado: 'maestro',
        memberFullName: `${maestroMiembro.nombres} ${maestroMiembro.apellidos}`,
        miembroId: maestroMiembro.id,
        isActive: true,
      },
    });
    
    const companeroUser = await prisma.user.upsert({
      where: { username: 'companero' },
      update: {},
      create: {
        username: 'companero',
        password: companeroPasswordHash,
        email: 'companero@orpheo.org',
        role: 'general',
        grado: 'companero',
        memberFullName: `${companeroMiembro.nombres} ${companeroMiembro.apellidos}`,
        miembroId: companeroMiembro.id,
        isActive: true,
      },
    });
    
    const aprendizUser = await prisma.user.upsert({
      where: { username: 'aprendiz' },
      update: {},
      create: {
        username: 'aprendiz',
        password: aprendizPasswordHash,
        email: 'aprendiz@orpheo.org',
        role: 'general',
        grado: 'aprendiz',
        memberFullName: `${aprendizMiembro.nombres} ${aprendizMiembro.apellidos}`,
        miembroId: aprendizMiembro.id,
        isActive: true,
      },
    });
    
    const secretarioUser = await prisma.user.upsert({
      where: { username: 'secretario' },
      update: {},
      create: {
        username: 'secretario',
        password: secretarioPasswordHash,
        email: 'secretario@orpheo.org',
        role: 'general',
        grado: 'maestro',
        cargo: 'secretario',
        memberFullName: `${secretarioMiembro.nombres} ${secretarioMiembro.apellidos}`,
        miembroId: secretarioMiembro.id,
        isActive: true,
      },
    });
    
    const tesoreroUser = await prisma.user.upsert({
      where: { username: 'tesorero' },
      update: {},
      create: {
        username: 'tesorero',
        password: tesoreroPasswordHash,
        email: 'tesorero@orpheo.org',
        role: 'general',
        grado: 'maestro',
        cargo: 'tesorero',
        memberFullName: `${tesoreroMiembro.nombres} ${tesoreroMiembro.apellidos}`,
        miembroId: tesoreroMiembro.id,
        isActive: true,
      },
    });
    
    console.log('Usuarios creados correctamente.');
    
    // Crear algunos documentos de ejemplo
    console.log('Creando documentos de ejemplo...');
    
    // Documentos para aprendices
    await prisma.documento.upsert({
      where: { id: 1 },
      update: {},
      create: {
        id: 1,
        nombre: 'Manual del Aprendiz',
        tipo: 'pdf',
        descripcion: 'Guía completa para el primer grado',
        categoria: 'aprendiz',
        autorId: maestroMiembro.id,
        subidoPorId: adminUser.id,
      },
    });
    
    await prisma.documento.upsert({
      where: { id: 2 },
      update: {},
      create: {
        id: 2,
        nombre: 'Simbolismo del Primer Grado',
        tipo: 'pdf',
        descripcion: 'Explicación detallada del simbolismo del primer grado',
        categoria: 'aprendiz',
        autorId: maestroMiembro.id,
        subidoPorId: adminUser.id,
      },
    });
    
    // Documentos para compañeros
    await prisma.documento.upsert({
      where: { id: 3 },
      update: {},
      create: {
        id: 3,
        nombre: 'Manual del Compañero',
        tipo: 'pdf',
        descripcion: 'Guía completa para el segundo grado',
        categoria: 'companero',
        autorId: maestroMiembro.id,
        subidoPorId: adminUser.id,
      },
    });
    
    // Documentos para maestros
    await prisma.documento.upsert({
      where: { id: 4 },
      update: {},
      create: {
        id: 4,
        nombre: 'Manual del Maestro',
        tipo: 'pdf',
        descripcion: 'Guía completa para el tercer grado',
        categoria: 'maestro',
        autorId: maestroMiembro.id,
        subidoPorId: adminUser.id,
      },
    });
    
    console.log('Documentos creados correctamente.');
    
    // Crear programas de ejemplo
    console.log('Creando programas de ejemplo...');
    
    const hoy = new Date();
    
    await prisma.programa.upsert({
      where: { id: 1 },
      update: {},
      create: {
        id: 1,
        tema: 'Tenida de Primer Grado',
        fecha: new Date(hoy.getFullYear(), hoy.getMonth(), hoy.getDate() + 7, 19, 30),
        encargado: 'Juan Pérez',
        grado: 'aprendiz',
        tipo: 'tenida',
        estado: 'Programado',
        ubicacion: 'Templo Principal',
        responsableId: maestroMiembro.id,
      },
    });
    
    await prisma.programa.upsert({
      where: { id: 2 },
      update: {},
      create: {
        id: 2,
        tema: 'Tenida de Segundo Grado',
        fecha: new Date(hoy.getFullYear(), hoy.getMonth(), hoy.getDate() + 14, 19, 30),
        encargado: 'Roberto Gómez',
        grado: 'companero',
        tipo: 'tenida',
        estado: 'Programado',
        ubicacion: 'Templo Principal',
        responsableId: maestroMiembro.id,
      },
    });
    
    await prisma.programa.upsert({
      where: { id: 3 },
      update: {},
      create: {
        id: 3,
        tema: 'Tenida de Tercer Grado',
        fecha: new Date(hoy.getFullYear(), hoy.getMonth(), hoy.getDate() + 21, 19, 30),
        encargado: 'Miguel Sánchez',
        grado: 'maestro',
        tipo: 'tenida',
        estado: 'Programado',
        ubicacion: 'Templo Principal',
        responsableId: maestroMiembro.id,
      },
    });
    
    console.log('Programas creados correctamente.');
    console.log('Datos semilla cargados con éxito.');
    
  } catch (error) {
    console.error('Error al cargar datos semilla:', error);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });