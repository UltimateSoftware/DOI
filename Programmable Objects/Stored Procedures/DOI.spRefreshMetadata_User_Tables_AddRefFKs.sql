IF OBJECT_ID('[DOI].[spRefreshMetadata_User_Tables_AddRefFKs]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_Tables_AddRefFKs];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [DOI].[spRefreshMetadata_User_Tables_AddRefFKs]

AS
    IF OBJECT_ID('DOI.IndexesColumnStore', 'U') IS NOT NULL
        AND OBJECT_ID('DOI.FK_IndexesColumnStore_Tables', 'F') IS NULL
    BEGIN
        ALTER TABLE DOI.IndexesColumnStore 
            ADD CONSTRAINT FK_IndexesColumnStore_Tables
                FOREIGN KEY (DatabaseName, SchemaName, TableName)
                    REFERENCES DOI.Tables (DatabaseName, SchemaName, TableName)
    END

    IF OBJECT_ID('DOI.IndexesRowStore', 'U') IS NOT NULL
        AND OBJECT_ID('DOI.FK_IndexesRowStore_Tables', 'F') IS NULL
    BEGIN
        ALTER TABLE DOI.IndexesRowStore ADD CONSTRAINT FK_IndexesRowStore_Tables
        FOREIGN KEY (DatabaseName, SchemaName, TableName)
            REFERENCES DOI.Tables (DatabaseName, SchemaName, TableName)
    END

    IF OBJECT_ID('DOI.Statistics', 'U') IS NOT NULL
        AND OBJECT_ID('DOI.FK_Statistics_Tables', 'F') IS NULL
    BEGIN
        ALTER TABLE DOI.[Statistics] ADD CONSTRAINT FK_Statistics_Tables
        FOREIGN KEY (DatabaseName, SchemaName, TableName)
            REFERENCES DOI.Tables (DatabaseName, SchemaName, TableName)
    END

    IF OBJECT_ID('DOI.DefaultConstraints', 'U') IS NOT NULL
        AND OBJECT_ID('DOI.FK_DefaultConstraints_Tables', 'F') IS NULL
    BEGIN
        ALTER TABLE DOI.DefaultConstraints ADD CONSTRAINT FK_DefaultConstraints_Tables
        FOREIGN KEY (DatabaseName, SchemaName, TableName)
            REFERENCES DOI.Tables (DatabaseName, SchemaName, TableName)
    END

    IF OBJECT_ID('DOI.CheckConstraints', 'U') IS NOT NULL
        AND OBJECT_ID('DOI.FK_CheckConstraints_Tables', 'F') IS NULL
    BEGIN
        ALTER TABLE DOI.CheckConstraints ADD CONSTRAINT FK_CheckConstraints_Tables
        FOREIGN KEY (DatabaseName, SchemaName, TableName)
            REFERENCES DOI.Tables (DatabaseName, SchemaName, TableName)
    END;

    IF OBJECT_ID('DOI.ForeignKeys', 'U') IS NOT NULL
        AND OBJECT_ID('DOI.FK_ForeignKeys_ParentTables', 'F') IS NULL
    BEGIN
        ALTER TABLE DOI.ForeignKeys ADD CONSTRAINT FK_ForeignKeys_ParentTables
        FOREIGN KEY (DatabaseName, ParentSchemaName, ParentTableName)
            REFERENCES DOI.Tables (DatabaseName, SchemaName, TableName)
    END

    IF OBJECT_ID('DOI.ForeignKeys', 'U') IS NOT NULL
        AND OBJECT_ID('DOI.FK_ForeignKeys_ReferencedTables', 'F') IS NULL
    BEGIN
        ALTER TABLE DOI.ForeignKeys ADD CONSTRAINT FK_ForeignKeys_ReferencedTables
        FOREIGN KEY (DatabaseName, ReferencedSchemaName, ReferencedTableName)
            REFERENCES DOI.Tables (DatabaseName, SchemaName, TableName)
    END

    IF OBJECT_ID('DOI.IndexColumns', 'U') IS NOT NULL
        AND OBJECT_ID('DOI.FK_IndexColumns_Tables', 'F') IS NULL
    BEGIN
        ALTER TABLE DOI.IndexColumns ADD CONSTRAINT FK_IndexColumns_Tables
        FOREIGN KEY (DatabaseName, SchemaName, TableName)
            REFERENCES DOI.Tables (DatabaseName, SchemaName, TableName)
    END
GO
