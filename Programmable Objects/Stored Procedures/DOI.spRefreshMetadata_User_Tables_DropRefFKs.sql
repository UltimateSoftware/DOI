USE [$(DatabaseName2)]
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_User_Tables_DropRefFKs]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_Tables_DropRefFKs];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [DOI].[spRefreshMetadata_User_Tables_DropRefFKs]

AS
    IF OBJECT_ID('DOI.FK_IndexesColumnStore_Tables', 'F') IS NOT NULL
    BEGIN
        ALTER TABLE DOI.IndexesColumnStore 
            DROP CONSTRAINT FK_IndexesColumnStore_Tables
    END

    IF OBJECT_ID('DOI.FK_IndexesRowStore_Tables', 'F') IS NOT NULL
    BEGIN
        ALTER TABLE DOI.IndexesRowStore DROP CONSTRAINT FK_IndexesRowStore_Tables
    END

    IF OBJECT_ID('DOI.FK_Statistics_Tables', 'F') IS NOT NULL
    BEGIN
        ALTER TABLE DOI.[Statistics] DROP CONSTRAINT FK_Statistics_Tables
    END

    IF OBJECT_ID('DOI.FK_DefaultConstraints_Tables', 'F') IS NOT NULL
    BEGIN
        ALTER TABLE DOI.DefaultConstraints DROP CONSTRAINT FK_DefaultConstraints_Tables
    END

    IF OBJECT_ID('DOI.FK_CheckConstraints_Tables', 'F') IS NOT NULL
    BEGIN
        ALTER TABLE DOI.CheckConstraints DROP CONSTRAINT FK_CheckConstraints_Tables
    END;

    IF OBJECT_ID('DOI.FK_ForeignKeys_ParentTables', 'F') IS NOT NULL
    BEGIN
        ALTER TABLE DOI.ForeignKeys DROP CONSTRAINT FK_ForeignKeys_ParentTables
    END

    IF OBJECT_ID('DOI.FK_ForeignKeys_ReferencedTables', 'F') IS NOT NULL
    BEGIN
        ALTER TABLE DOI.ForeignKeys DROP CONSTRAINT FK_ForeignKeys_ReferencedTables
    END

    IF OBJECT_ID('DOI.FK_IndexColumns_Tables', 'F') IS NOT NULL
    BEGIN
        ALTER TABLE DOI.IndexColumns DROP CONSTRAINT FK_IndexColumns_Tables
    END
GO
