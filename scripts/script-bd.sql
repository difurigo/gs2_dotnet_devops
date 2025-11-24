/*
    script-bd.sql
    Criação das tabelas da Avant API no Azure SQL

    Modelo baseado em:
    - Tabela Equipes
    - Tabela Usuarios
    - Relacionamentos:
        - Usuario -> Equipe (EquipeId, ON DELETE SET NULL)
        - Equipe -> Usuario (GerenteId, ON DELETE RESTRICT)
*/

-- Tabela Equipes
IF OBJECT_ID('dbo.Equipes', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Equipes
    (
        Id UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Equipes PRIMARY KEY,
        Nome NVARCHAR(100) NOT NULL,
        GerenteId UNIQUEIDENTIFIER NOT NULL
    );
END;
GO

-- Tabela Usuarios
IF OBJECT_ID('dbo.Usuarios', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Usuarios
    (
        Id UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Usuarios PRIMARY KEY,
        Nome NVARCHAR(100) NOT NULL,
        Email NVARCHAR(150) NOT NULL,
        SenhaHash NVARCHAR(300) NOT NULL,
        Perfil INT NOT NULL,
        PlanoCarreira NVARCHAR(200) NULL,
        EquipeId UNIQUEIDENTIFIER NULL
    );
END;
GO

-- Índice único em Email
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_Usuarios_Email'
      AND object_id = OBJECT_ID('dbo.Usuarios')
)
BEGIN
    CREATE UNIQUE INDEX IX_Usuarios_Email
        ON dbo.Usuarios (Email);
END;
GO

-- Índice em EquipeId
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_Usuarios_EquipeId'
      AND object_id = OBJECT_ID('dbo.Usuarios')
)
BEGIN
    CREATE INDEX IX_Usuarios_EquipeId
        ON dbo.Usuarios (EquipeId);
END;
GO

-- Índice em GerenteId
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_Equipes_GerenteId'
      AND object_id = OBJECT_ID('dbo.Equipes')
)
BEGIN
    CREATE INDEX IX_Equipes_GerenteId
        ON dbo.Equipes (GerenteId);
END;
GO

-- FK: Usuarios.EquipeId -> Equipes.Id (ON DELETE SET NULL)
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_Usuarios_Equipes_EquipeId'
      AND parent_object_id = OBJECT_ID('dbo.Usuarios')
)
BEGIN
    ALTER TABLE dbo.Usuarios
        ADD CONSTRAINT FK_Usuarios_Equipes_EquipeId
        FOREIGN KEY (EquipeId)
        REFERENCES dbo.Equipes (Id)
        ON DELETE SET NULL;
END;
GO

-- FK: Equipes.GerenteId -> Usuarios.Id (ON DELETE RESTRICT / NO ACTION)
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_Equipes_Usuarios_GerenteId'
      AND parent_object_id = OBJECT_ID('dbo.Equipes')
)
BEGIN
    ALTER TABLE dbo.Equipes
        ADD CONSTRAINT FK_Equipes_Usuarios_GerenteId
        FOREIGN KEY (GerenteId)
        REFERENCES dbo.Usuarios (Id)
        ON DELETE NO ACTION;
END;
GO
