-- <Migration ID="0110741a-4233-558c-95cb-a48ab650cbbe" TransactionHandling="Custom" />
USE [$(DatabaseName2)]
GO

IF OBJECT_ID('[DOI].[fnEstimateIndexSize_AllColSize]') IS NOT NULL
	DROP FUNCTION [DOI].[fnEstimateIndexSize_AllColSize];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE OR ALTER FUNCTION [DOI].[fnEstimateIndexSize_AllColSize](
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME, 
    @TableName SYSNAME)  
    
/*
    set statistics io on
    set statistics time on

    SELECT *, DOI.fnEstimateIndexSize_AllColSize(DatabaseName, schemaname, tablename)
    from DOI.Tables

*/     

RETURNS INT
WITH NATIVE_COMPILATION, SCHEMABINDING  
AS   
BEGIN ATOMIC WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'English')  
  
    DECLARE @IndexAllColSize SYSNAME;
  
    SELECT @IndexAllColSize = CAST(avg_record_size_in_bytes AS INT)
    FROM DOI.SysIndexPhysicalStats IPS
        INNER JOIN DOI.SysDatabases d ON IPS.database_id = d.database_id
        INNER JOIN DOI.systables t ON IPS.OBJECT_ID = t.object_id
        INNER JOIN DOI.sysschemas s ON t.SCHEMA_ID = s.schema_id
    WHERE d.NAME = @DatabaseName
        AND S.NAME = @SchemaName
        AND t.name = @TableName
    AND IPS.index_type_desc IN ('CLUSTERED INDEX', 'HEAP')
                                                             
    RETURN (@IndexAllColSize);  
  
END  
GO
