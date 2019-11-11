USE DDI
GO

DROP TABLE IF EXISTS DDI.IndexColumns
GO

CREATE TABLE DDI.IndexColumns (
    DatabaseName SYSNAME,
    SchemaName SYSNAME,
    TableName SYSNAME,
    IndexName SYSNAME,
    ColumnName SYSNAME,
    IsKeyColumn BIT NOT NULL,
    IsIncludedColumn BIT NOT NULL,
    IsFixedSize BIT NOT NULL,
    ColumnSize DECIMAL(10,2) NOT NULL


    CONSTRAINT PK_IndexColumns
        PRIMARY KEY NONCLUSTERED (DatabaseName, SchemaName, TableName, IndexName, ColumnName)
    )

    WITH (MEMORY_OPTIMIZED = ON)
GO

CREATE OR ALTER PROCEDURE DDI.spRefreshMetadata_IndexColumns

AS

DELETE DDI.IndexColumns

SELECT 'PaymentReporting' AS DatabaseName, 
        SchemaName, 
        TableName, 
        IndexName, 
        ColumnName, 
        IsKeyColumn, 
        IsIncludedColumn,
        IsFixedSize,
        ColumnSize
INTO #IndexColumns
FROM (  SELECT 'PaymentReporting' AS DatabaseName, 
                AllIdx.SchemaName, 
                AllIdx.TableName, 
                AllIdx.IndexName, 
                CL.ColumnName, 
                1 AS IsKeyColumn, 
                0 AS IsIncludedColumn,
                1 AS IsFixedSize,
                c.max_length AS ColumnSize
        FROM (  SELECT IRS.SchemaName, IRS.TableName, IRS.IndexName, IRS.KeyColumnList
                FROM DDI.IndexesRowStore IRS
                UNION ALL
                SELECT ICS.SchemaName, ICS.TableName, ICS.IndexName, ICS.ColumnList
                FROM DDI.IndexesColumnStore ICS) AllIdx
            INNER JOIN DDI.SysSchemas s ON AllIdx.SchemaName = s.name
            INNER JOIN DDI.SysTables t ON AllIdx.TableName = t.name
                AND s.schema_id = t.schema_id
            INNER JOIN DDI.SysColumns c ON t.object_id = c.object_id
            CROSS APPLY (   SELECT REPLACE(REPLACE(VALUE, ' ASC', ''), ' DESC', '') AS ColumnName
                            FROM STRING_SPLIT(AllIdx.KeyColumnList, ',')
                            WHERE REPLACE(REPLACE(VALUE, ' ASC', ''), ' DESC', '') = C.NAME) CL 
            INNER JOIN DDI.SysTypes ty ON c.user_type_id = ty.user_type_id
        WHERE ty.name NOT IN ('VARCHAR', 'NVARCHAR', 'TEXT', 'NTEXT', 'VARBINARY', 'FLOAT', 'DECIMAL', 'NUMERIC')
        UNION ALL
        SELECT 'PaymentReporting' AS DatabaseName, 
                AllIdx.SchemaName, 
                AllIdx.TableName, 
                AllIdx.IndexName, 
                CL.ColumnName, 
                0 AS IsKeyColumn, 
                1 AS IsIncludedColumn,
                1 AS IsFixedSize,
                c.max_length AS ColumnSize
        FROM DDI.IndexesRowStore AllIdx
            INNER JOIN DDI.SysSchemas s ON AllIdx.SchemaName = s.name
            INNER JOIN DDI.SysTables t ON AllIdx.TableName = t.name
                AND s.schema_id = t.schema_id
            INNER JOIN DDI.SysColumns c ON t.object_id = c.object_id
            CROSS APPLY (   SELECT REPLACE(REPLACE(VALUE, ' ASC', ''), ' DESC', '') AS ColumnName
                            FROM STRING_SPLIT(AllIdx.IncludedColumnList, ',')
                            WHERE REPLACE(REPLACE(VALUE, ' ASC', ''), ' DESC', '') = C.NAME) CL 
            INNER JOIN DDI.SysTypes ty ON c.user_type_id = ty.user_type_id
        WHERE ty.name NOT IN ('VARCHAR', 'NVARCHAR', 'TEXT', 'NTEXT', 'VARBINARY', 'FLOAT', 'DECIMAL', 'NUMERIC')
        UNION ALL
        SELECT 'PaymentReporting' AS DatabaseName, 
                AllIdx.SchemaName, 
                AllIdx.TableName, 
                AllIdx.IndexName, 
                CL.ColumnName, 
                1 AS IsKeyColumn, 
                0 AS IsIncludedColumn,
                0 AS IsFixedSize,
                c.max_length AS ColumnSize
        FROM (  SELECT IRS.SchemaName, IRS.TableName, IRS.IndexName, IRS.KeyColumnList
                FROM DDI.IndexesRowStore IRS
                UNION ALL
                SELECT ICS.SchemaName, ICS.TableName, ICS.IndexName, ICS.ColumnList
                FROM DDI.IndexesColumnStore ICS) AllIdx
            INNER JOIN DDI.SysSchemas s ON AllIdx.SchemaName = s.name
            INNER JOIN DDI.SysTables t ON AllIdx.TableName = t.name
                AND s.schema_id = t.schema_id
            INNER JOIN DDI.SysColumns c ON t.object_id = c.object_id
            CROSS APPLY (   SELECT REPLACE(REPLACE(VALUE, ' ASC', ''), ' DESC', '') AS ColumnName
                            FROM STRING_SPLIT(AllIdx.KeyColumnList, ',')
                            WHERE REPLACE(REPLACE(VALUE, ' ASC', ''), ' DESC', '') = C.NAME) CL 
            INNER JOIN DDI.SysTypes ty ON c.user_type_id = ty.user_type_id
        WHERE ty.name IN ('VARCHAR', 'NVARCHAR', 'TEXT', 'NTEXT', 'VARBINARY', 'FLOAT', 'DECIMAL', 'NUMERIC')
        UNION ALL
        SELECT 'PaymentReporting' AS DatabaseName, 
                AllIdx.SchemaName, 
                AllIdx.TableName, 
                AllIdx.IndexName, 
                CL.ColumnName, 
                0 AS IsKeyColumn, 
                1 AS IsIncludedColumn,
                0 AS IsFixedSize,
                c.max_length AS ColumnSize
        FROM DDI.IndexesRowStore AllIdx
            INNER JOIN DDI.SysSchemas s ON AllIdx.SchemaName = s.name
            INNER JOIN DDI.SysTables t ON AllIdx.TableName = t.name
                AND s.schema_id = t.schema_id
            INNER JOIN DDI.SysColumns c ON t.object_id = c.object_id
            CROSS APPLY (   SELECT REPLACE(REPLACE(VALUE, ' ASC', ''), ' DESC', '') AS ColumnName
                            FROM STRING_SPLIT(AllIdx.IncludedColumnList, ',')
                            WHERE REPLACE(REPLACE(VALUE, ' ASC', ''), ' DESC', '') = C.NAME) CL 
            INNER JOIN DDI.SysTypes ty ON c.user_type_id = ty.user_type_id
        WHERE ty.name IN ('VARCHAR', 'NVARCHAR', 'TEXT', 'NTEXT', 'VARBINARY', 'FLOAT', 'DECIMAL', 'NUMERIC')

        
        ) X

INSERT INTO DDI.IndexColumns 
SELECT * FROM #IndexColumns 

DROP TABLE #IndexColumns
GO

EXEC DDI.spRefreshMetadata_IndexColumns
GO
