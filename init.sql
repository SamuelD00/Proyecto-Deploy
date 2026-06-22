IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'ProyectoBD')
BEGIN
    CREATE DATABASE ProyectoBD;
END
GO

USE [ProyectoBD]
GO

IF NOT EXISTS (SELECT name FROM sys.sql_logins WHERE name = 'sa_proyecto')
BEGIN
    CREATE LOGIN sa_proyecto WITH PASSWORD = 'Proyecto1234!';
END
GO

IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'sa_proyecto')
BEGIN
    CREATE USER sa_proyecto FOR LOGIN sa_proyecto;
    ALTER ROLE db_owner ADD MEMBER sa_proyecto;
END
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Roles' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[Roles](
        [id_rol]  [int]         IDENTITY(1,1) NOT NULL,
        [nombre]  [varchar](50) NOT NULL,
        PRIMARY KEY CLUSTERED ([id_rol] ASC)
    ) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Departamentos' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[Departamentos](
        [id_departamento] [int]          IDENTITY(1,1) NOT NULL,
        [nombre]          [varchar](100) NOT NULL,
        [dias_alerta]     [int]          NOT NULL,
        PRIMARY KEY CLUSTERED ([id_departamento] ASC)
    ) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Sucursales' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[Sucursales](
        [id_sucursal] [int]          IDENTITY(1,1) NOT NULL,
        [nombre]      [varchar](100) NOT NULL,
        PRIMARY KEY CLUSTERED ([id_sucursal] ASC)
    ) ON [PRIMARY]
END
GO

-- Sucursales deben existir antes que Usuarios por la FK
IF NOT EXISTS (SELECT * FROM [dbo].[Sucursales])
BEGIN
    SET IDENTITY_INSERT [dbo].[Sucursales] ON
    INSERT [dbo].[Sucursales] ([id_sucursal], [nombre]) VALUES (1, N'Norte')
    INSERT [dbo].[Sucursales] ([id_sucursal], [nombre]) VALUES (2, N'Sur')
    INSERT [dbo].[Sucursales] ([id_sucursal], [nombre]) VALUES (3, N'Centro')
    SET IDENTITY_INSERT [dbo].[Sucursales] OFF
END
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Usuarios' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[Usuarios](
        [id_usuario]    [int]          IDENTITY(1,1) NOT NULL,
        [nombre]        [varchar](100) NOT NULL,
        [email]         [varchar](100) NOT NULL,
        [password]      [varchar](255) NOT NULL,
        [pin]           [varchar](10)  NULL,
        [id_rol]        [int]          NOT NULL,
        [id_sucursal]   [int]          NULL,
        [activo]        [bit]          NULL,
        [fecha_creacion][datetime]     NULL,
        PRIMARY KEY CLUSTERED ([id_usuario] ASC),
        UNIQUE NONCLUSTERED ([email] ASC),
        FOREIGN KEY([id_rol])      REFERENCES [dbo].[Roles]     ([id_rol]),
        FOREIGN KEY([id_sucursal]) REFERENCES [dbo].[Sucursales]([id_sucursal])
    ) ON [PRIMARY]
    ALTER TABLE [dbo].[Usuarios] ADD DEFAULT ((1))       FOR [activo]
    ALTER TABLE [dbo].[Usuarios] ADD DEFAULT (getdate()) FOR [fecha_creacion]
END
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Productos' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[Productos](
        [id_producto]    [int]          IDENTITY(1,1) NOT NULL,
        [nombre]         [varchar](150) NOT NULL,
        [codigo_barras]  [varchar](50)  NULL,
        [id_departamento][int]          NOT NULL,
        [activo]         [bit]          NULL,
        PRIMARY KEY CLUSTERED ([id_producto] ASC),
        UNIQUE NONCLUSTERED ([codigo_barras] ASC),
        FOREIGN KEY([id_departamento]) REFERENCES [dbo].[Departamentos] ([id_departamento])
    ) ON [PRIMARY]
    ALTER TABLE [dbo].[Productos] ADD DEFAULT ((1)) FOR [activo]
