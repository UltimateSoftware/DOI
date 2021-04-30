
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_Import_IndexColumns_InsertData]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_Import_IndexColumns_InsertData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_Import_IndexColumns_InsertData]

--WITH NATIVE_COMPILATION, SCHEMABINDING
AS

/*
    EXEC DOI.[spRefreshMetadata_Import_IndexColumns_InsertData]
*/

--BEGIN ATOMIC WITH (LANGUAGE = 'English', TRANSACTION ISOLATION LEVEL = SNAPSHOT)

    DELETE DOI.IndexColumns

    DECLARE @IndexColumns DOI.IndexColumnsTT 

    INSERT INTO DOI.IndexColumns ( DatabaseName ,SchemaName ,TableName ,IndexName ,ColumnName ,IsKeyColumn , KeyColumnPosition, IsIncludedColumn , IncludedColumnPosition, IsFixedSize ,ColumnSize )
    SELECT  DatabaseName,
            SchemaName, 
            TableName, 
            IndexName, 
            ColumnName, 
            IsKeyColumn, 
            X.KeyColumnListPosition,
            IsIncludedColumn,
            X.IncludedColumnListPosition,
            IsFixedSize,
            ColumnSize
    FROM (  SELECT  AllIdx.DatabaseName, 
                    AllIdx.SchemaName, 
                    AllIdx.TableName, 
                    AllIdx.IndexName, 
                    ISNULL(KCL.ColumnName, ICL.ColumnName) AS ColumnName,
                    CASE 
                        WHEN KCL.ColumnName IS NOT NULL
                        THEN 1
                        ELSE 0
                    END AS IsKeyColumn, 
                    KCL.KeyColumnListPosition,
                    CASE 
                        WHEN ICL.ColumnName IS NOT NULL
                        THEN 1
                        ELSE 0
                    END AS IsIncludedColumn, 
                    ICL.IncludedColumnListPosition,
                    CASE
                        WHEN ty.name IN ('VARCHAR', 'NVARCHAR', 'TEXT', 'NTEXT', 'VARBINARY', 'FLOAT', 'DECIMAL', 'NUMERIC')
                        THEN 0 
                        ELSE 1
                    END AS IsFixedSize,
                    c.max_length AS ColumnSize
            --SELECT COUNT(*)
            FROM @IndexColumns AllIdx
                INNER JOIN DOI.SysDatabases d ON AllIdx.DatabaseName = D.name
                INNER JOIN DOI.SysSchemas s ON AllIdx.SchemaName = s.name
                INNER JOIN DOI.SysTables t ON AllIdx.TableName = t.name
                    AND s.schema_id = t.schema_id
                INNER JOIN DOI.SysColumns c ON t.object_id = c.object_id
                OUTER APPLY (   SELECT REPLACE(REPLACE(VALUE, ' ASC', ''), ' DESC', '') AS ColumnName, ROW_NUMBER() OVER(PARTITION BY DatabaseName, SchemaName, TableName, IndexName ORDER BY x.MyOrder ASC) AS KeyColumnListPosition
                                FROM (  SELECT value, charindex(value,AllIdx.KeyColumnList_Desired, 0) AS MyOrder 
                                        FROM STRING_SPLIT(AllIdx.KeyColumnList_Desired, ',')) x
                                WHERE REPLACE(REPLACE(VALUE, ' ASC', ''), ' DESC', '') = C.NAME) KCL 
                OUTER APPLY (   SELECT REPLACE(REPLACE(VALUE, ' ASC', ''), ' DESC', '') AS ColumnName, ROW_NUMBER() OVER(PARTITION BY DatabaseName, SchemaName, TableName, IndexName ORDER BY x.MyOrder ASC) AS IncludedColumnListPosition
                                FROM (  SELECT value, charindex(value,AllIdx.IncludedColumnList_Desired, 0) AS MyOrder 
                                        FROM STRING_SPLIT(AllIdx.IncludedColumnList_Desired, ',')) x
                                WHERE REPLACE(REPLACE(VALUE, ' ASC', ''), ' DESC', '') = C.NAME) ICL 
                INNER JOIN DOI.SysTypes ty ON c.user_type_id = ty.user_type_id
            WHERE ISNULL(KCL.ColumnName, ICL.ColumnName) IS NOT NULL) X
--END


GO
