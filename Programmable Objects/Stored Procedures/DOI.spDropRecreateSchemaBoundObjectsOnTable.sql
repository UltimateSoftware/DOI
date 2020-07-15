USE [$(DatabaseName2)]
GO

IF OBJECT_ID('[DOI].[spDropRecreateSchemaBoundObjectsOnTable]') IS NOT NULL
	DROP PROCEDURE [DOI].[spDropRecreateSchemaBoundObjectsOnTable];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spDropRecreateSchemaBoundObjectsOnTable]
    @SchemaName SYSNAME,
    @TableName SYSNAME,
    @DropSQL VARCHAR(MAX) OUTPUT,
    @RecreateSQL VARCHAR(MAX) OUTPUT

AS

/*
    DECLARE @DropSQL VARCHAR(MAX) = '',
            @RecreateSQL VARCHAR(MAX) = ''

    EXEC DOI.spDropRecreateSchemaBoundObjectsOnTable
        @SchemaName = 'DOI',
        @TableName = 'IndexesRowStore',
        @DropSQL = @DropSQL OUTPUT,
        @RecreateSQL = @RecreateSQL OUTPUT

    PRINT @DropSQL
    PRINT @RecreateSQL

*/
SELECT  @DropSQL = '',
        @RecreateSQL = ''


SELECT  @DropSQL +=     CASE
                            WHEN type IN ('IF', 'FN', 'TF')
                            THEN 'DROP FUNCTION ' + s.name + '.' + o.name 
                            WHEN type = 'P'
                            THEN 'DROP PROCEDURE ' + s.name + '.' + o.name 
                            WHEN type = 'TR'
                            THEN 'DROP TRIGGER ' + s.name + '.' + o.name 
                            ELSE ''
                        END + CHAR(13) + CHAR(10) + 'GO' + CHAR(13) + CHAR(10), 
        @RecreateSQL +=  CASE
                            WHEN type IN ('IF', 'FN', 'P', 'TR', 'TF')
                            THEN m.definition
                            ELSE ''
                        END + CHAR(13) + CHAR(10) + 'GO' + CHAR(13) + CHAR(10)
FROM sys.sql_expression_dependencies d
    INNER JOIN sys.objects o on o.object_id = d.referencing_id
    INNER JOIN sys.schemas s on o.schema_id = s.schema_id
    INNER JOIN sys.sql_modules m on m.object_id = o.object_id
WHERE s.name = @SchemaName
    AND referenced_entity_name = @TableName
    AND is_schema_bound_reference = 1
    AND type NOT IN ('C', 'D', 'FK')
    AND referenced_minor_id = 0

GO