END
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Inventario' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[Inventario](
        [id_inventario]    [int]      IDENTITY(1,1) NOT NULL,
        [id_producto]      [int]      NOT NULL,
        [id_sucursal]      [int]      NOT NULL,
        [fecha_vencimiento][date]     NOT NULL,
        [cantidad]         [int]      NULL,
        [fecha_registro]   [datetime] NULL,
        PRIMARY KEY CLUSTERED ([id_inventario] ASC),
        FOREIGN KEY([id_producto]) REFERENCES [dbo].[Productos]  ([id_producto]),
        FOREIGN KEY([id_sucursal]) REFERENCES [dbo].[Sucursales] ([id_sucursal])
    ) ON [PRIMARY]
    ALTER TABLE [dbo].[Inventario] ADD DEFAULT (getdate()) FOR [fecha_registro]
END
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Retiros' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[Retiros](
        [id_retiro]    [int]         IDENTITY(1,1) NOT NULL,
        [id_inventario][int]         NOT NULL,
        [cantidad]     [int]         NOT NULL,
        [motivo]       [varchar](50) NULL,
        [fecha_retiro] [datetime]    NULL,
        [id_usuario]   [int]         NOT NULL,
        PRIMARY KEY CLUSTERED ([id_retiro] ASC),
        FOREIGN KEY([id_inventario]) REFERENCES [dbo].[Inventario] ([id_inventario]),
        FOREIGN KEY([id_usuario])    REFERENCES [dbo].[Usuarios]   ([id_usuario])
    ) ON [PRIMARY]
    ALTER TABLE [dbo].[Retiros] ADD DEFAULT ('VENCIMIENTO') FOR [motivo]
    ALTER TABLE [dbo].[Retiros] ADD DEFAULT (getdate())     FOR [fecha_retiro]
END
GO

-- ============================================================
-- DATOS INICIALES: Roles
-- ============================================================
IF NOT EXISTS (SELECT * FROM [dbo].[Roles])
BEGIN
    SET IDENTITY_INSERT [dbo].[Roles] ON
    INSERT [dbo].[Roles] ([id_rol], [nombre]) VALUES (1, N'Administrador')
    INSERT [dbo].[Roles] ([id_rol], [nombre]) VALUES (2, N'Operario')
    SET IDENTITY_INSERT [dbo].[Roles] OFF
END
GO

-- ============================================================
-- DATOS INICIALES: Departamentos
-- ============================================================
IF NOT EXISTS (SELECT * FROM [dbo].[Departamentos])
BEGIN
    SET IDENTITY_INSERT [dbo].[Departamentos] ON
    INSERT [dbo].[Departamentos] ([id_departamento], [nombre], [dias_alerta]) VALUES (1,  N'Lacteos',                  3)
    INSERT [dbo].[Departamentos] ([id_departamento], [nombre], [dias_alerta]) VALUES (2,  N'Carnes',                   3)
    INSERT [dbo].[Departamentos] ([id_departamento], [nombre], [dias_alerta]) VALUES (3,  N'Fiambres',                 3)
    INSERT [dbo].[Departamentos] ([id_departamento], [nombre], [dias_alerta]) VALUES (4,  N'Panaderia',                3)
    INSERT [dbo].[Departamentos] ([id_departamento], [nombre], [dias_alerta]) VALUES (5,  N'Huevos',                   3)
    INSERT [dbo].[Departamentos] ([id_departamento], [nombre], [dias_alerta]) VALUES (6,  N'Lacteos No Refrigerados', 10)
    INSERT [dbo].[Departamentos] ([id_departamento], [nombre], [dias_alerta]) VALUES (7,  N'Congelados',              10)
    INSERT [dbo].[Departamentos] ([id_departamento], [nombre], [dias_alerta]) VALUES (8,  N'Almacen',                 10)
    INSERT [dbo].[Departamentos] ([id_departamento], [nombre], [dias_alerta]) VALUES (9,  N'Bebidas',                  7)
    INSERT [dbo].[Departamentos] ([id_departamento], [nombre], [dias_alerta]) VALUES (10, N'Snacks',                   7)
    SET IDENTITY_INSERT [dbo].[Departamentos] OFF
END
GO

