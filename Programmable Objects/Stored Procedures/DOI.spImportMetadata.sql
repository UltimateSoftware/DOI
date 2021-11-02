
IF OBJECT_ID('[DOI].[spImportMetadata]') IS NOT NULL
	DROP PROCEDURE [DOI].[spImportMetadata];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spImportMetadata]
    @DatabaseName NVARCHAR(128) = NULL,
    @Debug BIT = 0

AS

/*
    exec [DOI].[spImportMetadata]
        @DAtabaseName = 'PaymentReporting',
        @Debug = 1
*/

--partition functions, tables, indexes, statistics (partitions?)

DECLARE @SQL VARCHAR(MAX) = ''

SET @SQL += '

IF NOT EXISTS(SELECT ''True'' FROM DOI.Databases WHERE DatabaseName = ''' + @DatabaseName + ''')
BEGIN
    INSERT INTO DOI.Databases
    VALUES (''' + @DatabaseName + ''')
END
ELSE
BEGIN
    RAISERROR(''Database already exists in metadata'', 10, 1)
END
GO

IF NOT EXISTS(SELECT ''True'' FROM DOI.DOISettings WHERE DatabaseName = ''' + @DatabaseName + ''')
BEGIN
    EXEC DOI.spRefreshMetadata_Setup_DOISettings @DatabaseName = ''' + @DatabaseName + '''
END
ELSE
BEGIN
    RAISERROR(''DOISettings already exist in metadata for the ' + @DatabaseName + ' database.'', 10, 1)
END
GO
'
    
SET @SQL += '

IF NOT EXISTS(SELECT ''True'' FROM DOI.PartitionFunctions WHERE DatabaseName = ''' + @DatabaseName + ''')
BEGIN
    DECLARE @PartitionFunctions TABLE (
        [DatabaseName] [sys].[sysname] NOT NULL,
        [PartitionFunctionName] [sys].[sysname] NOT NULL,
        [PartitionFunctionDataType] [sys].[sysname] NOT NULL,
        [BoundaryInterval] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [InitialDate] [date] NOT NULL)

    INSERT INTO @PartitionFunctions(DatabaseName, PartitionFunctionName, PartitionFunctionDataType, BoundaryInterval, InitialDate)
    SELECT ''' + @DatabaseName + ''', 
            name, 
            ''DATETIME2'', 
            CASE 
                WHEN x.DateDifference IN (365, 366)
                THEN ''Yearly''
                WHEN x.DateDifference IN (29, 30, 31)
                THEN ''Monthly''
                ELSE ''Error''
            END AS BoundaryInterval,
            prv.InitialDate
    FROM ' + @DatabaseName + '.sys.partition_functions pf
        CROSS APPLY (   SELECT CAST(MIN(value) AS DATE) AS InitialDate 
                        FROM ' + @DatabaseName + '.sys.partition_range_values prv 
                        WHERE pf.function_id = prv.function_id) prv
        CROSS APPLY (   SELECT TOP 1 
                            CAST(value AS DATETIME) AS Boundary, 
                            CAST(LEAD(value, 1) OVER (PARTITION BY function_id ORDER BY value) AS DATETIME) AS NextBoundary,
                            DATEDIFF(dd, CAST(value AS DATETIME), CAST(LEAD(value, 1) OVER (PARTITION BY function_id ORDER BY value) AS DATETIME)) AS DateDifference
                        FROM ' + @DatabaseName + '.sys.partition_range_values prv 
                        WHERE prv.function_id = pf.function_id 
                        ORDER BY value) x
    WHERE x.DateDifference IN (29, 30, 31, 365, 366)

    INSERT INTO DOI.PartitionFunctions(DatabaseName, PartitionFunctionName, PartitionFunctionDataType, BoundaryInterval, InitialDate, NumOfFutureIntervals, UsesSlidingWindow, IsDeprecated)
    SELECT DatabaseName, PartitionFunctionName, PartitionFunctionDataType, BoundaryInterval, InitialDate, 0, 0, 0 
    FROM @PartitionFunctions
END
ELSE
BEGIN
    RAISERROR(''PartitionFunctions already exist in metadata for the ' + @DatabaseName + ' database.'', 10, 1)
END
GO
'
    
