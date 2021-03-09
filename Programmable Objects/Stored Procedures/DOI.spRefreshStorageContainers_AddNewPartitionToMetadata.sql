
IF OBJECT_ID('[DOI].[spRefreshStorageContainers_AddNewPartitionsToMetadata]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshStorageContainers_AddNewPartitionsToMetadata];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE     PROCEDURE [DOI].[spRefreshStorageContainers_AddNewPartitionsToMetadata]
    @DatabaseName SYSNAME,
	@PartitionFunctionName SYSNAME = NULL,
	@Debug BIT = 0
AS

/*
	exec DOI.spRefreshStorageContainers_AddNewPartitionsToMetadata
        @DatabaseName = 'PaymentReporting',
        @PartitionFunctionName = 'pfMonthlyUnitTest',
		@Debug = 1
*/

INSERT INTO DOI.IndexPartitionsRowStore ( DatabaseName, SchemaName ,TableName ,IndexName ,PartitionNumber ,OptionResumable ,OptionMaxDuration ,OptionDataCompression )
SELECT IRS.DatabaseName, IRS.SchemaName, IRS.TableName, IRS.IndexName, P.PartitionNumber, IRS.OptionResumable_Desired, IRS.OptionMaxDuration_Desired, IRS.OptionDataCompression_Desired
FROM DOI.Tables T
	INNER JOIN DOI.IndexesRowStore IRS ON IRS.DatabaseName = T.DatabaseName
		AND IRS.SchemaName = T.SchemaName
		AND IRS.TableName = T.TableName
	INNER JOIN DOI.vwPartitionFunctionPartitions P ON P.DatabaseName = T.DatabaseName
		AND p.PartitionFunctionName = T.PartitionFunctionName
WHERE T.IntendToPartition = 1
	AND T.ReadyToQueue = 1
	AND NOT EXISTS (SELECT 'True' 
					FROM DOI.IndexPartitionsRowStore IPRS 
					WHERE IPRS.DatabaseName = IRS.DatabaseName
						AND IPRS.SchemaName = IRS.SchemaName
						AND IPRS.TableName = IRS.TableName
						AND IPRS.IndexName = IRS.IndexName
						AND IPRS.PartitionNumber = P.PartitionNumber)


INSERT INTO DOI.IndexPartitionsColumnStore (DatabaseName, SchemaName ,TableName ,IndexName ,PartitionNumber ,OptionDataCompression )
SELECT ICS.DatabaseName, ICS.SchemaName, ICS.TableName, ICS.IndexName, P.PartitionNumber, ICS.OptionDataCompression_Desired
FROM DOI.Tables T
    INNER JOIN DOI.IndexesColumnStore ICS ON ICS.DatabaseName = T.DatabaseName
		AND ICS.SchemaName = T.SchemaName 
        AND ICS.TableName = T.TableName
	INNER JOIN DOI.vwPartitionFunctionPartitions P ON P.DatabaseName = T.DatabaseName
		AND p.PartitionFunctionName = T.PartitionFunctionName
WHERE T.IntendToPartition = 1
	AND T.ReadyToQueue = 1
	AND NOT EXISTS (SELECT 'True' 
					FROM DOI.IndexPartitionsColumnStore IPCS 
					WHERE IPCS.DatabaseName = ICS.DatabaseName
						AND IPCS.SchemaName = ICS.SchemaName
						AND IPCS.TableName = ICS.TableName
						AND IPCS.IndexName = ICS.IndexName
						AND IPCS.PartitionNumber = P.PartitionNumber)
            
GO