-- ============================================================
-- DATOS INICIALES: Usuarios
-- admin: sin sucursal (NULL), operarios asignados a cada sucursal
-- ============================================================
IF NOT EXISTS (SELECT * FROM [dbo].[Usuarios])
BEGIN
    SET IDENTITY_INSERT [dbo].[Usuarios] ON
    INSERT [dbo].[Usuarios] ([id_usuario], [nombre], [email], [password], [pin], [id_rol], [id_sucursal], [activo]) VALUES (1, N'Administrador', N'admin@gondola.com',    N'admin123', N'0000',   1, NULL, 1)
    INSERT [dbo].[Usuarios] ([id_usuario], [nombre], [email], [password], [pin], [id_rol], [id_sucursal], [activo]) VALUES (2, N'Operario Norte', N'norte@gondola.com',   N'op123',    N'1111', 2, 1,    1)
    INSERT [dbo].[Usuarios] ([id_usuario], [nombre], [email], [password], [pin], [id_rol], [id_sucursal], [activo]) VALUES (3, N'Operario Sur',   N'sur@gondola.com',     N'op123',    N'2222', 2, 2,    1)
    INSERT [dbo].[Usuarios] ([id_usuario], [nombre], [email], [password], [pin], [id_rol], [id_sucursal], [activo]) VALUES (4, N'Operario Centro', N'centro@gondola.com', N'op123',    N'3333', 2, 3,    1)
    SET IDENTITY_INSERT [dbo].[Usuarios] OFF
END
GO

-- ============================================================
-- DATOS INICIALES: Productos
-- ============================================================
IF NOT EXISTS (SELECT * FROM [dbo].[Productos])
BEGIN
    SET IDENTITY_INSERT [dbo].[Productos] ON
    INSERT [dbo].[Productos] ([id_producto], [nombre], [codigo_barras], [id_departamento], [activo]) VALUES (1,  N'Leche Entera 1L',        N'7790001000011', 1,  1)
    INSERT [dbo].[Productos] ([id_producto], [nombre], [codigo_barras], [id_departamento], [activo]) VALUES (2,  N'Yogur Vainilla',          N'7790001000012', 1,  1)
    INSERT [dbo].[Productos] ([id_producto], [nombre], [codigo_barras], [id_departamento], [activo]) VALUES (3,  N'Carne Picada',            N'7790001000013', 2,  1)
    INSERT [dbo].[Productos] ([id_producto], [nombre], [codigo_barras], [id_departamento], [activo]) VALUES (4,  N'Bife de Chorizo',         N'7790001000014', 2,  1)
    INSERT [dbo].[Productos] ([id_producto], [nombre], [codigo_barras], [id_departamento], [activo]) VALUES (5,  N'Jamon Cocido',            N'7790001000015', 3,  1)
    INSERT [dbo].[Productos] ([id_producto], [nombre], [codigo_barras], [id_departamento], [activo]) VALUES (6,  N'Queso Cremoso',           N'7790001000016', 3,  1)
    INSERT [dbo].[Productos] ([id_producto], [nombre], [codigo_barras], [id_departamento], [activo]) VALUES (7,  N'Pan Frances',             N'7790001000017', 4,  1)
    INSERT [dbo].[Productos] ([id_producto], [nombre], [codigo_barras], [id_departamento], [activo]) VALUES (8,  N'Medialunas',              N'7790001000018', 4,  1)
    INSERT [dbo].[Productos] ([id_producto], [nombre], [codigo_barras], [id_departamento], [activo]) VALUES (9,  N'Huevos x12',             N'7790001000019', 5,  1)
    INSERT [dbo].[Productos] ([id_producto], [nombre], [codigo_barras], [id_departamento], [activo]) VALUES (10, N'Manteca',                 N'7790001000020', 1,  1)
    INSERT [dbo].[Productos] ([id_producto], [nombre], [codigo_barras], [id_departamento], [activo]) VALUES (11, N'Leche Larga Vida',        N'7790001000021', 6,  1)
    INSERT [dbo].[Productos] ([id_producto], [nombre], [codigo_barras], [id_departamento], [activo]) VALUES (12, N'Crema de Leche',          N'7790001000022', 6,  1)
    INSERT [dbo].[Productos] ([id_producto], [nombre], [codigo_barras], [id_departamento], [activo]) VALUES (13, N'Milanesas Congeladas',    N'7790001000023', 7,  1)
    INSERT [dbo].[Productos] ([id_producto], [nombre], [codigo_barras], [id_departamento], [activo]) VALUES (14, N'Papas Fritas Congeladas', N'7790001000024', 7,  1)
    INSERT [dbo].[Productos] ([id_producto], [nombre], [codigo_barras], [id_departamento], [activo]) VALUES (15, N'Arroz',                   N'7790001000025', 8,  1)
    INSERT [dbo].[Productos] ([id_producto], [nombre], [codigo_barras], [id_departamento], [activo]) VALUES (16, N'Fideos',                  N'7790001000026', 8,  1)
    INSERT [dbo].[Productos] ([id_producto], [nombre], [codigo_barras], [id_departamento], [activo]) VALUES (17, N'Gaseosa Cola 2L',         N'7790001000027', 9,  1)
    INSERT [dbo].[Productos] ([id_producto], [nombre], [codigo_barras], [id_departamento], [activo]) VALUES (18, N'Agua Mineral 1.5L',       N'7790001000028', 9,  1)
    INSERT [dbo].[Productos] ([id_producto], [nombre], [codigo_barras], [id_departamento], [activo]) VALUES (19, N'Papas Fritas Snack',      N'7790001000029', 10, 1)
    INSERT [dbo].[Productos] ([id_producto], [nombre], [codigo_barras], [id_departamento], [activo]) VALUES (20, N'Galletitas Dulces',       N'7790001000030', 10, 1)
    INSERT [dbo].[Productos] ([id_producto], [nombre], [codigo_barras], [id_departamento], [activo]) VALUES (21, N'Mermelada Frutilla',      N'7790001000031', 8,  1)
    INSERT [dbo].[Productos] ([id_producto], [nombre], [codigo_barras], [id_departamento], [activo]) VALUES (22, N'Dulce de Leche',          N'7790001000032', 8,  1)
    INSERT [dbo].[Productos] ([id_producto], [nombre], [codigo_barras], [id_departamento], [activo]) VALUES (23, N'Jugo en Polvo',           N'7790001000033', 9,  1)
    INSERT [dbo].[Productos] ([id_producto], [nombre], [codigo_barras], [id_departamento], [activo]) VALUES (24, N'Aceite de Girasol',       N'7790001000034', 8,  1)
    INSERT [dbo].[Productos] ([id_producto], [nombre], [codigo_barras], [id_departamento], [activo]) VALUES (25, N'Harina 000',              N'7790001000035', 8,  1)
    INSERT [dbo].[Productos] ([id_producto], [nombre], [codigo_barras], [id_departamento], [activo]) VALUES (26, N'Azucar',                  N'7790001000036', 8,  1)
    SET IDENTITY_INSERT [dbo].[Productos] OFF
