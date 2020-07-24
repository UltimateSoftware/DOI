
GO

IF OBJECT_ID('[DOI].[fnRefreshMetadataForViewSQL]') IS NOT NULL
	DROP FUNCTION [DOI].[fnRefreshMetadataForViewSQL];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE    FUNCTION [DOI].[fnRefreshMetadataForViewSQL](
    @ViewName SYSNAME)

RETURNS VARCHAR(MAX)

AS

/*
    SELECT DOI.fnRefreshMetadataForViewSQL('vwPartitionFunctionPartitions')

    FIGURES OUT THE ENTIRE DEPENDENCY CHAIN HERE:
    1. FROM VIEW TO SYS METADATA TABLES, 
    2. FROM SYS METADATA TABLES TO SPs THAT UPDATE THE SYS METADATA TABLES
    3. FROM SYS METADATA TABLES TO THE USER METADATA TABLES THAT HAVE COMPUTED COLUMNS BASED ON SYS METADATA TABLES.
    4. FROM THESE USER METADATA TABLES TO THE UPDATE SPs THAT UPDATE THE COMPUTED COLUMNS
*/

BEGIN
    DECLARE @SQL VARCHAR(MAX) = ''

    SET @SQL = (
                SELECT  DISTINCT 'EXEC ' + s.NAME + '.' + sp.NAME + CHAR(13) + CHAR(10)
                FROM sys.sql_expression_dependencies d
                    INNER JOIN sys.views v ON d.referencing_id = v.object_id
                    INNER JOIN sys.tables TRV ON d.referenced_id = TRV.object_id
                    INNER JOIN sys.sql_expression_dependencies dSP ON TRV.object_id = dSP.referenced_id
                    INNER JOIN sys.procedures sp ON dsp.referencing_id = sp.OBJECT_ID
                    INNER JOIN sys.schemas s ON sp.SCHEMA_ID = s.schema_id
                WHERE v.name = 'vwPartitionFunctionPartitions'--@ViewName
                    --AND TRV.name LIKE 'Sys%'
                    AND (sp.name LIKE 'spRefreshMetadata|_System|_%' ESCAPE '|'
                            OR sp.name LIKE 'spRefreshMetadata|_User|_%|_UpdateData' ESCAPE '|')
                ORDER BY 'EXEC ' + s.NAME + '.' + sp.NAME + CHAR(13) + CHAR(10)
                FOR XML PATH, TYPE).value('.', 'nvarchar(max)')

    RETURN @SQL
END


GO
