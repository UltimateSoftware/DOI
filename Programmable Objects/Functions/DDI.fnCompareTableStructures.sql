IF OBJECT_ID('[DDI].[fnCompareTableStructures]') IS NOT NULL
	DROP FUNCTION [DDI].[fnCompareTableStructures];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE     FUNCTION [DDI].[fnCompareTableStructures](
    @DatabaseName SYSNAME,
	@SchemaName1 SYSNAME,
	@TableName1 SYSNAME,
	@SchemaName2 SYSNAME,
	@TableName2 SYSNAME,
	@DiffBetTableNames SYSNAME,
	@PartitionColumnToReplaceInPK SYSNAME)
RETURNS TABLE
AS RETURN
(

/*

SELECT * FROM DDI.fnCompareTableStructures(
    'PaymentReporting',
    'dbo',
    'Liabilities',
    'dbo',
    'Liabilities_NewPartitionedTableFromPrep',
    '_NewPartitionedTableFromPrep',
    'PayDate')	
*/


SELECT 
(SELECT	COUNT(*) AS Counts
FROM (	SELECT * 
		FROM sys.dm_exec_describe_first_result_set (N'SELECT * FROM ' + @DatabaseName + '.' + @SchemaName1 + '.' + @TableName1 , NULL, 0) 
		WHERE name NOT IN ('DMLType')) Live 
	FULL OUTER JOIN (	SELECT * 
						FROM sys.dm_exec_describe_first_result_set (N'SELECT * FROM ' + @DatabaseName + '.' + @SchemaName2 + '.' + @TableName2, NULL, 0) 
						WHERE name NOT IN ('DMLType')) Prep 
		ON Live.name = Prep.name 
WHERE (Live.is_nullable <> Prep.is_nullable
		OR live.system_type_name <> prep.system_type_name
		OR live.is_identity_column <> prep.is_identity_column
		OR Live.max_length <> Prep.max_length
		OR Live.precision <> Prep.precision
		OR Live.collation_name <> Prep.collation_name
		OR Live.scale <> Prep.scale
		OR Live.is_part_of_unique_key <> Prep.is_part_of_unique_key
		OR Live.name IS NULL
		OR Prep.name IS NULL))
+ --indexes
(SELECT COUNT(*)
FROM (
		SELECT * 
		FROM DDI.fnActualIndexStructuresForTable(@DatabaseName,@SchemaName1,@TableName1, @DiffBetTableNames, @PartitionColumnToReplaceInPK)
		WHERE NOT EXISTS (  SELECT 'True' 
                            FROM DDI.IndexesNotInMetadata INIM 
                            WHERE DatabaseName = INIM.DatabaseName
                                AND SchemaName = INIM.SchemaName
                                AND TableName = INIM.TableName
                                AND INIM.IndexName = IndexName)
		EXCEPT
		SELECT *
		FROM DDI.fnActualIndexStructuresForTable(@DatabaseName,@SchemaName2,@TableName2, @DiffBetTableNames, @PartitionColumnToReplaceInPK)
		WHERE NOT EXISTS (  SELECT 'True' 
                            FROM DDI.IndexesNotInMetadata INIM 
                            WHERE DatabaseName = INIM.DatabaseName
                                AND SchemaName = INIM.SchemaName
                                AND TableName = INIM.TableName
                                AND INIM.IndexName = IndexName))x)
+ --constraints
(SELECT COUNT(*)
FROM (
		SELECT * 
		FROM DDI.fnActualConstraintsForTable(@DatabaseName,@SchemaName1,@TableName1, @DiffBetTableNames)
		EXCEPT
		SELECT *
		FROM DDI.fnActualConstraintsForTable(@DatabaseName,@SchemaName2,@TableName2, @DiffBetTableNames))x) AS Counts
)


GO
