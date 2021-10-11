-- <Migration ID="1ad38e90-f0a5-4dca-8a98-7796c3f7f2cc" />
GO
-- WARNING: this script could not be parsed using the Microsoft.TrasactSql.ScriptDOM parser and could not be made rerunnable. You may be able to make this change manually by editing the script by surrounding it in the following sql and applying it or marking it as applied!
IF OBJECT_ID('[DOI].[spRefreshMetadata_User_IndexColumns_InsertData]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_IndexColumns_InsertData];

GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_User_IndexColumns_InsertData]
    @DatabaseName NVARCHAR(128) = NULL

AS
DELETE DOI.IndexColumns
WHERE DatabaseName = CASE WHEN @DatabaseName IS NULL THEN DatabaseName ELSE @DatabaseName END

--INSERT IRS ACTUAL COLUMNS
INSERT INTO DOI.IndexColumns(DatabaseName,SchemaName,TableName,IndexName,ColumnName,IsKeyColumn,KeyColumnPosition,IsIncludedColumn,IncludedColumnPosition, Desired, Actual)
SELECT DatabaseName, SchemaName, TableName, IndexName, KCL.value AS ColumnName, 1 AS IsKeyColumn, ROW_NUMBER() OVER(PARTITION BY DatabaseName, SchemaName, TableName ORDER BY TableName) AS KeyColumnPosition, 0 IsIncludedColumn, NULL AS IncludedColumnPosition, 0 AS Desired, 1 AS Actual
FROM DOI.IndexesRowStore IRS
    CROSS APPLY STRING_SPLIT(REPLACE(REPLACE(KeyColumnList_Actual, ' ASC', SPACE(0)), ' DESC', SPACE(0)),',') KCL
WHERE DatabaseName = CASE WHEN @DatabaseName IS NULL THEN DatabaseName ELSE @DatabaseName END
UNION ALL
SELECT DatabaseName, SchemaName, TableName, IndexName, ICL.value, 0, NULL, 1, ROW_NUMBER() OVER(PARTITION BY DatabaseName, SchemaName, TableName ORDER BY TableName), 0, 1
FROM DOI.IndexesRowStore IRS
    CROSS APPLY STRING_SPLIT(REPLACE(REPLACE(IncludedColumnList_Actual, ' ASC', SPACE(0)), ' DESC', SPACE(0)),',') ICL
WHERE DatabaseName = CASE WHEN @DatabaseName IS NULL THEN DatabaseName ELSE @DatabaseName END

--INSERT IRS DESIRED COLUMNS, WHICH ARE NOT ACTUAL COLUMNS.
INSERT INTO DOI.IndexColumns(DatabaseName,SchemaName,TableName,IndexName,ColumnName,IsKeyColumn,KeyColumnPosition,IsIncludedColumn,IncludedColumnPosition, Desired, Actual)
SELECT DatabaseName, SchemaName, TableName, IndexName, KCLD.value, 1, ROW_NUMBER() OVER(PARTITION BY DatabaseName, SchemaName, TableName ORDER BY TableName), 0, NULL, 1, 0
FROM DOI.IndexesRowStore IRS
    CROSS APPLY STRING_SPLIT(REPLACE(REPLACE(KeyColumnList_Desired, ' ASC', SPACE(0)), ' DESC', SPACE(0)),',') KCLD
WHERE DatabaseName = CASE WHEN @DatabaseName IS NULL THEN DatabaseName ELSE @DatabaseName END
    AND NOT EXISTS (SELECT 'True' 
                    FROM DOI.IndexColumns IC 
                    WHERE IC.DatabaseName = IRS.DatabaseName 
                        AND IC.TableName = IRS.TableName 
                        AND IC.IndexName = IRS.IndexName 
                        AND IC.ColumnName = KCLD.value)
UNION ALL
SELECT DatabaseName, SchemaName, TableName, IndexName, ICLD.value, 0, NULL, 0, ROW_NUMBER() OVER(PARTITION BY DatabaseName, SchemaName, TableName ORDER BY TableName), 1, 0
FROM DOI.IndexesRowStore IRS
    CROSS APPLY STRING_SPLIT(REPLACE(REPLACE(IncludedColumnList_Desired, ' ASC', SPACE(0)), ' DESC', SPACE(0)),',') ICLD
