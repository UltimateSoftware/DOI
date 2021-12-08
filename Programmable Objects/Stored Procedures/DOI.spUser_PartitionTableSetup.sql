
IF OBJECT_ID('[DOI].[spUser_PartitionTableSetup]') IS NOT NULL
	DROP PROCEDURE [DOI].[spUser_PartitionTableSetup];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spUser_PartitionTableSetup]
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME,
    @TableName SYSNAME,
    @PartitionFunctionName SYSNAME,
    @PartitionColumnDataType SYSNAME,
    @PartitionYearlyOrMonthly VARCHAR(10),
    @PartitioningNumOfFutureIntervals TINYINT,
    @PartitioningInitialDate DATE,
    @PartitionSchemeName SYSNAME,
    @PartitionColumnName SYSNAME



AS

/*
    exec [DOI].[spUser_PartitionTableSetup]
        @DAtabaseName = 'PaymentReporting'
*/

EXEC [DOI].spImportMetadata
    @DatabaseName = @DatabaseName

DECLARE @MinValueOfDataType DATE = CASE WHEN @PartitionColumnDataType = 'DATETIME2' THEN '0001-01-01' WHEN @PartitionColumnDataType = 'DATETIME' THEN '1900-01-01' END

EXEC('
IF NOT EXISTS(SELECT ''True'' FROM ' + @DatabaseName + '.sys.columns c INNER JOIN ' + @DatabaseName + '.sys.tables t ON c.object_id = t.object_id WHERE T.NAME = ''' + @TableName + ''' AND c.name = ''UpdatedUtcDt'')
BEGIN
   ALTER TABLE ' + @DatabaseName + '.' + @SchemaName + '.' + @TableName + ' ADD UpdatedUtcDt DATETIME2 NOT NULL CONSTRAINT Def_' + @TableName + '_UpdatedUtcDt DEFAULT SYSDATETIME()
END
') 

IF NOT EXISTS (SELECT 'True' FROM DOI.PartitionFunctions WHERE DatabaseName = @DatabaseName AND PartitionFunctionName = @PartitionFunctionName)
BEGIN
    INSERT INTO DOI.PartitionFunctions(DatabaseName, PartitionFunctionName, PartitionFunctionDataType, BoundaryInterval, NumOfFutureIntervals, InitialDate, UsesSlidingWindow, SlidingWindowSize, IsDeprecated, PartitionSchemeName)
    VALUES(   @DatabaseName, @PartitionFunctionName, @PartitionColumnDataType, @PartitionYearlyOrMonthly, @PartitioningNumOfFutureIntervals, @PartitioningInitialDate, 0, NULL, 0, @PartitionSchemeName)
END

UPDATE T
SET PartitionColumn = @PartitionColumnName,
    T.PartitionFunctionName = @PartitionFunctionName,
    T.IntendToPartition = 1,
    T.ReadyToQueue = 1
--SELECT *
FROM DOI.Tables T
WHERE DatabaseName = @DatabaseName
    AND SchemaName = @SchemaName
    AND TableName = @TableName

UPDATE IRS
SET IRS.PartitionFunction_Desired = @PartitionFunctionName,
    IRS.PartitionColumn_Desired = @PartitionColumnName,
    IRS.OptionStatisticsIncremental_Desired = 1,
    IRS.KeyColumnList_Desired = IRS.KeyColumnList_Desired + CASE WHEN IRS.KeyColumnList_Desired NOT LIKE '%' + @PartitionColumnName + '%' THEN ',' + @PartitionColumnName + ' ASC' ELSE '' END
--SELECT KeyColumnList_Desired, KeyColumnList_Desired + CASE WHEN IRS.KeyColumnList_Desired NOT LIKE '%EjhJobEffDate%' THEN ',EjhJobEffDate' ELSE '' END
FROM DOI.IndexesRowStore IRS
WHERE DatabaseName = @DatabaseName
    AND SchemaName = @SchemaName
    AND TableName = @TableName

UPDATE ICS
SET ICS.PartitionFunction_Desired = @PartitionFunctionName,
    ICS.PartitionColumn_Desired = @PartitionColumnName,
    ICS.ColumnList_Desired = ICS.ColumnList_Desired + CASE WHEN ICS.ColumnList_Desired NOT LIKE  '%' + @PartitionColumnName + '%' THEN ',' + @PartitionColumnName + ' ASC' ELSE '' END
--SELECT *
FROM DOI.IndexesColumnStore ICS
WHERE DatabaseName = @DatabaseName
    AND SchemaName = @SchemaName
    AND TableName = @TableName

--refresh storage containers in case the partition functions, schemes, filegroups, or files are new.
EXEC doi.spRefreshStorageContainers_All
    @DatabaseName = @DatabaseName



EXEC DOI.spRefreshMetadata_Run_All 
    @DatabaseName = @DatabaseName

GO