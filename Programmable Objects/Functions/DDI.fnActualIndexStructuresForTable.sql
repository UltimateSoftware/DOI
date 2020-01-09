IF OBJECT_ID('[DDI].[fnActualIndexStructuresForTable]') IS NOT NULL
	DROP FUNCTION [DDI].[fnActualIndexStructuresForTable];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE         FUNCTION [DDI].[fnActualIndexStructuresForTable](
    @DatabaseName SYSNAME,
	@SchemaName SYSNAME,
	@TableName SYSNAME,
	@NameStringReplace SYSNAME = NULL,
	@PartitionColumnToReplace SYSNAME = NULL)
RETURNS TABLE
AS RETURN
(

/*
SELECT * 
FROM DDI.fnActualIndexStructuresForTable('PaymentReporting', 'dbo','LiabilityCollections', '_NewPartitionedTableFromPrep', 'PayUtcDt')

SELECT *
FROM DDI.fnActualIndexStructuresForTable('PaymentReporting', 'dbo','LiabilityCollections_NewPartitionedTableFromPrep', '_NewPartitionedTableFromPrep', 'PayUtcDt')
*/
SELECT 
    d.name AS DatabaseName
    ,s.name AS SchemaName
    ,REPLACE(t.name, @NameStringReplace, SPACE(0)) AS TableName
	,REPLACE(i.name, @NameStringReplace, SPACE(0)) AS IndexName
	--,i.type
	,i.type_desc
	,i.is_unique
	,i.ignore_dup_key
	,i.is_primary_key
	,i.is_unique_constraint
	,i.is_disabled
	,i.is_hypothetical
	,i.has_filter
	,i.filter_definition
    ,i.key_column_list AS IndexKeys
    ,i.included_column_list AS IncludedColumns 
FROM DDI.SysIndexes i
    INNER JOIN DDI.SysDatabases d ON d.database_id = i.database_id
	INNER JOIN DDI.SysTables t ON t.database_id = i.database_id
        AND t.object_id = i.object_id
	INNER JOIN DDI.SysSchemas s ON s.database_id = t.database_id
        AND s.schema_id = t.schema_id
WHERE d.name = @DatabaseName
    AND s.name = @SchemaName
	AND t.name = @TableName)
GO