WHERE DatabaseName = CASE WHEN @DatabaseName IS NULL THEN DatabaseName ELSE @DatabaseName END
    AND NOT EXISTS (SELECT 'True' 
                    FROM DOI.IndexColumns IC 
                    WHERE IC.DatabaseName = IRS.DatabaseName 
                        AND IC.TableName = IRS.TableName 
                        AND IC.IndexName = IRS.IndexName 
                        AND IC.ColumnName = ICLD.value)

--INSERT ICS ACTUAL COLUMNS
INSERT INTO DOI.IndexColumns(DatabaseName,SchemaName,TableName,IndexName,ColumnName,IsKeyColumn,KeyColumnPosition,IsIncludedColumn,IncludedColumnPosition, Desired, Actual)
SELECT DatabaseName, SchemaName, TableName, IndexName, CL.value, 0, NULL, 1, ROW_NUMBER() OVER(PARTITION BY DatabaseName, SchemaName, TableName ORDER BY TableName), 0, 1
FROM DOI.IndexesColumnStore ICS
    CROSS APPLY STRING_SPLIT(REPLACE(REPLACE(ICS.ColumnList_Actual, ' ASC', SPACE(0)), ' DESC', SPACE(0)),',') CL
WHERE DatabaseName = CASE WHEN @DatabaseName IS NULL THEN DatabaseName ELSE @DatabaseName END

--INSERT ICS DESIRED COLUMNS, THAT ARE NOT ACTUAL COLUMNS.
INSERT INTO DOI.IndexColumns(DatabaseName,SchemaName,TableName,IndexName,ColumnName,IsKeyColumn,KeyColumnPosition,IsIncludedColumn,IncludedColumnPosition, Desired, Actual)
SELECT DatabaseName, SchemaName, TableName, IndexName, CLD.value, 0, NULL, 1, ROW_NUMBER() OVER(PARTITION BY DatabaseName, SchemaName, TableName ORDER BY TableName), 1, 0
FROM DOI.IndexesColumnStore ICS
    CROSS APPLY STRING_SPLIT(REPLACE(REPLACE(ColumnList_Desired, ' ASC', SPACE(0)), ' DESC', SPACE(0)),',') CLD
WHERE DatabaseName = CASE WHEN @DatabaseName IS NULL THEN DatabaseName ELSE @DatabaseName END
    AND NOT EXISTS (SELECT 'True' 
                    FROM DOI.IndexColumns IC 
                    WHERE IC.DatabaseName = ICS.DatabaseName 
                        AND IC.TableName = ICS.TableName 
                        AND IC.IndexName = ICS.IndexName 
                        AND IC.ColumnName = CLD.value)

--UPDATE OTHER VALUES THAT MAY HAVE CHANGED.
UPDATE IC
SET Desired = 1, IsKeyColumn = 1, IC.KeyColumnPosition = KCLD.KeyColumnPosition
FROM DOI.IndexColumns IC
    INNER JOIN DOI.IndexesRowStore IRS ON IC.DatabaseName = IRS.DatabaseName 
        AND IC.TableName = IRS.TableName 
        AND IC.IndexName = IRS.IndexName 
    CROSS APPLY (   SELECT value, ROW_NUMBER() OVER(PARTITION BY IC.DatabaseName, IC.SchemaName, IC.TableName ORDER BY IC.TableName) AS KeyColumnPosition
                    FROM STRING_SPLIT(REPLACE(REPLACE(KeyColumnList_Desired, ' ASC', SPACE(0)), ' DESC', SPACE(0)),',')) KCLD
WHERE IC.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN IC.DatabaseName ELSE @DatabaseName END
    AND IC.ColumnName = KCLD.value

