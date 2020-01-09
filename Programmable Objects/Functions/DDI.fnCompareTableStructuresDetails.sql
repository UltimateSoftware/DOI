IF OBJECT_ID('[DDI].[fnCompareTableStructuresDetails]') IS NOT NULL
	DROP FUNCTION [DDI].[fnCompareTableStructuresDetails];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE     FUNCTION [DDI].[fnCompareTableStructuresDetails](
    @DatabaseName SYSNAME,
	@SchemaName1 SYSNAME,
	@TableName1 SYSNAME,
	@SchemaName2 SYSNAME,
	@TableName2 SYSNAME,
	@DiffBetTableNames SYSNAME,
	@PartitionColumnToReplaceInPK SYSNAME)
RETURNS TABLE

AS

/*
    select * from DDI.fnCompareTableStructuresDetails(
    'PaymentReporting',
    'dbo',
    'Bai2BankTransactions',
    'dbo',
    'Bai2BankTransactions_NewPartitionedTableFromPrep',
    '_NewPartitionedTableFromPrep',
    'TransactionSysUtcDt')
*/
RETURN (
        SELECT *
        FROM (  SELECT  AT.DatabaseName,
                        ISNULL(AT.TableName, NPT.TableName) AS TableName,
                        ISNULL(AT.IndexName, NPT.IndexName) AS IndexName,
                        CASE 
                            WHEN ISNULL(AT.type_desc, '') <> ISNULL(NPT.type_desc, '') 
                            THEN 'TypeDiff:  Actual Table:  ' + ISNULL(AT.type_desc, '') + '// New Table:  ' + ISNULL(NPT.type_desc, '') 
                            ELSE ''
                        END + 
                        CASE 
                            WHEN ISNULL(CAST(AT.is_unique AS CHAR(1)), '') <> ISNULL(CAST(NPT.is_unique AS CHAR(1)), '') 
                            THEN 'IsUniqueDiff:  Actual Table:  ' + ISNULL(CAST(AT.is_unique AS CHAR(1)), '') + '// New Table:  ' + ISNULL(CAST(NPT.is_unique AS CHAR(1)), '') 
                            ELSE ''
                        END +
                        CASE 
                            WHEN ISNULL(CAST(AT.ignore_dup_key AS CHAR(1)), '') <> ISNULL(CAST(NPT.ignore_dup_key AS CHAR(1)), '') 
                            THEN 'OptionIgnoreDupKeyDiff:  Actual Table:  ' + ISNULL(CAST(AT.ignore_dup_key AS CHAR(1)), '') + '// New Table:  ' + ISNULL(CAST(NPT.ignore_dup_key AS CHAR(1)), '') 
                            ELSE ''
                        END +
                        CASE 
                            WHEN ISNULL(CAST(AT.is_primary_key AS CHAR(1)), '') <> ISNULL(CAST(NPT.is_primary_key AS CHAR(1)), '') 
                            THEN 'IsPrimaryKeyDiff:  Actual Table:  ' + ISNULL(CAST(AT.is_primary_key AS CHAR(1)), '') + '// New Table:  ' + ISNULL(CAST(NPT.is_primary_key AS CHAR(1)), '') 
                            ELSE ''
                        END +
                        CASE 
                            WHEN ISNULL(CAST(AT.is_unique_constraint AS CHAR(1)), '') <> ISNULL(CAST(NPT.is_unique_constraint AS CHAR(1)), '') 
                            THEN 'IsUniqueConstraintDiff:  Actual Table:  ' + ISNULL(CAST(AT.is_unique_constraint AS CHAR(1)), '') + '// New Table:  ' + ISNULL(CAST(NPT.is_unique_constraint AS CHAR(1)), '') 
                            ELSE ''
                        END +
                        CASE 
                            WHEN ISNULL(CAST(AT.is_disabled AS CHAR(1)), '') <> ISNULL(CAST(NPT.is_disabled AS CHAR(1)), '') 
                            THEN 'IsDisabledDiff:  Actual Table:  ' + ISNULL(CAST(AT.is_disabled AS CHAR(1)), '') + '// New Table:  ' + ISNULL(CAST(NPT.is_disabled AS CHAR(1)), '') 
                            ELSE ''
                        END +
                        CASE 
                            WHEN ISNULL(CAST(AT.is_hypothetical AS CHAR(1)), '') <> ISNULL(CAST(NPT.is_hypothetical AS CHAR(1)), '') 
                            THEN 'IsHypotheticalDiff:  Actual Table:  ' + ISNULL(CAST(AT.is_hypothetical AS CHAR(1)), '') + '// New Table:  ' + ISNULL(CAST(NPT.is_hypothetical AS CHAR(1)), '') 
                            ELSE ''
                        END +
                        CASE 
                            WHEN ISNULL(CAST(AT.has_filter AS CHAR(1)), '') <> ISNULL(CAST(NPT.has_filter AS CHAR(1)), '') 
                            THEN 'IsFilteredDiff:  Actual Table:  ' + ISNULL(CAST(AT.has_filter AS CHAR(1)), '') + '// New Table:  ' + ISNULL(CAST(NPT.has_filter AS CHAR(1)), '') 
                            ELSE ''
                        END +
                        CASE 
                            WHEN ISNULL(AT.filter_definition, '') <> ISNULL(NPT.filter_definition, '') 
                            THEN 'FilterPredicateDiff:  Actual Table:  ' + ISNULL(AT.filter_definition, '') + '// New Table:  ' + ISNULL(NPT.filter_definition, '') 
                            ELSE ''
                        END +
                        CASE 
                            WHEN ISNULL(AT.IndexKeys, '') <> ISNULL(NPT.IndexKeys, '') 
                            THEN 'KeyColumnListDiff:  Actual Table:  ' + ISNULL(AT.IndexKeys, '') + '// New Table:  ' + ISNULL(NPT.IndexKeys, '') 
                            ELSE ''
                        END +
                        CASE 
                            WHEN ISNULL(AT.IncludedColumns, '') <> ISNULL(NPT.IncludedColumns, '') 
                            THEN 'IncludedColumnListDiff:  Actual Table:  ' + ISNULL(AT.IncludedColumns, '') + '// New Table:  ' + ISNULL(NPT.IncludedColumns, '') 
                            ELSE ''
                        END COLLATE DATABASE_DEFAULT AS SchemaDifferences
                FROM DDI.fnActualIndexStructuresForTable(@DatabaseName,@SchemaName1,@TableName1, @DiffBetTableNames, @PartitionColumnToReplaceInPK) AT
                    FULL OUTER JOIN DDI.fnActualIndexStructuresForTable(@DatabaseName,@SchemaName2,@TableName2, @DiffBetTableNames, @PartitionColumnToReplaceInPK) NPT
                        ON AT.TableName = NPT.TableName
                            AND AT.IndexName = NPT.IndexName) x
        WHERE EXISTS (  SELECT *
                        FROM (
                                SELECT * 
                                FROM DDI.fnActualIndexStructuresForTable(@DatabaseName,@SchemaName1,@TableName1, @DiffBetTableNames, @PartitionColumnToReplaceInPK)
                                WHERE TableName = @TableName1
                                EXCEPT
                                SELECT *
                                FROM DDI.fnActualIndexStructuresForTable(@DatabaseName,@SchemaName2,@TableName2, @DiffBetTableNames, @PartitionColumnToReplaceInPK)
                                WHERE TableName = @TableName1)Diff
                        WHERE Diff.TableName = x.TableName
                            AND Diff.IndexName = x.IndexName)
)
GO
