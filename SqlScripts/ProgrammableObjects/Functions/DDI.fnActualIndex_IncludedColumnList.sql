USE DDI
GO

CREATE OR ALTER FUNCTION DDI.fnActualIndex_IncludedColumnList(
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME,
    @TableName SYSNAME,
    @IndexName SYSNAME)   

RETURNS VARCHAR(MAX)
WITH NATIVE_COMPILATION, SCHEMABINDING  
AS   

/*
    SELECT DDI.fnActualIndex_IncludedColumnList('PaymentReporting', 'dbo', 'PayTaxes', 'IDX_PayTaxes_IngestionCoverWithoutTenantId' )   
*/
BEGIN ATOMIC WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'English')  
    DECLARE @IncludedColumnList VARCHAR(MAX) = ''

    SELECT @IncludedColumnList += /*STUFF(*/X.IndexIncludedColumnList/*,LEN(X.IndexKeyColumnList),1,'') AS IndexKeyColumnList*/
	FROM    (SELECT TOP (12345678909876543)
                (C.NAME + ',')
            FROM DDI.SysIndexColumns ic
	            INNER JOIN DDI.SysColumns C ON C.column_id = ic.column_id
		            AND C.object_id = ic.OBJECT_ID
                    AND c.database_id = ic.database_id
                INNER JOIN DDI.SysIndexes i ON i.object_id = ic.object_id
		            AND i.index_id = ic.index_id
                    AND i.database_id = ic.database_id
                INNER JOIN DDI.SysTables t ON t.OBJECT_ID = i.OBJECT_ID
                    AND t.database_id = i.database_id
                INNER JOIN DDI.SysSchemas s ON s.SCHEMA_ID = t.SCHEMA_ID
                    AND s.database_id = t.database_id
                INNER JOIN DDI.SysDatabases d ON s.database_id = d.database_id
            WHERE d.NAME = @DatabaseName
                AND s.NAME = @SchemaName
                AND t.NAME = @TableName
                AND i.NAME = @IndexName
                AND ic.is_included_column = 1
                AND ic.key_ordinal = 0
                AND ic.partition_ordinal = 0
            ORDER BY ic.key_ordinal
            /*FOR XML PATH('')*/)X(IndexIncludedColumnList)

    RETURN @IncludedColumnList
END

GO	
