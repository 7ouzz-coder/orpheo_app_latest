-- CreateTable
CREATE TABLE "User" (
    "id" SERIAL NOT NULL,
    "username" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "email" TEXT,
    "role" TEXT NOT NULL DEFAULT 'general',
    "grado" TEXT NOT NULL DEFAULT 'aprendiz',
    "cargo" TEXT,
    "memberFullName" TEXT,
    "miembroId" INTEGER,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Miembro" (
    "id" SERIAL NOT NULL,
    "nombres" TEXT NOT NULL,
    "apellidos" TEXT NOT NULL,
    "rut" TEXT NOT NULL,
    "grado" TEXT NOT NULL DEFAULT 'aprendiz',
    "cargo" TEXT,
    "vigente" BOOLEAN NOT NULL DEFAULT true,
    "email" TEXT,
    "telefono" TEXT,
    "direccion" TEXT,
    "profesion" TEXT,
    "ocupacion" TEXT,
    "trabajoNombre" TEXT,
    "trabajoDireccion" TEXT,
    "trabajoTelefono" TEXT,
    "trabajoEmail" TEXT,
    "parejaNombre" TEXT,
    "parejaTelefono" TEXT,
    "contactoEmergenciaNombre" TEXT,
    "contactoEmergenciaTelefono" TEXT,
    "fechaNacimiento" TIMESTAMP(3),
    "fechaIniciacion" TIMESTAMP(3),
    "fechaAumentoSalario" TIMESTAMP(3),
    "fechaExaltacion" TIMESTAMP(3),
    "situacionSalud" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Miembro_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Documento" (
    "id" SERIAL NOT NULL,
    "nombre" TEXT NOT NULL,
    "tipo" TEXT NOT NULL,
    "descripcion" TEXT,
    "tamano" TEXT,
    "url" TEXT,
    "localPath" TEXT,
    "categoria" TEXT NOT NULL,
    "subcategoria" TEXT,
    "palabrasClave" TEXT,
    "esPlancha" BOOLEAN NOT NULL DEFAULT false,
    "planchaId" TEXT,
    "planchaEstado" TEXT,
    "autorId" INTEGER,
    "subidoPorId" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Documento_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Programa" (
    "id" SERIAL NOT NULL,
    "tema" TEXT NOT NULL,
    "fecha" TIMESTAMP(3) NOT NULL,
    "encargado" TEXT NOT NULL,
    "quienImparte" TEXT,
    "resumen" TEXT,
    "grado" TEXT NOT NULL,
    "tipo" TEXT NOT NULL,
    "estado" TEXT NOT NULL DEFAULT 'Pendiente',
    "documentosJson" TEXT,
    "responsableId" INTEGER,
    "ubicacion" TEXT,
    "detallesAdicionales" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Programa_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Asistencia" (
    "id" SERIAL NOT NULL,
    "programaId" INTEGER NOT NULL,
    "miembroId" INTEGER NOT NULL,
    "asistio" BOOLEAN NOT NULL DEFAULT false,
    "justificacion" TEXT,
    "registradoPorId" INTEGER,
    "horaRegistro" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Asistencia_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Notificacion" (
    "id" SERIAL NOT NULL,
    "titulo" TEXT NOT NULL,
    "mensaje" TEXT NOT NULL,
    "tipo" TEXT NOT NULL,
    "relacionadoTipo" TEXT,
    "relacionadoId" TEXT,
    "leido" BOOLEAN NOT NULL DEFAULT false,
    "leidoAt" TIMESTAMP(3),
    "usuarioId" INTEGER NOT NULL,
    "gradoDestino" TEXT,
    "remitenteTipo" TEXT,
    "remitenteId" TEXT,
    "remitenteNombre" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiresAt" TIMESTAMP(3),
    "isPriority" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "Notificacion_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_username_key" ON "User"("username");

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE UNIQUE INDEX "User_miembroId_key" ON "User"("miembroId");

-- CreateIndex
CREATE UNIQUE INDEX "Miembro_rut_key" ON "Miembro"("rut");

-- CreateIndex
CREATE UNIQUE INDEX "Asistencia_programaId_miembroId_key" ON "Asistencia"("programaId", "miembroId");

-- AddForeignKey
ALTER TABLE "User" ADD CONSTRAINT "User_miembroId_fkey" FOREIGN KEY ("miembroId") REFERENCES "Miembro"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Documento" ADD CONSTRAINT "Documento_autorId_fkey" FOREIGN KEY ("autorId") REFERENCES "Miembro"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Documento" ADD CONSTRAINT "Documento_subidoPorId_fkey" FOREIGN KEY ("subidoPorId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Programa" ADD CONSTRAINT "Programa_responsableId_fkey" FOREIGN KEY ("responsableId") REFERENCES "Miembro"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Asistencia" ADD CONSTRAINT "Asistencia_programaId_fkey" FOREIGN KEY ("programaId") REFERENCES "Programa"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Asistencia" ADD CONSTRAINT "Asistencia_miembroId_fkey" FOREIGN KEY ("miembroId") REFERENCES "Miembro"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Asistencia" ADD CONSTRAINT "Asistencia_registradoPorId_fkey" FOREIGN KEY ("registradoPorId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Notificacion" ADD CONSTRAINT "Notificacion_usuarioId_fkey" FOREIGN KEY ("usuarioId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