END
GO

-- ============================================================
-- DATOS INICIALES: Inventario
-- ============================================================
IF NOT EXISTS (SELECT * FROM [dbo].[Inventario])
BEGIN
    SET IDENTITY_INSERT [dbo].[Inventario] ON
    INSERT [dbo].[Inventario] ([id_inventario], [id_producto], [id_sucursal], [fecha_vencimiento], [cantidad], [fecha_registro]) VALUES (2,  1,  1, CAST(N'2026-06-05' AS Date), 9,  CAST(N'2026-06-01T20:30:25.127' AS DateTime))
    INSERT [dbo].[Inventario] ([id_inventario], [id_producto], [id_sucursal], [fecha_vencimiento], [cantidad], [fecha_registro]) VALUES (3,  2,  1, CAST(N'2026-06-10' AS Date), 8,  CAST(N'2026-06-01T20:30:25.127' AS DateTime))
    INSERT [dbo].[Inventario] ([id_inventario], [id_producto], [id_sucursal], [fecha_vencimiento], [cantidad], [fecha_registro]) VALUES (4,  3,  1, CAST(N'2026-06-04' AS Date), 5,  CAST(N'2026-06-01T20:30:25.127' AS DateTime))
    INSERT [dbo].[Inventario] ([id_inventario], [id_producto], [id_sucursal], [fecha_vencimiento], [cantidad], [fecha_registro]) VALUES (5,  4,  1, CAST(N'2026-06-15' AS Date), 12, CAST(N'2026-06-01T20:30:25.127' AS DateTime))
    INSERT [dbo].[Inventario] ([id_inventario], [id_producto], [id_sucursal], [fecha_vencimiento], [cantidad], [fecha_registro]) VALUES (6,  5,  1, CAST(N'2026-06-03' AS Date), 6,  CAST(N'2026-06-01T20:30:25.127' AS DateTime))
    INSERT [dbo].[Inventario] ([id_inventario], [id_producto], [id_sucursal], [fecha_vencimiento], [cantidad], [fecha_registro]) VALUES (7,  6,  1, CAST(N'2026-06-20' AS Date), 7,  CAST(N'2026-06-08T19:03:34.730' AS DateTime))
    INSERT [dbo].[Inventario] ([id_inventario], [id_producto], [id_sucursal], [fecha_vencimiento], [cantidad], [fecha_registro]) VALUES (8,  7,  1, CAST(N'2026-06-09' AS Date), 15, CAST(N'2026-06-08T19:03:34.730' AS DateTime))
    INSERT [dbo].[Inventario] ([id_inventario], [id_producto], [id_sucursal], [fecha_vencimiento], [cantidad], [fecha_registro]) VALUES (9,  8,  1, CAST(N'2026-06-08' AS Date), 20, CAST(N'2026-06-08T19:03:34.730' AS DateTime))
    INSERT [dbo].[Inventario] ([id_inventario], [id_producto], [id_sucursal], [fecha_vencimiento], [cantidad], [fecha_registro]) VALUES (10, 9,  1, CAST(N'2026-06-25' AS Date), 18, CAST(N'2026-06-08T19:03:34.730' AS DateTime))
    INSERT [dbo].[Inventario] ([id_inventario], [id_producto], [id_sucursal], [fecha_vencimiento], [cantidad], [fecha_registro]) VALUES (11, 10, 1, CAST(N'2026-06-24' AS Date), 16, CAST(N'2026-06-08T19:03:34.730' AS DateTime))
    INSERT [dbo].[Inventario] ([id_inventario], [id_producto], [id_sucursal], [fecha_vencimiento], [cantidad], [fecha_registro]) VALUES (12, 11, 1, CAST(N'2026-07-10' AS Date), 25, CAST(N'2026-06-08T19:03:34.730' AS DateTime))
    INSERT [dbo].[Inventario] ([id_inventario], [id_producto], [id_sucursal], [fecha_vencimiento], [cantidad], [fecha_registro]) VALUES (13, 12, 1, CAST(N'2026-07-05' AS Date), 12, CAST(N'2026-06-08T19:03:34.730' AS DateTime))
    INSERT [dbo].[Inventario] ([id_inventario], [id_producto], [id_sucursal], [fecha_vencimiento], [cantidad], [fecha_registro]) VALUES (14, 13, 1, CAST(N'2026-08-15' AS Date), 30, CAST(N'2026-06-08T19:03:34.730' AS DateTime))
    INSERT [dbo].[Inventario] ([id_inventario], [id_producto], [id_sucursal], [fecha_vencimiento], [cantidad], [fecha_registro]) VALUES (15, 14, 1, CAST(N'2026-08-20' AS Date), 22, CAST(N'2026-06-08T19:03:34.730' AS DateTime))
    INSERT [dbo].[Inventario] ([id_inventario], [id_producto], [id_sucursal], [fecha_vencimiento], [cantidad], [fecha_registro]) VALUES (16, 15, 1, CAST(N'2026-12-10' AS Date), 40, CAST(N'2026-06-08T19:03:34.730' AS DateTime))
    INSERT [dbo].[Inventario] ([id_inventario], [id_producto], [id_sucursal], [fecha_vencimiento], [cantidad], [fecha_registro]) VALUES (17, 16, 1, CAST(N'2026-11-20' AS Date), 35, CAST(N'2026-06-08T19:03:34.730' AS DateTime))
    INSERT [dbo].[Inventario] ([id_inventario], [id_producto], [id_sucursal], [fecha_vencimiento], [cantidad], [fecha_registro]) VALUES (18, 17, 1, CAST(N'2026-09-15' AS Date), 28, CAST(N'2026-06-08T19:03:34.730' AS DateTime))
    INSERT [dbo].[Inventario] ([id_inventario], [id_producto], [id_sucursal], [fecha_vencimiento], [cantidad], [fecha_registro]) VALUES (19, 18, 1, CAST(N'2026-09-10' AS Date), 24, CAST(N'2026-06-08T19:03:34.730' AS DateTime))
    INSERT [dbo].[Inventario] ([id_inventario], [id_producto], [id_sucursal], [fecha_vencimiento], [cantidad], [fecha_registro]) VALUES (20, 19, 1, CAST(N'2026-08-01' AS Date), 18, CAST(N'2026-06-08T19:03:34.730' AS DateTime))
    INSERT [dbo].[Inventario] ([id_inventario], [id_producto], [id_sucursal], [fecha_vencimiento], [cantidad], [fecha_registro]) VALUES (21, 20, 1, CAST(N'2026-08-05' AS Date), 15, CAST(N'2026-06-08T19:03:34.730' AS DateTime))
    INSERT [dbo].[Inventario] ([id_inventario], [id_producto], [id_sucursal], [fecha_vencimiento], [cantidad], [fecha_registro]) VALUES (22, 21, 1, CAST(N'2026-07-20' AS Date), 25, CAST(N'2026-06-08T19:03:34.730' AS DateTime))
    INSERT [dbo].[Inventario] ([id_inventario], [id_producto], [id_sucursal], [fecha_vencimiento], [cantidad], [fecha_registro]) VALUES (23, 22, 1, CAST(N'2026-07-25' AS Date), 30, CAST(N'2026-06-08T19:03:34.730' AS DateTime))
    INSERT [dbo].[Inventario] ([id_inventario], [id_producto], [id_sucursal], [fecha_vencimiento], [cantidad], [fecha_registro]) VALUES (24, 23, 1, CAST(N'2026-06-09' AS Date), 10, CAST(N'2026-06-08T19:03:34.730' AS DateTime))
    INSERT [dbo].[Inventario] ([id_inventario], [id_producto], [id_sucursal], [fecha_vencimiento], [cantidad], [fecha_registro]) VALUES (25, 24, 1, CAST(N'2026-06-07' AS Date), 14, CAST(N'2026-06-08T19:03:34.730' AS DateTime))
    INSERT [dbo].[Inventario] ([id_inventario], [id_producto], [id_sucursal], [fecha_vencimiento], [cantidad], [fecha_registro]) VALUES (26, 25, 1, CAST(N'2026-06-06' AS Date), 5,  CAST(N'2026-06-08T19:03:34.730' AS DateTime))
    INSERT [dbo].[Inventario] ([id_inventario], [id_producto], [id_sucursal], [fecha_vencimiento], [cantidad], [fecha_registro]) VALUES (27, 26, 1, CAST(N'2026-06-11' AS Date), 8,  CAST(N'2026-06-08T19:03:34.730' AS DateTime))
    -- Sucursal Sur
    INSERT [dbo].[Inventario] ([id_inventario], [id_producto], [id_sucursal], [fecha_vencimiento], [cantidad], [fecha_registro]) VALUES (28, 1,  2, CAST(N'2026-06-12' AS Date), 10, CAST(N'2026-06-08T19:03:34.730' AS DateTime))
    INSERT [dbo].[Inventario] ([id_inventario], [id_producto], [id_sucursal], [fecha_vencimiento], [cantidad], [fecha_registro]) VALUES (29, 3,  2, CAST(N'2026-06-14' AS Date), 7,  CAST(N'2026-06-08T19:03:34.730' AS DateTime))
    INSERT [dbo].[Inventario] ([id_inventario], [id_producto], [id_sucursal], [fecha_vencimiento], [cantidad], [fecha_registro]) VALUES (30, 5,  2, CAST(N'2026-07-01' AS Date), 15, CAST(N'2026-06-08T19:03:34.730' AS DateTime))
    -- Sucursal Centro
    INSERT [dbo].[Inventario] ([id_inventario], [id_producto], [id_sucursal], [fecha_vencimiento], [cantidad], [fecha_registro]) VALUES (31, 2,  3, CAST(N'2026-06-18' AS Date), 6,  CAST(N'2026-06-08T19:03:34.730' AS DateTime))
    INSERT [dbo].[Inventario] ([id_inventario], [id_producto], [id_sucursal], [fecha_vencimiento], [cantidad], [fecha_registro]) VALUES (32, 4,  3, CAST(N'2026-06-20' AS Date), 9,  CAST(N'2026-06-08T19:03:34.730' AS DateTime))
    INSERT [dbo].[Inventario] ([id_inventario], [id_producto], [id_sucursal], [fecha_vencimiento], [cantidad], [fecha_registro]) VALUES (33, 6,  3, CAST(N'2026-07-05' AS Date), 11, CAST(N'2026-06-08T19:03:34.730' AS DateTime))
    SET IDENTITY_INSERT [dbo].[Inventario] OFF