UPDATE IC
SET Desired = 1, IsIncludedColumn = 1, IC.IncludedColumnPosition = ICLD.IncludedColumnPosition
FROM DOI.IndexColumns IC
    INNER JOIN DOI.IndexesRowStore IRS ON IC.DatabaseName = IRS.DatabaseName 
        AND IC.TableName = IRS.TableName 
        AND IC.IndexName = IRS.IndexName 
    CROSS APPLY (      SELECT value, ROW_NUMBER() OVER(PARTITION BY IC.DatabaseName, IC.SchemaName, IC.TableName ORDER BY IC.TableName) AS IncludedColumnPosition
                    FROM STRING_SPLIT(REPLACE(REPLACE(IncludedColumnList_Desired, ' ASC', SPACE(0)), ' DESC', SPACE(0)),',')) ICLD
WHERE IC.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN IC.DatabaseName ELSE @DatabaseName END
    AND IC.ColumnName = ICLD.value

UPDATE IC
SET Desired = 1, IC.IsIncludedColumn = 1, IC.IncludedColumnPosition = CLD.IncludedColumnPosition
FROM DOI.IndexColumns IC
    INNER JOIN DOI.IndexesColumnStore ICS ON IC.DatabaseName = ICS.DatabaseName 
        AND IC.TableName = ICS.TableName 
        AND IC.IndexName = ICS.IndexName 
    CROSS APPLY (      SELECT value, ROW_NUMBER() OVER(PARTITION BY IC.DatabaseName, IC.SchemaName, IC.TableName ORDER BY IC.TableName) AS IncludedColumnPosition
                    FROM STRING_SPLIT(REPLACE(REPLACE(ColumnList_Desired, ' ASC', SPACE(0)), ' DESC', SPACE(0)),',')) CLD
WHERE IC.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN IC.DatabaseName ELSE @DatabaseName END
    AND IC.ColumnName = CLD.value

--DELETE ANY COLUMNS THAT WERE REMOVED FROM INDEXES...we don't need this b/c we are already setting 'desired' and 'actual' columns to 0 if needed above.
--DELETE IC
--FROM DOI.IndexColumns IC
--WHERE IC.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN IC.DatabaseName ELSE @DatabaseName END
--    AND ic.IsKeyColumn = 1
--    AND NOT EXISTS (SELECT 'True' 
--                    FROM DOI.IndexesRowStore IRS
--                        CROSS APPLY STRING_SPLIT(REPLACE(REPLACE(KeyColumnList_Desired, ' ASC', SPACE(0)), ' DESC', SPACE(0)),',') KCLD
--                    WHERE IRS.DatabaseName = IC.DatabaseName
--                        AND IRS.SchemaName = IC.SchemaName
--                        AND IRS.TableName = IC.TableName
--                        AND IRS.IndexName = IC.IndexName
--                        AND KCLD.Value = IC.ColumnName)

--DELETE IC
--FROM DOI.IndexColumns IC
--WHERE IC.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN IC.DatabaseName ELSE @DatabaseName END
--    AND IC.IsIncludedColumn = 1
--    AND NOT EXISTS (SELECT 'True' 
--                    FROM DOI.IndexesRowStore IRS
--                        CROSS APPLY STRING_SPLIT(REPLACE(REPLACE(IncludedColumnList_Desired, ' ASC', SPACE(0)), ' DESC', SPACE(0)),',') ICLD
--                    WHERE IRS.DatabaseName = IC.DatabaseName
--                        AND IRS.SchemaName = IC.SchemaName
--                        AND IRS.TableName = IC.TableName
--                        AND IRS.IndexName = IC.IndexName
--                        AND ICLD.Value = IC.ColumnName)


--DELETE IC
--FROM DOI.IndexColumns IC
--WHERE IC.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN IC.DatabaseName ELSE @DatabaseName END
--    AND NOT EXISTS (SELECT 'True' 
--                    FROM DOI.IndexesColumnStore ICS
--                        CROSS APPLY STRING_SPLIT(REPLACE(REPLACE(ColumnList_Desired, ' ASC', SPACE(0)), ' DESC', SPACE(0)),',') CLD
--                    WHERE ICS.DatabaseName = IC.DatabaseName
--                        AND ICS.SchemaName = IC.SchemaName
--                        AND ICS.TableName = IC.TableName
--                        AND ICS.IndexName = IC.IndexName
--                        AND CLD.Value = IC.ColumnName)
GO