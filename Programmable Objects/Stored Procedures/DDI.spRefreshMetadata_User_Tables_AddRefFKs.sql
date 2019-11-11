IF OBJECT_ID('[DDI].[spRefreshMetadata_User_Tables_AddRefFKs]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_Tables_AddRefFKs];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [DDI].[spRefreshMetadata_User_Tables_AddRefFKs]

AS
    IF OBJECT_ID('DDI.IndexesColumnStore', 'U') IS NOT NULL
        AND OBJECT_ID('DDI.FK_IndexesColumnStore_Tables', 'F') IS NULL
    BEGIN
        ALTER TABLE DDI.IndexesColumnStore 
            ADD CONSTRAINT FK_IndexesColumnStore_Tables
                FOREIGN KEY (DatabaseName, SchemaName, TableName)
                    REFERENCES DDI.Tables (DatabaseName, SchemaName, TableName)
    END

    IF OBJECT_ID('DDI.IndexesRowStore', 'U') IS NOT NULL
        AND OBJECT_ID('DDI.FK_IndexesRowStore_Tables', 'F') IS NULL
    BEGIN
        ALTER TABLE DDI.IndexesRowStore ADD CONSTRAINT FK_IndexesRowStore_Tables
        FOREIGN KEY (DatabaseName, SchemaName, TableName)
            REFERENCES DDI.Tables (DatabaseName, SchemaName, TableName)
    END

    IF OBJECT_ID('DDI.Statistics', 'U') IS NOT NULL
        AND OBJECT_ID('DDI.FK_Statistics_Tables', 'F') IS NULL
    BEGIN
        ALTER TABLE DDI.[Statistics] ADD CONSTRAINT FK_Statistics_Tables
        FOREIGN KEY (DatabaseName, SchemaName, TableName)
            REFERENCES DDI.Tables (DatabaseName, SchemaName, TableName)
    END

    IF OBJECT_ID('DDI.DefaultConstraints', 'U') IS NOT NULL
        AND OBJECT_ID('DDI.FK_DefaultConstraints_Tables', 'F') IS NULL
    BEGIN
        ALTER TABLE DDI.DefaultConstraints ADD CONSTRAINT FK_DefaultConstraints_Tables
        FOREIGN KEY (DatabaseName, SchemaName, TableName)
            REFERENCES DDI.Tables (DatabaseName, SchemaName, TableName)
    END

    IF OBJECT_ID('DDI.CheckConstraints', 'U') IS NOT NULL
        AND OBJECT_ID('DDI.FK_CheckConstraints_Tables', 'F') IS NULL
    BEGIN
        ALTER TABLE DDI.CheckConstraints ADD CONSTRAINT FK_CheckConstraints_Tables
        FOREIGN KEY (DatabaseName, SchemaName, TableName)
            REFERENCES DDI.Tables (DatabaseName, SchemaName, TableName)
    END;

    IF OBJECT_ID('DDI.ForeignKeys', 'U') IS NOT NULL
        AND OBJECT_ID('DDI.FK_ForeignKeys_ParentTables', 'F') IS NULL
    BEGIN
        ALTER TABLE DDI.ForeignKeys ADD CONSTRAINT FK_ForeignKeys_ParentTables
        FOREIGN KEY (DatabaseName, ParentSchemaName, ParentTableName)
            REFERENCES DDI.Tables (DatabaseName, SchemaName, TableName)
    END

    IF OBJECT_ID('DDI.ForeignKeys', 'U') IS NOT NULL
        AND OBJECT_ID('DDI.FK_ForeignKeys_ReferencedTables', 'F') IS NULL
    BEGIN
        ALTER TABLE DDI.ForeignKeys ADD CONSTRAINT FK_ForeignKeys_ReferencedTables
        FOREIGN KEY (DatabaseName, ReferencedSchemaName, ReferencedTableName)
            REFERENCES DDI.Tables (DatabaseName, SchemaName, TableName)
    END

    IF OBJECT_ID('DDI.IndexColumns', 'U') IS NOT NULL
        AND OBJECT_ID('DDI.FK_IndexColumns_Tables', 'F') IS NULL
    BEGIN
        ALTER TABLE DDI.IndexColumns ADD CONSTRAINT FK_IndexColumns_Tables
        FOREIGN KEY (DatabaseName, SchemaName, TableName)
            REFERENCES DDI.Tables (DatabaseName, SchemaName, TableName)
    END
GO