END
GO

-- ============================================================
-- DATOS INICIALES: Retiros
-- ============================================================
IF NOT EXISTS (SELECT * FROM [dbo].[Retiros])
BEGIN
    SET IDENTITY_INSERT [dbo].[Retiros] ON
    INSERT [dbo].[Retiros] ([id_retiro], [id_inventario], [cantidad], [motivo], [fecha_retiro], [id_usuario]) VALUES (1, 2, 2, N'Vencimiento',     CAST(N'2026-06-09T19:00:31.037' AS DateTime), 1)
    INSERT [dbo].[Retiros] ([id_retiro], [id_inventario], [cantidad], [motivo], [fecha_retiro], [id_usuario]) VALUES (2, 3, 1, N'Producto dañado', CAST(N'2026-06-09T19:00:31.037' AS DateTime), 2)
    INSERT [dbo].[Retiros] ([id_retiro], [id_inventario], [cantidad], [motivo], [fecha_retiro], [id_usuario]) VALUES (3, 4, 3, N'Vencimiento',     CAST(N'2026-06-09T19:00:31.037' AS DateTime), 1)
    INSERT [dbo].[Retiros] ([id_retiro], [id_inventario], [cantidad], [motivo], [fecha_retiro], [id_usuario]) VALUES (4, 2, 1, N'Vencimiento',     CAST(N'2026-06-09T20:05:50.080' AS DateTime), 1)
    SET IDENTITY_INSERT [dbo].[Retiros] OFF
