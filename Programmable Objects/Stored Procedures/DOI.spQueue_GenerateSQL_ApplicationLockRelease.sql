-- <Migration ID="" />

IF OBJECT_ID('[DOI].[spQueue_GenerateSQL_ApplicationLockRelease]') IS NOT NULL
	DROP PROCEDURE [DOI].spQueue_GenerateSQL_ApplicationLockRelease;

GO

CREATE PROCEDURE DOI.spQueue_GenerateSQL_ApplicationLockRelease(
    @DatabaseName SYSNAME,
    @Debug BIT = 0
)   

AS

/*
    EXEC DOI.spQueue_GenerateSQL_ApplicationLockRelease
        @DatabaseName = 'DOIUnitTests',
        @Debug = 1

*/

DECLARE @SQL VARCHAR(MAX) = ''

SELECT TOP 1 @SQL = ReleaseApplicationLockSQL
FROM DOI.vwIndexes
WHERE DatabaseName = @DatabaseName

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