-- <Migration ID="0110741a-4233-558c-95cb-a48ab650cbbe" TransactionHandling="Custom" />
IF OBJECT_ID('[DDI].[fnEstimateIndexSize_AllColSize]') IS NOT NULL
	DROP FUNCTION [DDI].[fnEstimateIndexSize_AllColSize];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE OR ALTER FUNCTION [DDI].[fnEstimateIndexSize_AllColSize](
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME, 
    @TableName SYSNAME)  
    
/*
    set statistics io on
    set statistics time on

    SELECT *, DDI.fnEstimateIndexSize_AllColSize(DatabaseName, schemaname, tablename)
    from DDI.Tables

*/     

RETURNS INT
WITH NATIVE_COMPILATION, SCHEMABINDING  
AS   
BEGIN ATOMIC WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'English')  
  
    DECLARE @IndexAllColSize SYSNAME;
  
    SELECT @IndexAllColSize = CAST(avg_record_size_in_bytes AS INT)
    FROM DDI.SysIndexPhysicalStats IPS
        INNER JOIN DDI.SysDatabases d ON IPS.database_id = d.database_id
        INNER JOIN DDI.systables t ON IPS.OBJECT_ID = t.object_id
        INNER JOIN DDI.sysschemas s ON t.SCHEMA_ID = s.schema_id
    WHERE d.NAME = @DatabaseName
        AND S.NAME = @SchemaName
        AND t.name = @TableName
    AND IPS.index_type_desc IN ('CLUSTERED INDEX', 'HEAP')
                                                             
    RETURN (@IndexAllColSize);  
  
END  
GO