SET @SQL += '
IF NOT EXISTS(SELECT ''True'' FROM DOI.CheckConstraints WHERE DatabaseName = ''' + @DatabaseName + ''')
BEGIN
    DECLARE @CheckConstraints TABLE (
        [DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [ColumnName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
        [CheckDefinition] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [IsDisabled] [bit] NOT NULL,
        [CheckConstraintName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL)

    INSERT INTO @CheckConstraints(DatabaseName, SchemaName, TableName, ColumnName, CheckDefinition, IsDisabled, CheckConstraintName)
    SELECT ''' + @DatabaseName + ''', s.name, t.name, c.name, cc.definition, cc.is_disabled, cc.name
    FROM ' + @DatabaseName + '.sys.check_constraints cc
        INNER JOIN ' + @DatabaseName + '.sys.schemas s ON cc.schema_id = s.schema_id
        INNER JOIN ' + @DatabaseName + '.sys.tables t ON cc.parent_object_id = t.object_id
        INNER JOIN ' + @DatabaseName + '.sys.columns c ON cc.parent_object_id = c.object_id
            AND cc.parent_column_id = c.column_id

    INSERT INTO DOI.CheckConstraints(DatabaseName, SchemaName, TableName, ColumnName, CheckDefinition, IsDisabled, CheckConstraintName)
    SELECT * FROM @CheckConstraints
END
ELSE
BEGIN
    RAISERROR(''CheckConstraints already exist in metadata for the ' + @DatabaseName + ' database.'', 10, 1)
END
GO
'
    
SET @SQL += '

IF NOT EXISTS(SELECT ''True'' FROM DOI.DefaultConstraints WHERE DatabaseName = ''' + @DatabaseName + ''')
BEGIN
    DECLARE @DefaultConstraints TABLE (
        [DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [ColumnName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [DefaultDefinition] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [DefaultConstraintName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)

    INSERT INTO @DefaultConstraints([DatabaseName], [SchemaName], [TableName], [ColumnName], [DefaultDefinition], [DefaultConstraintName])
    SELECT ''' + @DatabaseName + ''', s.name, t.name, c.name, dc.definition, dc.name
    FROM ' + @DatabaseName + '.sys.default_constraints dc
        INNER JOIN ' + @DatabaseName + '.sys.schemas s ON dc.schema_id = s.schema_id
        INNER JOIN ' + @DatabaseName + '.sys.tables t ON dc.parent_object_id = t.object_id
        INNER JOIN ' + @DatabaseName + '.sys.columns c ON dc.parent_object_id = c.object_id
            AND dc.parent_column_id = c.column_id

    INSERT INTO DOI.DefaultConstraints([DatabaseName], [SchemaName], [TableName], [ColumnName], [DefaultDefinition], [DefaultConstraintName])
    SELECT * FROM @DefaultConstraints
END
ELSE
BEGIN
    RAISERROR(''DefaultConstraints already exist in metadata for the ' + @DatabaseName + ' database.'', 10, 1)
END
GO
'
    
SET @SQL += '

IF NOT EXISTS(SELECT ''True'' FROM DOI.[Tables] WHERE DatabaseName = ''' + @DatabaseName + ''')
BEGIN
    DECLARE @Tables TABLE (
        [DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [PartitionFunctionName_Desired] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
        [PartitionColumn] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
        [IntendToPartition] [bit] NOT NULL DEFAULT ((0)),
        [ReadyToQueue] [bit] NOT NULL DEFAULT ((0)))

    INSERT INTO @Tables ([DatabaseName], [SchemaName], [TableName], [PartitionColumn], [IntendToPartition], [ReadyToQueue], [PartitionFunctionName_Desired])
    SELECT ''' + @DatabaseName + ''', s.name, t.name, PartitionColumnName, CASE WHEN p.PartitionFunctionName IS NOT NULL THEN 1 ELSE 0 END, 1, p.PartitionFunctionName
    FROM ' + @DatabaseName + '.sys.tables t
        INNER JOIN ' + @DatabaseName + '.sys.schemas s ON t.schema_id = s.schema_id
        OUTER APPLY (   SELECT pf.name AS PartitionFunctionName, c.name AS PartitionColumnName
                        FROM ' + @DatabaseName + '.sys.indexes i 
                            INNER JOIN ' + @DatabaseName + '.sys.partition_schemes ps ON i.data_space_id = ps.data_space_id 
                            INNER JOIN ' + @DatabaseName + '.sys.partition_functions pf ON pf.function_id = ps.function_id
                            INNER JOIN ' + @DatabaseName + '.sys.index_columns ic ON i.object_id = ic.object_id
                                AND i.index_id = ic.index_id
                            INNER JOIN ' + @DatabaseName + '.sys.columns c ON i.object_id = c.object_id
                                AND ic.column_id = c.column_id
                        WHERE i.object_id = t.object_id 
                            AND i.type IN (0,1)
                            AND ic.partition_ordinal >= 1) p

    INSERT INTO DOI.[Tables]([DatabaseName], [SchemaName], [TableName], [PartitionFunctionName], [PartitionColumn], [IntendToPartition], [ReadyToQueue])
    SELECT * FROM @Tables
END
ELSE
BEGIN
    RAISERROR(''Tables already exist in metadata for the ' + @DatabaseName + ' database.'', 10, 1)
END
GO
'
    
SET @SQL += '

IF NOT EXISTS(SELECT ''True'' FROM DOI.IndexesColumnStore WHERE DatabaseName = ''' + @DatabaseName + ''')
BEGIN
    DECLARE @IndexesColumnStore TABLE (
        [DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [IndexName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [IsClustered_Desired] [bit] NOT NULL,
        [ColumnList_Desired] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
        [IsFiltered_Desired] [bit] NOT NULL,
        [FilterPredicate_Desired] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
        [OptionDataCompression_Desired] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL DEFAULT (''COLUMNSTORE''),
        [OptionDataCompressionDelay_Desired] [int] NOT NULL,
        [PartitionFunction_Desired] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
        [PartitionColumn_Desired] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
'
    
SET @SQL += '

    INSERT INTO @IndexesColumnStore([DatabaseName], [SchemaName], [TableName], [IndexName], [IsClustered_Desired], [ColumnList_Desired], [IsFiltered_Desired], [FilterPredicate_Desired], [OptionDataCompression_Desired], [OptionDataCompressionDelay_Desired], [PartitionFunction_Desired], [PartitionColumn_Desired])
    SELECT ''' + @DatabaseName + ''', s.name, t.name, i.name, CASE WHEN i.type_desc LIKE ''%NONCLUSTERED%'' THEN 0 ELSE 1 END, CASE WHEN i.type_desc NOT LIKE ''%NONCLUSTERED%'' THEN NULL ELSE STUFF(x.IndexIncludedColumnList, LEN(x.IndexIncludedColumnList), 1, SPACE(0)) END, i.has_filter, i.filter_definition, dc.data_compression_desc, i.compression_delay, p.PartitionFunctionName, p.PartitionColumnName
    FROM ' + @DatabaseName + '.sys.indexes i
        INNER JOIN ' + @DatabaseName + '.sys.tables t ON i.object_id = t.object_id
        INNER JOIN ' + @DatabaseName + '.sys.schemas s ON t.schema_id = s.schema_id
        CROSS APPLY (   SELECT data_compression_desc
                        FROM ' + @DatabaseName + '.sys.partitions p 
                        WHERE p.object_id = t.object_id
                            AND p.index_id = i.index_id
                            AND p.partition_number = 1) dc
        CROSS APPLY (   SELECT C.NAME + '',''
                        FROM ' + @DatabaseName + '.sys.index_columns ic 
                            INNER JOIN ' + @DatabaseName + '.sys.columns c ON c.column_id = ic.column_id
                                AND c.object_id = ic.object_id
                        WHERE i.object_id = ic.object_id
                            AND i.index_id = ic.index_id
                            AND ic.is_included_column = 1
							AND ic.key_ordinal = 0
							AND ic.partition_ordinal = 0
                        ORDER BY ic.key_ordinal
                        FOR XML PATH('''')) x(IndexIncludedColumnList)
        OUTER APPLY (   SELECT pf.name AS PartitionFunctionName, c.name AS PartitionColumnName
                        FROM ' + @DatabaseName + '.sys.indexes i 
                            INNER JOIN ' + @DatabaseName + '.sys.partition_schemes ps ON i.data_space_id = ps.data_space_id 
                            INNER JOIN ' + @DatabaseName + '.sys.partition_functions pf ON pf.function_id = ps.function_id
                            INNER JOIN ' + @DatabaseName + '.sys.index_columns ic ON i.object_id = ic.object_id
                                AND i.index_id = ic.index_id
                            INNER JOIN ' + @DatabaseName + '.sys.columns c ON i.object_id = c.object_id
                                AND ic.column_id = c.column_id
                        WHERE i.object_id = t.object_id 
                            AND i.type IN (0,1)
                            AND ic.partition_ordinal >= 1) p
    WHERE i.type_desc LIKE ''%COLUMNSTORE%''

    INSERT INTO DOI.IndexesColumnStore([DatabaseName], [SchemaName], [TableName], [IndexName], [IsClustered_Desired], [ColumnList_Desired], [IsFiltered_Desired], [FilterPredicate_Desired], [OptionDataCompression_Desired], [OptionDataCompressionDelay_Desired], [PartitionFunction_Desired], [PartitionColumn_Desired], [Storage_Desired])
    SELECT *, SPACE(0) FROM @IndexesColumnStore
END
ELSE
BEGIN
    RAISERROR(''IndexesColumnStore already exist in metadata for the ' + @DatabaseName + ' database.'', 10, 1)
END
GO
'
    
SET @SQL += '

IF NOT EXISTS(SELECT ''True'' FROM DOI.IndexesRowStore WHERE DatabaseName = ''' + @DatabaseName + ''')
BEGIN
    DECLARE @IndexesRowStore TABLE (
        [DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [IndexName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [IsUnique_Desired] [bit] NOT NULL,
        [IsPrimaryKey_Desired] [bit] NOT NULL,
        [IsClustered_Desired] [bit] NOT NULL,
        [KeyColumnList_Desired] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [IncludedColumnList_Desired] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
        [IsFiltered_Desired] [bit] NOT NULL,
        [FilterPredicate_Desired] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
        [Fillfactor_Desired] [tinyint] NOT NULL DEFAULT ((90)),
        [OptionPadIndex_Desired] [bit] NOT NULL DEFAULT ((1)),
        [OptionStatisticsNoRecompute_Desired] [bit] NOT NULL DEFAULT ((0)),
        [OptionStatisticsIncremental_Desired] [bit] NOT NULL DEFAULT ((0)),
        [OptionIgnoreDupKey_Desired] [bit] NOT NULL DEFAULT ((0)),
        [OptionResumable_Desired] [bit] NOT NULL DEFAULT ((0)),
        [OptionMaxDuration_Desired] [smallint] NOT NULL DEFAULT ((0)),
        [OptionAllowRowLocks_Desired] [bit] NOT NULL DEFAULT ((1)),
        [OptionAllowPageLocks_Desired] [bit] NOT NULL DEFAULT ((1)),
        [OptionDataCompression_Desired] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL DEFAULT (''PAGE''),
        [PartitionFunction_Desired] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
        [PartitionColumn_Desired] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
        [Storage_Desired] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL)'
    
SET @SQL += '

    INSERT INTO @IndexesRowStore([DatabaseName], [SchemaName], [TableName], [IndexName], [IsUnique_Desired], [IsPrimaryKey_Desired], [IsClustered_Desired], [KeyColumnList_Desired], [IncludedColumnList_Desired], [IsFiltered_Desired], [FilterPredicate_Desired], [Fillfactor_Desired], [OptionPadIndex_Desired], [OptionStatisticsNoRecompute_Desired], [OptionStatisticsIncremental_Desired], [OptionIgnoreDupKey_Desired], [OptionResumable_Desired], [OptionMaxDuration_Desired], [OptionAllowRowLocks_Desired], [OptionAllowPageLocks_Desired], [OptionDataCompression_Desired], [PartitionFunction_Desired], [PartitionColumn_Desired], [Storage_Desired])
    SELECT ''' + @DatabaseName + ''', s.name, t.name, i.name, i.is_unique, i.is_primary_key, CASE WHEN i.type_desc LIKE ''%NONCLUSTERED%'' THEN 0 ELSE 1 END, STUFF(z.IndexKeyColumnList, LEN(z.IndexKeyColumnList), 1, SPACE(0)), STUFF(x.IndexIncludedColumnList, LEN(x.IndexIncludedColumnList), 1, SPACE(0)), i.has_filter, i.filter_definition, i.fill_factor, i.is_padded, st.no_recompute, st.is_incremental, i.ignore_dup_key, 0, 0, i.allow_row_locks, i.allow_page_locks, dc.data_compression_desc, p.PartitionFunctionName, p.PartitionColumnName, ds.name
    FROM ' + @DatabaseName + '.sys.indexes i
        INNER JOIN ' + @DatabaseName + '.sys.tables t ON i.object_id = t.object_id
        INNER JOIN ' + @DatabaseName + '.sys.schemas s ON t.schema_id = s.schema_id
        INNER JOIN ' + @DatabaseName + '.sys.data_spaces ds on i.data_space_id = ds.data_space_id
        CROSS APPLY (   SELECT C.NAME + CASE WHEN ic.is_descending_key = 1 THEN '' DESC'' ELSE '' ASC'' END + '',''
                        FROM ' + @DatabaseName + '.sys.index_columns ic 
                            INNER JOIN ' + @DatabaseName + '.sys.columns C ON C.column_id = ic.column_id
                                AND C.object_id = ic.object_id
                        WHERE i.object_id = IC.object_id
                            AND i.index_id = IC.index_id
                            AND ic.is_included_column = 0
	                        AND ic.key_ordinal > 0
                        ORDER BY ic.key_ordinal
                        FOR XML PATH('''')) z(IndexKeyColumnList)
        CROSS APPLY (   SELECT c.NAME + '',''
                        FROM ' + @DatabaseName + '.sys.index_columns ic 
                            INNER JOIN ' + @DatabaseName + '.sys.columns c ON c.column_id = ic.column_id
                                AND c.object_id = ic.OBJECT_ID
                        WHERE i.object_id = ic.object_id
                            AND i.index_id = ic.index_id
                            AND ic.is_included_column = 1
							AND ic.key_ordinal = 0
							AND ic.partition_ordinal = 0
                        ORDER BY ic.key_ordinal
                        FOR XML PATH('''')) x(IndexIncludedColumnList)
        CROSS APPLY (   SELECT TOP 1 p.data_compression_desc
                        FROM ' + @DatabaseName + '.sys.partitions p
                        WHERE p.object_id = i.object_id
                            AND p.index_id = i.index_id) AS DC
        CROSS APPLY (   SELECT s2.is_incremental, s2.no_recompute
                        FROM ' + @DatabaseName + '.sys.stats s2
                        WHERE s2.object_id = i.object_id
		                    AND s2.stats_id = i.index_id) st'
SET @SQL += '
        OUTER APPLY (   SELECT pf.name AS PartitionFunctionName, c.name AS PartitionColumnName
                        FROM ' + @DatabaseName + '.sys.indexes i 
                            INNER JOIN ' + @DatabaseName + '.sys.partition_schemes ps ON i.data_space_id = ps.data_space_id 
                            INNER JOIN ' + @DatabaseName + '.sys.partition_functions pf ON pf.function_id = ps.function_id
                            INNER JOIN ' + @DatabaseName + '.sys.index_columns ic ON i.object_id = ic.object_id
                                AND i.index_id = ic.index_id
                            INNER JOIN ' + @DatabaseName + '.sys.columns c ON i.object_id = c.object_id
                                AND ic.column_id = c.column_id
                        WHERE i.object_id = t.object_id 
                            AND i.type IN (0,1)
                            AND ic.partition_ordinal >= 1) p
    WHERE i.type_desc NOT LIKE ''%COLUMNSTORE%''

    INSERT INTO DOI.IndexesRowStore([DatabaseName], [SchemaName], [TableName], [IndexName], [IsUnique_Desired], [IsPrimaryKey_Desired], [IsClustered_Desired], [KeyColumnList_Desired], [IncludedColumnList_Desired], [IsFiltered_Desired], [FilterPredicate_Desired], [Fillfactor_Desired], [OptionPadIndex_Desired], [OptionStatisticsNoRecompute_Desired], [OptionStatisticsIncremental_Desired], [OptionIgnoreDupKey_Desired], [OptionResumable_Desired], [OptionMaxDuration_Desired], [OptionAllowRowLocks_Desired], [OptionAllowPageLocks_Desired], [OptionDataCompression_Desired], [PartitionFunction_Desired], [PartitionColumn_Desired], [Storage_Desired])
    SELECT * FROM @IndexesRowStore
END
ELSE
BEGIN
    RAISERROR(''IndexesRowStore already exist in metadata for the ' + @DatabaseName + ' database.'', 10, 1)
END
GO
'
    
SET @SQL += '
IF NOT EXISTS(SELECT ''True'' FROM DOI.IndexColumns WHERE DatabaseName = ''' + @DatabaseName + ''')
BEGIN
    DECLARE @IndexColumns TABLE (
        [DatabaseName] [sys].[sysname] NOT NULL,
        [SchemaName] [sys].[sysname] NOT NULL,
        [TableName] [sys].[sysname] NOT NULL,
        [IndexName] [sys].[sysname] NOT NULL,
        [ColumnName] [sys].[sysname] NOT NULL,
        [IsKeyColumn] [bit] NOT NULL,
        [KeyColumnPosition] [smallint] NULL,
        [IsIncludedColumn] [bit] NOT NULL,
        [IncludedColumnPosition] [smallint] NULL)

    INSERT INTO @IndexColumns([DatabaseName], [SchemaName], [TableName], [IndexName], [ColumnName], [IsKeyColumn], [KeyColumnPosition], [IsIncludedColumn], [IncludedColumnPosition])
    SELECT ''' + @DatabaseName + ''', s.name, t.name, i.name, c.name, CASE WHEN ic.key_ordinal > 0 THEN 1 ELSE 0 END, ic.key_ordinal, ic.is_included_column, NULL
    FROM ' + @DatabaseName + '.sys.index_columns ic
        INNER JOIN ' + @DatabaseName + '.sys.indexes i ON i.object_id = ic.object_id
            AND i.index_id = ic.index_id
        INNER JOIN ' + @DatabaseName + '.sys.columns c ON ic.object_id = c.object_id
            AND ic.column_id = c.column_id
        INNER JOIN ' + @DatabaseName + '.sys.tables t ON i.object_id = t.object_id
        INNER JOIN ' + @DatabaseName + '.sys.schemas s ON t.schema_id = s.schema_id

    INSERT INTO DOI.IndexColumns([DatabaseName], [SchemaName], [TableName], [IndexName], [ColumnName], [IsKeyColumn], [KeyColumnPosition], [IsIncludedColumn], [IncludedColumnPosition])
    SELECT * FROM @IndexColumns
END
ELSE
BEGIN
    RAISERROR(''IndexColumns already exist in metadata for the ' + @DatabaseName + ' database.'', 10, 1)
END
GO'

SET @SQL += '

IF NOT EXISTS(SELECT ''True'' FROM DOI.IndexPartitionsColumnStore WHERE DatabaseName = ''' + @DatabaseName + ''')
BEGIN
    DECLARE @IndexPartitionsColumnStore TABLE (
        [DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [IndexName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [PartitionNumber] [smallint] NOT NULL,
        [OptionDataCompression] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL DEFAULT (''COLUMNSTORE''),
        [PartitionType] [VARCHAR] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL DEFAULT (''ColumnStore''))

    INSERT INTO @IndexPartitionsColumnStore([DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber], [OptionDataCompression], [PartitionType])
    SELECT ''' + @DatabaseName + ''', s.name, t.name, i.name, p.partition_number, p.data_compression_desc, ''ColumnStore''
    FROM ' + @DatabaseName + '.sys.partitions p
        INNER JOIN ' + @DatabaseName + '.sys.tables t ON p.object_id = t.object_id
        INNER JOIN ' + @DatabaseName + '.sys.schemas s ON t.schema_id = s.schema_id
        INNER JOIN ' + @DatabaseName + '.sys.indexes i ON p.object_id = i.object_id
            AND p.index_id = i.index_id
    WHERE i.type_desc IN (''NONCLUSTERED COLUMNSTORE'', ''CLUSTERED COLUMNSTORE'')

    INSERT INTO DOI.IndexPartitionsColumnStore([DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber], [OptionDataCompression], [PartitionType])
    SELECT * FROM @IndexPartitionsColumnStore
END
ELSE
BEGIN
    RAISERROR(''IndexPartitionsColumnStore already exist in metadata for the ' + @DatabaseName + ' database.'', 10, 1)
END
GO
'
    
SET @SQL += '

IF NOT EXISTS(SELECT ''True'' FROM DOI.IndexPartitionsRowStore WHERE DatabaseName = ''' + @DatabaseName + ''')
BEGIN
    DECLARE @IndexPartitionsRowStore TABLE (
        [DatabaseName] [NVARCHAR] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [SchemaName] [NVARCHAR] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [TableName] [NVARCHAR] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [IndexName] [NVARCHAR] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [PartitionNumber] [SMALLINT] NOT NULL,
        [OptionResumable] [BIT] NOT NULL DEFAULT ((0)),
        [OptionMaxDuration] [SMALLINT] NOT NULL DEFAULT ((0)),
        [OptionDataCompression] [NVARCHAR] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL DEFAULT (''PAGE''),
        [PartitionType] [VARCHAR] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL DEFAULT (''RowStore''))

    INSERT INTO @IndexPartitionsRowStore([DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber], [OptionResumable], [OptionMaxDuration], [OptionDataCompression], [PartitionType])
    SELECT ''' + @DatabaseName + ''', s.name, t.name, i.name, p.partition_number, 0, 0, p.data_compression_desc, ''RowStore''
    FROM ' + @DatabaseName + '.sys.partitions p
        INNER JOIN ' + @DatabaseName + '.sys.tables t ON p.object_id = t.object_id
        INNER JOIN ' + @DatabaseName + '.sys.schemas s ON t.schema_id = s.schema_id
        INNER JOIN ' + @DatabaseName + '.sys.indexes i ON p.object_id = i.object_id
            AND p.index_id = i.index_id
    WHERE i.type_desc IN (''NONCLUSTERED'', ''CLUSTERED'')

    INSERT INTO DOI.IndexPartitionsRowStore([DatabaseName], [SchemaName], [TableName], [IndexName], [PartitionNumber], [OptionResumable], [OptionMaxDuration], [OptionDataCompression], [PartitionType])
    SELECT * FROM @IndexPartitionsRowStore
END
ELSE
BEGIN
    RAISERROR(''IndexPartitionsRowStore already exist in metadata for the ' + @DatabaseName + ' database.'', 10, 1)
END
GO'

SET @SQL += '

IF NOT EXISTS(SELECT ''True'' FROM DOI.[Statistics] WHERE DatabaseName = ''' + @DatabaseName + ''')
BEGIN
    DECLARE @Statistics TABLE (
        [DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [SchemaName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [StatisticsName] [sys].[sysname] NOT NULL,
        [StatisticsColumnList_Desired] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [SampleSizePct_Desired] [tinyint] NOT NULL,
        [IsFiltered_Desired] [bit] NOT NULL,
        [FilterPredicate_Desired] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
        [IsIncremental_Desired] [bit] NOT NULL,
        [NoRecompute_Desired] [bit] NOT NULL,
        [ReadyToQueue] [bit] NOT NULL DEFAULT ((0)))

    INSERT INTO @Statistics([DatabaseName], [SchemaName], [TableName], [StatisticsName], [StatisticsColumnList_Desired], [SampleSizePct_Desired], [IsFiltered_Desired], [FilterPredicate_Desired], [IsIncremental_Desired], [NoRecompute_Desired], [ReadyToQueue])
    SELECT ''' + @DatabaseName + ''', s.name, t.name, st.name, STUFF(x.ColumnList, LEN(x.ColumnList), 1, SPACE(0)), ISNULL(sp.persisted_sample_percent, 0), st.has_filter, st.filter_definition, st.is_incremental, st.no_recompute, 0
    FROM ' + @DatabaseName + '.sys.stats st
        INNER JOIN ' + @DatabaseName + '.sys.tables t ON st.object_id = t.object_id
        INNER JOIN ' + @DatabaseName + '.sys.schemas s ON t.schema_id = s.schema_id
        CROSS APPLY (   SELECT c.name + '',''
                        FROM ' + @DatabaseName + '.sys.stats_columns sc 
                            INNER JOIN ' + @DatabaseName + '.sys.columns c ON c.column_id = sc.column_id
                                AND c.object_id = sc.object_id
                        WHERE st.object_id = sc.object_id
                            AND st.stats_id = sc.stats_id
                        ORDER BY sc.stats_column_id
                        FOR XML PATH('''')) x(ColumnList)
        CROSS APPLY ' + @DatabaseName + '.sys.dm_db_stats_properties(st.object_id, st.stats_id) sp 

    INSERT INTO DOI.[Statistics]([DatabaseName], [SchemaName], [TableName], [StatisticsName], [StatisticsColumnList_Desired], [SampleSizePct_Desired], [IsFiltered_Desired], [FilterPredicate_Desired], [IsIncremental_Desired], [NoRecompute_Desired], [ReadyToQueue], [LowerSampleSizeToDesired])
    SELECT *, 0 FROM @Statistics
END
ELSE
BEGIN
    RAISERROR(''Statistics already exist in metadata for the ' + @DatabaseName + ' database.'', 10, 1)
END
GO
'
    
SET @SQL += '
IF NOT EXISTS(SELECT ''True'' FROM DOI.ForeignKeys WHERE DatabaseName = ''' + @DatabaseName + ''')
BEGIN
    DECLARE @ForeignKeys TABLE (
        [DatabaseName] [sys].[sysname] NOT NULL,
        [ParentSchemaName] [sys].[sysname] NOT NULL,
        [ParentTableName] [sys].[sysname] NOT NULL,
        [FKName] [sys].[sysname] NOT NULL DEFAULT (''NameNotUpdatedYet''),
        [ParentColumnList_Desired] [varchar] (MAX) NOT NULL,
        [ReferencedSchemaName] [sys].[sysname] NOT NULL,
        [ReferencedTableName] [sys].[sysname] NOT NULL,
        [ReferencedColumnList_Desired] [varchar] (MAX) NOT NULL)

    INSERT INTO @ForeignKeys([DatabaseName], [ParentSchemaName], [ParentTableName], [ParentColumnList_Desired], [ReferencedSchemaName], [ReferencedTableName], [ReferencedColumnList_Desired], [FKName])
    SELECT ''' + @DatabaseName + ''', ps.name, pt.name, STUFF(pc.ColumnList, LEN(pc.ColumnList), 1, SPACE(0)) , rs.name, rt.name, STUFF(rc.ColumnList, LEN(rc.ColumnList), 1, SPACE(0)), fk.name
    FROM ' + @DatabaseName + '.sys.foreign_keys fk
        INNER JOIN ' + @DatabaseName + '.sys.tables pt ON fk.parent_object_id = pt.object_id
        INNER JOIN ' + @DatabaseName + '.sys.schemas ps ON pt.schema_id = ps.schema_id
        INNER JOIN ' + @DatabaseName + '.sys.tables rt ON fk.referenced_object_id = rt.object_id
        INNER JOIN ' + @DatabaseName + '.sys.schemas rs ON rt.schema_id = rs.schema_id
        CROSS APPLY (   SELECT c.name + '',''
                        FROM ' + @DatabaseName + '.sys.foreign_key_columns fkc 
                            INNER JOIN ' + @DatabaseName + '.sys.columns c ON c.column_id = fkc.parent_column_id
                                AND c.object_id = fkc.parent_object_id
                        WHERE pt.object_id = fkc.parent_object_id
                            AND fkc.constraint_object_id = fk.object_id
                        ORDER BY fkc.constraint_column_id
                        FOR XML PATH('''')) pc(ColumnList)
        CROSS APPLY (   SELECT c.name + '',''
                        FROM ' + @DatabaseName + '.sys.foreign_key_columns fkc 
                            INNER JOIN ' + @DatabaseName + '.sys.columns c ON c.column_id = fkc.referenced_column_id
                                AND c.object_id = fkc.referenced_object_id
                        WHERE rt.object_id = fkc.referenced_object_id
                            AND fkc.constraint_object_id = fk.object_id
                        ORDER BY fkc.constraint_column_id
                        FOR XML PATH('''')) rc(ColumnList)

    INSERT INTO DOI.ForeignKeys([DatabaseName], [ParentSchemaName], [ParentTableName], [ParentColumnList_Desired], [ReferencedSchemaName], [ReferencedTableName], [ReferencedColumnList_Desired], [FKName])
    SELECT [DatabaseName], [ParentSchemaName], [ParentTableName], [ParentColumnList_Desired], [ReferencedSchemaName], [ReferencedTableName], [ReferencedColumnList_Desired], [FKName] FROM @ForeignKeys
END
ELSE
BEGIN
    RAISERROR(''ForeignKeys already exist in metadata for the ' + @DatabaseName + ' database.'', 10, 1)
END
GO
'
IF @Debug = 1
BEGIN
    EXEC DOI.spPrintOutLongSQL 
        @SQLInput = @SQL,
        @VariableName = N'@SQL'
END
ELSE
BEGIN
    EXEC DOI.sp_ExecuteSQLByBatch 
        @SQL = @SQL
END
GO