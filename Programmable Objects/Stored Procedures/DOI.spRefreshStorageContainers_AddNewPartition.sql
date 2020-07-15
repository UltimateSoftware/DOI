USE [$(DatabaseName2)]
GO

IF OBJECT_ID('[DOI].[spRefreshStorageContainers_AddNewPartition]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshStorageContainers_AddNewPartition];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE     PROCEDURE [DOI].[spRefreshStorageContainers_AddNewPartition]
    @DatabaseName SYSNAME,
	@PartitionFunctionName SYSNAME = NULL,
	@Debug BIT = 0
AS

/*
	exec DOI.spRefreshStorageContainers_AddNewPartition
        @DatabaseName = 'PaymentReporting',
        @PartitionFunctionName = 'pfMonthlyUnitTest',
		@Debug = 1
*/

DECLARE @SetNextUseFileGroupSQL VARCHAR(MAX) = '',
		@PartitionFunctionSplitSQL VARCHAR(MAX) = ''

--1. create new file and filegroup
EXEC DOI.spRefreshStorageContainers_FilegroupsAndFiles 
    @DatabaseName = @DatabaseName,
    @Debug = @Debug

--2. alter partition function split range...this includes the SET NEXT filegroup command.
SELECT @PartitionFunctionSplitSQL += PartitionFunctionSplitSQL + CHAR(13) + CHAR(10)
FROM DOI.vwPartitionFunctionPartitions 
WHERE IsDeprecated = 0
    AND DatabaseName = @DatabaseName
    AND PartitionFunctionName = CASE WHEN @PartitionFunctionName IS NULL THEN PartitionFunctionName ELSE @PartitionFunctionName END
	AND IsPartitionMissing = 1


IF @Debug = 1
BEGIN
	EXEC DOI.spPrintOutLongSQL 
		@SQLInput =  @PartitionFunctionSplitSQL,
	    @VariableName = N'@PartitionFunctionSplitSQL' 
END
ELSE
BEGIN
	EXEC(@PartitionFunctionSplitSQL)
END



GO
