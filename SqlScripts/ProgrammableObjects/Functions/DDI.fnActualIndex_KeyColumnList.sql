USE DDI
GO

DROP FUNCTION DDI.fnActualIndex_KeyColumnList

GO

CREATE OR ALTER FUNCTION DDI.fnActualIndex_KeyColumnList(
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME,
    @TableName SYSNAME,
    @IndexName SYSNAME)   

RETURNS VARCHAR(MAX)
WITH NATIVE_COMPILATION, SCHEMABINDING  
AS   

/*
    SELECT DDI.fnActualIndex_KeyColumnList('PaymentReporting', 'dbo', 'PayTaxes', 'PK_PayTaxes')   
*/
BEGIN ATOMIC WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'English')  
    DECLARE @KeyColumnList VARCHAR(MAX) = ''

    SELECT @KeyColumnList += /*STUFF(*/X.IndexKeyColumnList/*,LEN(X.IndexKeyColumnList),1,'') AS IndexKeyColumnList*/
	FROM    (SELECT TOP (12345678909876543)
                (C.NAME + /*CASE WHEN ic.is_descending_key = 1 THEN ' DESC' ELSE ' ASC' END +*/ ',')
            FROM DDI.SysIndexColumns ic
	            INNER JOIN DDI.SysColumns C ON C.column_id = ic.column_id
		            AND C.object_id = ic.OBJECT_ID
                    AND c.database_id = ic.data
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
                AND ic.is_included_column = 0
	            AND ic.key_ordinal > 0
            ORDER BY ic.key_ordinal
            /*FOR XML PATH('')*/)X(IndexKeyColumnList)

    RETURN @KeyColumnList
END

GO	
