-- <Migration ID="" />

IF OBJECT_ID('[DOI].[spQueue_GenerateSQL_ResourceGovernorEnable]') IS NOT NULL
	DROP PROCEDURE [DOI].spQueue_GenerateSQL_ResourceGovernorEnable;

GO

CREATE PROCEDURE DOI.spQueue_GenerateSQL_ResourceGovernorEnable(
    @Debug BIT = 0
)   

AS

/*
    EXEC DOI.spQueue_GenerateSQL_ResourceGovernorEnable
        @Debug = 1

*/

DECLARE @SQL VARCHAR(MAX) = 'EXEC DOI.spRun_ReEnableResourceGovernor'

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