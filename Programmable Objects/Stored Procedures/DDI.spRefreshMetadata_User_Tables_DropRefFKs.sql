IF OBJECT_ID('[DDI].[spRefreshMetadata_User_Tables_DropRefFKs]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_Tables_DropRefFKs];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [DDI].[spRefreshMetadata_User_Tables_DropRefFKs]

AS
    IF OBJECT_ID('DDI.FK_IndexesColumnStore_Tables', 'F') IS NOT NULL
    BEGIN
        ALTER TABLE DDI.IndexesColumnStore 
            DROP CONSTRAINT FK_IndexesColumnStore_Tables
    END

    IF OBJECT_ID('DDI.FK_IndexesRowStore_Tables', 'F') IS NOT NULL
    BEGIN
        ALTER TABLE DDI.IndexesRowStore DROP CONSTRAINT FK_IndexesRowStore_Tables
    END

    IF OBJECT_ID('DDI.FK_Statistics_Tables', 'F') IS NOT NULL
    BEGIN
        ALTER TABLE DDI.[Statistics] DROP CONSTRAINT FK_Statistics_Tables
    END

    IF OBJECT_ID('DDI.FK_DefaultConstraints_Tables', 'F') IS NOT NULL
    BEGIN
        ALTER TABLE DDI.DefaultConstraints DROP CONSTRAINT FK_DefaultConstraints_Tables
    END

    IF OBJECT_ID('DDI.FK_CheckConstraints_Tables', 'F') IS NOT NULL
    BEGIN
        ALTER TABLE DDI.CheckConstraints DROP CONSTRAINT FK_CheckConstraints_Tables
    END;

    IF OBJECT_ID('DDI.FK_ForeignKeys_ParentTables', 'F') IS NOT NULL
    BEGIN
        ALTER TABLE DDI.ForeignKeys DROP CONSTRAINT FK_ForeignKeys_ParentTables
    END

    IF OBJECT_ID('DDI.FK_ForeignKeys_ReferencedTables', 'F') IS NOT NULL
    BEGIN
        ALTER TABLE DDI.ForeignKeys DROP CONSTRAINT FK_ForeignKeys_ReferencedTables
    END

    IF OBJECT_ID('DDI.FK_IndexColumns_Tables', 'F') IS NOT NULL
    BEGIN
        ALTER TABLE DDI.IndexColumns DROP CONSTRAINT FK_IndexColumns_Tables
    END
GO