END
GO

-- ============================================================
-- STORED PROCEDURES
-- ============================================================

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='sp_inventario_por_sucursal' AND xtype='P')
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_inventario_por_sucursal]
        @id_sucursal INT
    AS
    BEGIN
        SET NOCOUNT ON;
        SELECT
            i.id_inventario,
            p.nombre AS producto,
            d.nombre AS departamento,
            i.fecha_vencimiento,
            i.cantidad,
            i.fecha_registro
        FROM Inventario i
        INNER JOIN Productos     p ON i.id_producto      = p.id_producto
        INNER JOIN Departamentos d ON p.id_departamento  = d.id_departamento
        WHERE i.id_sucursal = @id_sucursal;
    END
    ')
END
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='sp_mermas_por_sucursal' AND xtype='P')
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_mermas_por_sucursal]
    AS
    BEGIN
        SET NOCOUNT ON;
        SELECT
            s.nombre AS sucursal,
            SUM(r.cantidad) AS total_merma
        FROM Retiros r
        INNER JOIN Inventario i ON r.id_inventario = i.id_inventario
        INNER JOIN Sucursales s ON i.id_sucursal   = s.id_sucursal
        GROUP BY s.nombre;
    END
    ')
END
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='sp_registrar_inventario' AND xtype='P')
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_registrar_inventario]
        @id_producto       INT,
        @id_sucursal       INT,
        @fecha_vencimiento DATE,
        @cantidad          INT = NULL
    AS
    BEGIN
        SET NOCOUNT ON;
        INSERT INTO Inventario (id_producto, id_sucursal, fecha_vencimiento, cantidad)
        VALUES (@id_producto, @id_sucursal, @fecha_vencimiento, @cantidad);
    END
    ')
END
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='sp_registrar_retiro' AND xtype='P')
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_registrar_retiro]
        @id_inventario INT,
        @cantidad      INT,
        @id_usuario    INT
    AS
    BEGIN
        SET NOCOUNT ON;
        INSERT INTO Retiros (id_inventario, cantidad, id_usuario)
        VALUES (@id_inventario, @cantidad, @id_usuario);

        UPDATE Inventario
        SET cantidad = ISNULL(cantidad, 0) - @cantidad
        WHERE id_inventario = @id_inventario;
    END
    ')
END
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='sp_total_mermas' AND xtype='P')
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_total_mermas]
    AS
    BEGIN
        SET NOCOUNT ON;
        SELECT SUM(cantidad) AS total_merma FROM Retiros;
    END
    ')
END
GO
