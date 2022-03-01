-- <Migration ID="73f36dff-ab1e-4cef-86df-568e2311dcee" />
GO
-- WARNING: this script could not be parsed using the Microsoft.TrasactSql.ScriptDOM parser and could not be made rerunnable. You may be able to make this change manually by editing the script by surrounding it in the following sql and applying it or marking it as applied!
-- <Migration ID="" />

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID('[DOI].[fnIndexesSQLToRun]') IS NOT NULL
	DROP FUNCTION [DOI].[fnIndexesSQLToRun];

GO
CREATE   FUNCTION DOI.[fnIndexesSQLToRun](
    @DatabaseName SYSNAME,
	@SchemaName VARCHAR(128) = NULL,
	@TableName VARCHAR(128) = NULL,
    @OnlineOperations BIT)

RETURNS TABLE

AS

RETURN (
        SELECT (SELECT	
				        CASE
                            WHEN x.NotInMetadataTableName IS NOT NULL
                            THEN '
DECLARE @ErrorMessage VARCHAR(MAX) = ''' + x.DatabaseName + '.' + x.SchemaName + '.' + x.TableName + ' has pending constraint or index changes and will NOT be queued for refreshing of Index Structures.'',

EXEC DOI.spRunLogInsert
	@CurrentDatabaseName    = ''' + x.DatabaseName + ''',
	@CurrentSchemaName      = ''' + x.SchemaName + ''',
	@CurrentTableName       = ''' + x.TableName + ''',
	@CurrentIndexName       = ''N/A'',
	@CurrentPartitionNumber	= 0, 
	@IndexSizeInMB			= 0,   
	@SQLStatement			= @ErrorMessage,
	@IndexOperation			= ''PendingConstraintValidation'',  
	@OnlineOperation		= ' + CAST(@OnlineOperations AS CHAR(1)) + ',
	@RowCount				= 0,     
	@TableChildOperationId	= 0, 
	@RunStatus				= ''Error'', 
	@TransactionId			= NULL,      
	@BatchId				= @BatchIdOUT,    
	@SeqNo					= 0,        
	@ErrorText              = @ErrorMessage,
	@ExitTableLoopOnError	= 0'
                            ELSE    CASE 
						                WHEN ROW_NUMBER() OVER(PARTITION BY X.DatabaseName, X.ParentSchemaName, X.ParentTableName ORDER BY X.IndexOperationSeqNo) = 1
						                THEN '
DECLARE @BatchId UNIQUEIDENTIFIER = NEWID()

INSERT INTO DOI.Queue(DatabaseName,SchemaName,TableName,IndexName,PartitionNumber,IndexSizeInMB,ParentSchemaName,ParentTableName,ParentIndexName,IndexOperation,TableChildOperationId,SQLStatement,SeqNo,DateTimeInserted,InProgress,RunStatus,ErrorMessage,TransactionId,BatchId,ExitTableLoopOnError)
VALUES 
            ('''
						                ELSE '
        ,('''
				                    END
                        END
                        + DatabaseName + ''', ''' 
				        + SchemaName + ''', ''' 
				        + TableName + ''', ''' 
				        + IndexName + ''', '
				        + '0, ' 
                        + '0, '
				        + ParentSchemaName + ', '
				        + ParentTableName + ', '
				        + ParentIndexName + ', '''
				        + x.IndexOperation + ''', '
				        + CAST(X.IndexOperationSeqNo AS VARCHAR(3)) + ', '''
				        + 'EXEC ' + REPLACE(REPLACE(REPLACE(REPLACE(x.SPSQLStmt, '<DatabaseName>', QUOTENAME(x.DatabaseName, '''')), '<SchemaName>', QUOTENAME(x.SchemaName, '''')), '<TableName>', QUOTENAME(x.TableName, '''')), '<IndexName>', QUOTENAME(x.IndexName, '''')) + ''', ' + --HOW DO WE DEAL WITH VARIABLE PARAMETER LISTS?  OR DIFFERENT VIEWS OTHER THAN VWINDEXES?
				        --+ COALESCE(X.SQLLiteral, '(SELECT ' + X.SQLColumnName + ' FROM DOI.' + X.ViewName + ' WHERE DatabaseName = ''' + X.DatabaseName + ''' AND SchemaName = ''' + X.SchemaName + ''' AND TableName = ''' + X.TableName + ''' AND IndexName = ''' + X.IndexName + ''')') + ''''  + ', '
                        + CAST(ROW_NUMBER() OVER(PARTITION BY X.DatabaseName, X.ParentSchemaName, X.ParentTableName ORDER BY X.IndexOperationSeqNo) AS VARCHAR(20)) + ', '
                        + 'DEFAULT, '
                        + 'DEFAULT, ' 
                        + 'DEFAULT, ' 
                        + 'NULL, '
                        + CASE WHEN X.NeedsTransaction = 1 THEN 'CAST(NEWID() AS VARCHAR(40)), ' ELSE 'NULL,' END
                        + 'CAST(@BatchId  AS VARCHAR(40)), '
                        + CAST(X.ExitTableLoopOnError AS CHAR(1)) + ')' AS InsertQueueSQL
        --SELECT *
        FROM (  SELECT TOP 9876543210987  I.DatabaseName, I.SchemaName, I.TableName, I.IndexName, i.IndexUpdateType, I.IndexSizeMB_Actual, 
                                        'NULL' AS ParentSchemaName, 'NULL' AS ParentTableName, 'NULL' AS ParentIndexName, IUTO.IndexOperation, IUTO.IndexOperationSeqNo, 
                                        IUTO.SPSQLStmt, IUTO.SQLLiteral, IUTO.NeedsTransaction, IUTO.ExitTableLoopOnError, NIM.SchemaName AS NotInMetadataSchemaName, NIM.TableName AS NotInMetadataTableName
                FROM DOI.vwIndexes I
                    INNER JOIN DOI.IndexUpdateTypeOperations IUTO ON IUTO.IndexUpdateType = I.IndexUpdateType
                    OUTER APPLY(	SELECT	DatabaseName,
			                                SchemaName, 
			                                TableName
	                                FROM (SELECT DatabaseName, SchemaName, TableName
					                                FROM DOI.CheckConstraintsNotInMetadata 			
					                                UNION
					                                SELECT DatabaseName, SchemaName, TableName
					                                FROM DOI.DefaultConstraintsNotInMetadata
					                                UNION
					                                SELECT DatabaseName, SchemaName, TableName
					                                FROM DOI.IndexesNotInMetadata
					                                WHERE Ignore = 0) NIMT
	                                WHERE DatabaseName = I.DatabaseName
				                                AND SchemaName = I.SchemaName
				                                AND TableName = I.TableName 
                                                AND ReadyToQueue = 1) NIM
		        WHERE I.DatabaseName = @DatabaseName
					AND I.SchemaName = CASE WHEN @SchemaName IS NULL THEN I.SchemaName ELSE @SchemaName END
					AND I.TableName = CASE WHEN @TableName IS NULL THEN I.TableName ELSE @TableName END
                    AND I.IndexUpdateType <> 'None'
                    AND I.IsOnlineOperation = @OnlineOperations
                ORDER BY I.DatabaseName, I.SchemaName, I.TableName, IUTO.SeqNo)x
        FOR XML PATH, TYPE).value('.', 'NVARCHAR(MAX)') AS InsertQueueSQL

		/*
			I don't think we need the code below anymore...this new design is not going to insert useless maintenance tasks below unless there is an actual indexupdatetype <> 'None'.

					--IF NOTHING OF SUBSTANCE WAS INSERTED, DELETE THE FEW USELESS MAINTENANCE TASKS THAT WERE INSERTED.
			IF EXISTS (	SELECT 'True' 
						FROM DOI.Queue 
						WHERE DatabaseName = @CurrentDatabaseName
							AND ParentTableName = @CurrentTableName
							AND IndexOperation IN ('Free TempDB Space Validation', 'Free Log Space Validation', 'Free Data Space Validation', 'Disable CmdShell', 'Get Application Lock', 'Release Application Lock'))
				AND NOT EXISTS (SELECT 'True' 
								FROM DOI.Queue 
								WHERE DatabaseName = @CurrentDatabaseName
									AND ParentTableName = @CurrentTableName
									AND IndexOperation NOT IN ('Free TempDB Space Validation', 'Free Log Space Validation', 'Free Data Space Validation', 'Disable CmdShell', 'Get Application Lock', 'Release Application Lock'))
			BEGIN
				DELETE FROM DOI.Queue 
				WHERE DatabaseName = @CurrentDatabaseName
					AND ParentTableName = @CurrentTableName
					AND IndexOperation IN ('Free TempDB Space Validation', 'Free Log Space Validation', 'Free Data Space Validation', 'Disable CmdShell', 'Get Application Lock', 'Release Application Lock')
			END

			*/


/*
		--partition-level updates
		UNION ALL
		SELECT	IP.IsOnlineOperation,
				IP.DatabaseName,
				IP.SchemaName, 
				IP.TableName, 
				IP.IndexName, 
				IP.PartitionUpdateType,
				IP.PartitionUpdateType,
				1 AS RowNum,
				IP.PartitionUpdateType AS IndexOperation,
				CASE IP.PartitionUpdateType
					WHEN 'AlterRebuild-PartitionLevel'
					THEN IP.AlterRebuildStatement
					WHEN 'AlterReorganize-PartitionLevel'
					THEN IP.AlterReorganizeStatement
					ELSE ''
				END AS CurrentSQLToExecute,
				IP.PartitionNumber,
				IP.TotalIndexPartitionSizeInMB
		FROM DOI.vwIndexPartitions IP 
		WHERE IP.PartitionUpdateType <> 'None') U)v

		UNION ALL

                                SELECT  StatisticsName, 
                                        CASE
                                            WHEN StatisticsUpdateType IN ('Create Statistics', 'DropRecreate Statistics')
                                            THEN CreateStatisticsSQL
                                            WHEN StatisticsUpdateType = 'Update Statistics'
                                            THEN UpdateStatisticsSQL
                                        END , 
                                        StatisticsUpdateType AS OriginalStatisticsUpdateType,
                                        CASE
                                            WHEN StatisticsUpdateType = 'DropRecreate Statistics'
                                            THEN 'Create Statistics'
                                            ELSE StatisticsUpdateType
                                        END AS StatisticsUpdateType,
                                        DropStatisticsSQL
                                FROM DOI.vwStatistics
                                WHERE DatabaseName = @CurrentDatabaseName
							        AND SchemaName = @CurrentSchemaName
                                    AND TableName = @CurrentTableName
                                    AND StatisticsUpdateType <> 'None'
                                    AND ReadyToQueue = 1*/
        )
GO