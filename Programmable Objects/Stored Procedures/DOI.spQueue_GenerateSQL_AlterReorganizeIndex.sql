-- <Migration ID="" />

IF OBJECT_ID('[DOI].[spQueue_GenerateSQL_AlterReorganizeIndex]') IS NOT NULL
	DROP PROCEDURE [DOI].spQueue_GenerateSQL_AlterReorganizeIndex;

GO

CREATE PROCEDURE DOI.spQueue_GenerateSQL_AlterReorganizeIndex(
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME,
    @TableName SYSNAME,
    @IndexName SYSNAME,
    @Debug BIT = 0
)   

AS

/*
    EXEC DOI.spQueue_GenerateSQL_AlterReorganizeIndex
        @DatabaseName = 'DOIUnitTests',
        @SchemaName = 'dbo',
        @TableName = 'TempA',
        @IndexName = 'CDX_TempA',
        @Debug = 1

*/

DECLARE @SQL VARCHAR(MAX) = ''

SELECT @SQL = AlterReorganizeStatement
FROM DOI.vwIndexes
WHERE DatabaseName = @DatabaseName
    AND SchemaName = @SchemaName
    AND TableName = @TableName
    AND IndexName = @IndexName

IF @Debug = 1
BEGIN
    EXEC DOI.spPrintOutLongSQL 
        @SQLInput = @SQL,     
        @VariableName = N'@SQL'    
END
ELSE
BEGIN
    EXEC (@SQL)
END

GO