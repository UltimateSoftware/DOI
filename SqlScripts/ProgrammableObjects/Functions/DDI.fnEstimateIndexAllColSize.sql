USE DDI
GO

CREATE OR ALTER FUNCTION DDI.fnEstimateIndexAllColSize(
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME, 
    @TableName SYSNAME)  
    
/*
    set statistics io on
    set statistics time on
    go
    SELECT *, DDI.fnEstimateIndexAllColSize(schemaname, tablename)
    from DDI.Tables

*/     

RETURNS FLOAT
WITH NATIVE_COMPILATION, SCHEMABINDING  
AS   
BEGIN ATOMIC WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'English')  
  
    DECLARE @IndexAllColSize SYSNAME;
  
    SELECT @IndexAllColSize = avg_record_size_in_bytes
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
