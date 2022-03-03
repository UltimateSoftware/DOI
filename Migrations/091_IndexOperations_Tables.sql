-- <Migration ID="0a2d9793-514c-4e0a-afcc-4b4887a15347" />
GO
-- </>

DROP TABLE IF EXISTS DOI.IndexUpdateTypeOperations
DROP TABLE IF EXISTS DOI.IndexOperation
DROP TABLE IF EXISTS DOI.IndexUpdateType

CREATE TABLE DOI.IndexOperation (Category VARCHAR(50) NOT NULL, IndexOperation VARCHAR(70) PRIMARY KEY CLUSTERED, ObjectType VARCHAR(50) NOT NULL, SQLText VARCHAR(500) NOT NULL)

INSERT INTO DOI.IndexOperation(Category, IndexOperation, ObjectType, SQLText)
VALUES
 ('ApplicationLock'     , 'ApplicationLockGet'                      , 'Application Lock')
,('ApplicationLock'     , 'ApplicationLockRelease'                  , 'Application Lock')

,('CmdShell'            , 'CmdShellDisable'                         , 'CmdShell')
,('CmdShell'            , 'CmdShellEnable'                          , 'CmdShell')

,('Constraints'         , 'Check Constraint SQL'                    , 'Constraint')
,('Constraints'         , 'ConstraintCreate'                        , 'Constraint')
,('Constraints'         , 'ConstraintPrepTableCreate'               , 'Constraint')
,('Constraints'         , 'ConstraintPrepTableDataLoadCreate'       , 'Constraint')
,('Constraints'         , 'ConstraintCreateNewTable'                , 'Constraint')

,('Databases'           , 'Change DB'                               , 'Database')

,('DataSynch'           , 'DataSynchTableCreate'                    , 'Table')
,('DataSynch'           , 'DataSynchTableDrop'                      , 'Table')
,('DataSynch'           , 'DataSynchTriggerCreate'                  , 'Trigger')
,('DataSynch'           , 'DataSynchTriggerDrop'                    , 'Trigger')
,('DataSynch'           , 'DataSynchTurnOff'                        , 'Data')
,('DataSynch'           , 'DataSynchTurnOn'                         , 'Data')
,('DataSynch'           , 'DataSynchUpdates'                        , 'Data')
,('DataSynch'           , 'DataSynchInserts'                        , 'Data')
,('DataSynch'           , 'DataSynchDeletes'                        , 'Data')

,('FinalDataSynch'      , 'FinalDataSynchTableCreate'               , 'Table')
,('FinalDataSynch'      , 'FinalDataSynchTriggerCreate'             , 'Trigger')

,('Foreign Keys'        , 'FKsAddBackParentTable'                   , 'Foreign Keys')
,('Foreign Keys'        , 'FKsAddBackRefTable'                      , 'Foreign Keys')
,('Foreign Keys'        , 'FKsDropParentTable'                      , 'Foreign Keys')
,('Foreign Keys'        , 'FKsDropRefTable'                         , 'Foreign Keys')
,('Foreign Keys'        , 'FKsRecreateAll'                          , 'Foreign Keys')

,('Indexes'             , 'IndexAlterRebuild-Online'                , 'Index')
,('Indexes'             , 'IndexAlterRebuild-Offline'               , 'Index')
,('Indexes'             , 'IndexAlterRebuild-PartitionLevel-Online' , 'Index')
,('Indexes'             , 'IndexAlterRebuild-PartitionLevel-Offline', 'Index')
,('Indexes'             , 'IndexAlterSet'                           , 'Index')
,('Indexes'             , 'IndexAlterReorganize'                    , 'Index')
,('Indexes'             , 'IndexAlterReorganize-PartitionLevel'     , 'Index')
,('Indexes'             , 'IndexCreate'                             , 'Index'           , 'EXEC DOI.spQueue_GenerateSQL_CreateIndex')
,('Indexes'             , 'IndexCreateDropExisting'                 , 'Index')
,('Indexes'             , 'IndexCreateNewTable'                     , 'Index')
,('Indexes'             , 'IndexPrepTableCreate'                    , 'Index')
,('Indexes'             , 'IndexDrop'                               , 'Index')

,('LoadData'            , 'LoadDataBCPViewCreate'                   , 'View')
,('LoadData'            , 'LoadDataBCPViewDrop'                     , 'View')
,('LoadData'            , 'LoadData'                                , 'Table')

,('Miscellaneous'       , 'Clean Up Tables'                         , 'Table')
,('Miscellaneous'       , 'Clear Queue of Other Tables'             , 'Data')
,('Miscellaneous'       , 'Delay'                                   , 'Process')
,('Miscellaneous'       , 'Kill'                                    , 'Process')
,('Miscellaneous'       , 'Rollback DDL'                            , 'Process')
,('Miscellaneous'       , 'Manual SQL Command'                      , 'Process')
,('Miscellaneous'       , 'Stop Processing'                         , 'Process')

,('PartitionState'      , 'PartitionStateMetadataDelete'            , 'Data')
,('PartitionState'      , 'PartitionStateMetadataValidation'        , 'Data')

,('PartitionSwitch'     , 'PartitionSwitch'                         , 'Table')

,('Queue'               , 'QueueDeleteTransaction'                  , 'Queue')
,('Queue'               , 'QueueUpdateToIn-Progress'                , 'Queue')

,('RenameDataSynch'     , 'RenameDataSynchTable'                    , 'Table')
,('RenameExistingTable' , 'RenameExistingTable'                     , 'Table')
,('RenameExistingTable' , 'RenameExistingTableConstraint'           , 'Constraint')
,('RenameExistingTable' , 'RenameExistingTableIndex'                , 'Index')
,('RenameExistingTable' , 'RenameExistingTableStatistic'            , 'Statistic')
,('RenameNewTable'      , 'RenameNewTable'                          , 'Table')
,('RenameNewTable'      , 'RenameNewTableConstraint'                , 'Constraint')
,('RenameNewTable'      , 'RenameNewTableIndex'                     , 'Index')
,('RenameNewTable'      , 'RenameNewTableStatistic'                 , 'Statistic')

,('ResourceGovernor'    , 'ResourceGovernorSettingsCheck'           , 'ResourceGovernor')
,('ResourceGovernor'    , 'ResourceGovernorDisable'                 , 'ResourceGovernor')
,('ResourceGovernor'    , 'ResourceGovernorEnable'                  , 'ResourceGovernor')

,('RevertRename'        , 'RevertRenameCreateTrigger'               , 'RevertRename')
,('RevertRename'        , 'RevertRenameDataSynchTrigger'            , 'RevertRename')
,('RevertRename'        , 'RevertRenameDropTrigger'                 , 'RevertRename')
,('RevertRename'        , 'RevertRenameTable'                       , 'RevertRename')
,('RevertRename'        , 'RevertRenameTableConstraint'             , 'RevertRename')
,('RevertRename'        , 'RevertRenameTableIndex'                  , 'RevertRename')
,('RevertRename'        , 'RevertRenameTableStatistics'             , 'Revert')

,('Statistics'          , 'StatisticsUpdate'                        , 'Statistics')
,('Statistics'          , 'StatisticsCreate'                        , 'Statistics')
,('Statistics'          , 'StatisticsDropRecreate'                  , 'Statistics')
,('Statistics'          , 'StatisticsCreateNewTable'                , 'Statistics')
,('Statistics'          , 'StatisticsDrop'                          , 'Statistics')

,('Tables'              , 'Partition Prep Table SQL'                , 'Tables')
,('Tables'              , 'PrepTableCreate'                         , 'Tables')
,('Tables'              , 'CreateNewTable'                          , 'Tables')
,('Tables'              , 'TableDrop'                               , 'Tables')
,('Tables'              , 'Temp Table SQL'                          , 'Tables')

,('Transaction'         , 'BeginTran'                               , 'Transaction')
,('Transaction'         , 'CommitTran'                              , 'Transaction')

,('Triggers'            , 'TriggerCreate'                           , 'Triggers')
,('Triggers'            , 'TriggerDrop'                             , 'Triggers')

,('Validation'          , 'FreeSpaceValidationData'                 , 'Space')
,('Validation'          , 'FreeSpaceValidationLog'                  , 'Space')
,('Validation'          , 'FreeSpaceValidationTempDb'               , 'Space')
,('Validation'          , 'ValidationFinal'                         , 'Validation')
,('Validation'          , 'ValidationPartitionData'                 , 'Data')
,('Validation'          , 'ValidationPostPartitioningData'          , 'Data')
,('Validation'          , 'ValidationPriorError'                    , 'Error')

                                          
CREATE TABLE DOI.IndexUpdateType (
    IndexUpdateType VARCHAR(50) PRIMARY KEY CLUSTERED,
    IsOnlineOperation BIT NOT NULL);
GO

INSERT INTO DOI.IndexUpdateType(IndexUpdateType, IsOnlineOperation)
VALUES
 ('Delete'                              , 1)
,('CreateMissing'                       , 1)
,('CreateDropExisting'                  , 1)
,('ExchangeTableNonPartitioned'         , 1)
,('ExchangeTablePartitioned'            , 1)
,('AlterRebuild-Online'                 , 1)
,('AlterRebuild-PartitionLevel-Online'  , 1)
,('DropRecreate'                        , 0)
,('AlterRebuild-Offline'                , 0)
,('AlterRebuild-PartitionLevel-Offline' , 0)
,('AlterSet'                            , 1)
,('AlterReorganize'                     , 1)
,('AlterReorganize-PartitionLevel'      , 1)
,('CreateStatistics'                    , 1)
,('DropRecreateStatistics'              , 0)
,('UpdateStatistics'                    , 1)
,('None'                                , 1);


/*

DROP TABLE IF EXISTS DOI.IndexUpdateTypeOperations

CREATE TABLE DOI.IndexUpdateTypeOperations (
    IndexUpdateType VARCHAR(50) NOT NULL  
        CONSTRAINT FK_IndexUpdateTypeOperations_IndexUpdateType
            FOREIGN KEY REFERENCES DOI.IndexUpdateType(IndexUpdateType),
    IndexOperation VARCHAR(70) NOT NULL
        CONSTRAINT FK_IndexUpdateTypeOperations_IndexOperation
            FOREIGN KEY REFERENCES DOI.IndexOperation(IndexOperation),
    IndexOperationSeqNo TINYINT NOT NULL,
    SPSQLStmt NVARCHAR(MAX) NULL,
    SQLLiteral NVARCHAR(128) NULL,
    SeqNo INT NOT NULL,
    NeedsTransaction BIT NOT NULL,
    ExitTableLoopOnError BIT NOT NULL,
    CONSTRAINT PK_IndexUpdateTypeOperations
        PRIMARY KEY CLUSTERED (IndexUpdateType, IndexOperation, IndexOperationSeqNo),
    CONSTRAINT Chk_IndexUpdateTypeOperations_SQLLiteralOrNot
        CHECK ((SPSQLStmt IS NULL AND SQLLiteral IS NOT NULL)
                    OR (SPSQLStmt IS NOT NULL AND SQLLiteral IS NULL)));
GO

CREATE UNIQUE NONCLUSTERED INDEX UDX_IndexUpdateTypeOperations
    ON DOI.IndexUpdateTypeOperations(IndexUpdateType, SeqNo)

INSERT INTO DOI.IndexUpdateTypeOperations
( IndexUpdateType                       , IndexOperation                                                , IndexOperationSeqNo   , SPSQLStmt                                                                                                                                                                             , SQLLiteral                                , SeqNo , NeedsTransaction  , ExitTableLoopOnError)
VALUES
 ('Delete'                              , 'ResourceGovernorEnable'                                      , 1                     , 'DOI.spQueue_GenerateSQL_ResourceGovernorEnable'                                                                                                                                      , NULL                                      , 1     , 0                 , 1)
,('Delete'                              , 'ApplicationLockGet'                                          , 1                     , 'DOI.spQueue_GenerateSQL_ApplicationLockGet @DatabaseName = ''<DatabaseName>'', @BatchId = ''''00000000-0000-0000-0000-000000000000'''''                                              , NULL                                      , 2     , 0                 , 1)
,('Delete'                              , 'IndexDrop'                                                   , 1                     , 'DOI.spQueue_GenerateSQL_DropExistingIndex @DatabaseName = ''<DatabaseName>'', @SchemaName = ''<SchemaName>'', @TableName = ''<TableName>'', @IndexName = ''<IndexName>'''            , NULL                                      , 3     , 0                 , 0)
,('Delete'                              , 'ApplicationLockRelease'                                      , 1                     , 'DOI.spQueue_GenerateSQL_ApplicationLockRelease @DatabaseName = ''<DatabaseName>'', @BatchId = ''00000000-0000-0000-0000-000000000000'''''                                            , NULL                                      , 4     , 0                 , 0)

,('CreateMissing'                       , 'ResourceGovernorEnable'                                      , 1                     , 'DOI.spQueue_GenerateSQL_ResourceGovernorEnable'                                                                                                                                      , NULL                                      , 1     , 0                 , 1)
,('CreateMissing'                       , 'ApplicationLockGet'                                          , 1                     , 'DOI.spQueue_GenerateSQL_ApplicationLockGet @DatabaseName = ''<DatabaseName>'', @BatchId = ''''00000000-0000-0000-0000-000000000000'''''                                              , NULL                                      , 2     , 0                 , 1)
,('CreateMissing'                       , 'FreeSpaceValidationData'                                     , 1                     , 'DOI.spQueue_GenerateSQL_FreeSpaceValidationData @DatabaseName = ''<DatabaseName>'', @SchemaName = ''<SchemaName>'', @TableName = ''<TableName>'', @IndexName = ''<IndexName>'''      , NULL                                      , 3     , 0                 , 0)
,('CreateMissing'                       , 'FreeSpaceValidationLog'                                      , 1                     , 'DOI.spQueue_GenerateSQL_FreeSpaceValidationLog @DatabaseName = ''<DatabaseName>'', @SchemaName = ''<SchemaName>'', @TableName = ''<TableName>'', @IndexName = ''<IndexName>'''       , NULL                                      , 4     , 0                 , 0)
,('CreateMissing'                       , 'FreeSpaceValidationTempDb'                                   , 1                     , 'DOI.spQueue_GenerateSQL_FreeSpaceValidationTempDb @DatabaseName = ''<DatabaseName>'', @SchemaName = ''<SchemaName>'', @TableName = ''<TableName>'', @IndexName = ''<IndexName>'''    , NULL                                      , 5     , 0                 , 0)
,('CreateMissing'                       , 'IndexCreate'                                                 , 1                     , 'DOI.spQueue_GenerateSQL_CreateIndex @DatabaseName = ''<DatabaseName>'', @SchemaName = ''<SchemaName>'', @TableName = ''<TableName>'', @IndexName = ''<IndexName>'''                  , NULL                                      , 6     , 0                 , 0)
,('CreateMissing'                       , 'ApplicationLockRelease'                                      , 1                     , 'DOI.spQueue_GenerateSQL_ApplicationLockRelease @DatabaseName = ''<DatabaseName>'', @BatchId = ''''00000000-0000-0000-0000-000000000000'''''                                          , NULL                                      , 7     , 0                 , 0)
               

SELECT * FROM DOI.IndexUpdateTypeOperations ORDER BY IndexUpdateType, SeqNo


SELECT (SELECT
				CASE 
						WHEN ROW_NUMBER() OVER(PARTITION BY X.DatabaseName, X.ParentSchemaName, X.ParentTableName ORDER BY X.IndexOperationSeqNo) = 1
						THEN '
DECLARE @BatchId UNIQUEIDENTIFIER = NEWID()

INSERT INTO DOI.Queue(DatabaseName,SchemaName,TableName,IndexName,PartitionNumber,IndexSizeInMB,ParentSchemaName,ParentTableName,ParentIndexName,IndexOperation,TableChildOperationId,SQLStatement,SeqNo,DateTimeInserted,InProgress,RunStatus,ErrorMessage,TransactionId,BatchId,ExitTableLoopOnError)
VALUES 
 ('''
						ELSE '
,('''
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
                + CASE WHEN X.NeedsTransaction = 1 THEN '''' + CAST(NEWID() AS VARCHAR(40)) + ''', ' ELSE 'NULL,' END
                + 'CAST(@BatchId  AS VARCHAR(40)), '
                + CAST(X.ExitTableLoopOnError AS CHAR(1)) + ')' AS InsertQueueSQL
--SELECT *
FROM (  SELECT TOP 9876543210987  I.DatabaseName, I.SchemaName, I.TableName, I.IndexName, i.IndexUpdateType, I.IndexSizeMB_Actual, 
                                'NULL' AS ParentSchemaName, 'NULL' AS ParentTableName, 'NULL' AS ParentIndexName, IUTO.IndexOperation, IUTO.IndexOperationSeqNo, 
                                IUTO.SPSQLStmt, IUTO.SQLLiteral, IUTO.NeedsTransaction, IUTO.ExitTableLoopOnError
        FROM DOI.vwIndexes I
            INNER JOIN DOI.IndexUpdateTypeOperations IUTO ON IUTO.IndexUpdateType = I.IndexUpdateType
		WHERE I.IndexUpdateType <> 'None'
            AND I.IsOnlineOperation = 1
        ORDER BY I.DatabaseName, I.SchemaName, I.TableName, IUTO.SeqNo)x
FOR XML PATH, TYPE).value('.', 'nvarchar(max)') AS InsertQueueSQL



SELECT * FROM DOI.fnIndexesSQLToRun('doiunittests', 1)






*/

CREATE TABLE DOI.IndexUpdateTypeOperations (
    IndexUpdateType VARCHAR(50) NOT NULL  
        CONSTRAINT FK_IndexUpdateTypeOperations_IndexUpdateType
            FOREIGN KEY REFERENCES DOI.IndexUpdateType(IndexUpdateType),
    IndexOperation VARCHAR(70) NOT NULL
        CONSTRAINT FK_IndexUpdateTypeOperations_IndexOperation
            FOREIGN KEY REFERENCES DOI.IndexOperation(IndexOperation),
    IndexOperationSeqNo TINYINT NOT NULL,
    SPName NVARCHAR(128) NULL,
    SQLColumnName NVARCHAR(128) NULL,
    SQLLiteral NVARCHAR(128) NULL,
    SeqNo INT NOT NULL,
    NeedsTransaction BIT NOT NULL,
    ExitTableLoopOnError BIT NOT NULL,
    CONSTRAINT PK_IndexUpdateTypeOperations
        PRIMARY KEY CLUSTERED (IndexUpdateType, IndexOperation, IndexOperationSeqNo),
    CONSTRAINT Chk_IndexUpdateTypeOperations_SQLLiteralOrNot
        CHECK ((ViewName IS NULL AND SQLColumnName IS NULL AND SQLLiteral IS NOT NULL)
                    OR (ViewName IS NOT NULL AND SQLColumnName IS NOT NULL AND SQLLiteral IS NULL)));
GO

CREATE UNIQUE NONCLUSTERED INDEX UDX_IndexUpdateTypeOperations
    ON DOI.IndexUpdateTypeOperations(IndexUpdateType, SeqNo)

INSERT INTO DOI.IndexUpdateTypeOperations
( IndexUpdateType                       , IndexOperation                                                , IndexOperationSeqNo   , SPName   /*CHANGE THIS TO SPName and add params...use replaceable markers for var parameter lists*/                                                   , SQLColumnName                                     , SQLLiteral                                                                            , SeqNo , NeedsTransaction  , ExitTableLoopOnError)

/*
for partitioning operations, we need to have a parent SP which handles all the operations for a single prep table (create table, load, indexes, constraints, etc.) in the right sequence.  
In this table below, we would just represent that with a single operation 'Setup Prep table', or something like that,  and have the call to the parent SP stored in this table.

when called, that parent SP would loop through all the partitions for that table and insert a group of SP calls into the Queue table, one SP call that handles that particular operation, for that particular prep table, in the right order, passing the
partition #'s or boundary values to each operation.

so, we end up with all the detail sql still in the queue, but inserted in a data-driven way.
*/


VALUES
--table switch, non-partitioned
 ('ExchangeTableNonPartitioned'         , 'ResourceGovernorEnable'                                      , 1                     , NULL                                                          , NULL                                              , 'EXEC DOI.spRun_ReEnableResourceGovernor'                                             , 1     , 0                 , 1)
,('ExchangeTableNonPartitioned'         , 'ApplicationLockGet'                                          , 1                     , 'vwExchangeTableNonPartitioned_Tables_NewTable'               , 'GetApplicationLockSQL'                           , NULL                                                                                  , 2     , 0                 , 1)
,('ExchangeTableNonPartitioned'         , 'FreeSpaceValidationData'                                     , 1                     , 'vwExchangeTableNonPartitioned_Tables_NewTable'               , 'FreeDataSpaceCheckSQL'                           , NULL                                                                                  , 3     , 0                 , 0)
,('ExchangeTableNonPartitioned'         , 'FreeSpaceValidationLog'                                      , 1                     , 'vwExchangeTableNonPartitioned_Tables_NewTable'               , 'FreeLogSpaceCheckSQL'                            , NULL                                                                                  , 4     , 0                 , 0)
,('ExchangeTableNonPartitioned'         , 'FreeSpaceValidationTempDb'                                   , 1                     , 'vwExchangeTableNonPartitioned_Tables_NewTable'               , 'FreeTempDBSpaceCheckSQL'                         , NULL                                                                                  , 5     , 0                 , 0)
,('ExchangeTableNonPartitioned'         , 'CreateNewTable'                                              , 1                     , 'vwExchangeTableNonPartitioned_Tables_NewTable'               , 'CreateNewTableSQL'                               , NULL                                                                                  , 6     , 0                 , 0)
,('ExchangeTableNonPartitioned'         , 'ConstraintCreateNewTable'                                    , 1                     , 'vwExchangeTableNonPartitioned_Tables_NewTable_Constraints'   , 'CreateConstraintStatement'                       , NULL                                                                                  , 7     , 0                 , 0)
,('ExchangeTableNonPartitioned'         , 'DataSynchTableCreate'                                        , 1                     , 'vwExchangeTableNonPartitioned_Tables_NewTable'               , 'CreateDataSynchTableSQL'                         , NULL                                                                                  , 8     , 0                 , 0)
,('ExchangeTableNonPartitioned'         , 'DataSynchTriggerCreate'                                      , 1                     , 'vwExchangeTableNonPartitioned_Tables_NewTable'               , 'CreateDataSynchTriggerSQL'                       , NULL                                                                                  , 9     , 0                 , 1)
--Rename 2 data synch process to 'partition data synch' and 'table data synch'.                         
,('ExchangeTableNonPartitioned'         , 'CmdShellEnable'                                              , 1                     , 'vwExchangeTableNonPartitioned_Tables_NewTable'               , 'EnableCmdShellSQL'                               , NULL                                                                                  , 10    , 0                 , 0)
,('ExchangeTableNonPartitioned'         , 'LoadDataBCPViewCreate'                                       , 1                     , 'vwExchangeTableNonPartitioned_Tables_NewTable'               , 'CreateViewForBCPSQL'                             , NULL                                                                                  , 11    , 0                 , 0)
,('ExchangeTableNonPartitioned'         , 'LoadData'                                                    , 1                     , 'vwExchangeTableNonPartitioned_Tables_NewTable'               , 'BCPSQL'                                          , NULL                                                                                  , 12    , 0                 , 0)
,('ExchangeTableNonPartitioned'         , 'CmdShellDisable'                                             , 1                     , 'vwExchangeTableNonPartitioned_Tables_NewTable'               , 'DisableCmdShellSQL'                              , NULL                                                                                  , 13    , 0                 , 0)
,('ExchangeTableNonPartitioned'         , 'IndexCreateNewTable'                                         , 1                     , 'vwExchangeTableNonPartitioned_Tables_NewTable_Indexes'       , 'NewTableIndexCreateSQL'                          , NULL                                                                                  , 14    , 0                 , 0)
,('ExchangeTableNonPartitioned'         , 'StatisticsCreateNewTable'                                    , 1                     , 'vwExchangeTableNonPartitioned_Tables_NewTable_Statistics'    , 'CreateStatisticsStatement'                       , NULL                                                                                  , 15    , 0                 , 0)
,('ExchangeTableNonPartitioned'         , 'BeginTran'                                                   , 1                     , NULL                                                          , NULL                                              , 'SET TRANSACTION ISOLATION LEVEL SERIALIZABLE' + CHAR(13) + CHAR(10) + 'BEGIN TRAN'   , 16    , 0                 , 0)
,('ExchangeTableNonPartitioned'         , 'RenameExistingTableIndex'                                    , 1                     , 'vwExchangeTableNonPartitioned_Tables_NewTable_Indexes'       , 'RenameExistingTableIndexSQL'                     , NULL                                                                                  , 17    , 0                 , 0)
,('ExchangeTableNonPartitioned'         , 'RenameNewTableIndex'                                         , 1                     , 'vwExchangeTableNonPartitioned_Tables_NewTable_Indexes'       , 'RenameNewTableIndexSQL'                          , NULL                                                                                  , 18    , 0                 , 0)
,('ExchangeTableNonPartitioned'         , 'RenameExistingTableStatistic'                                , 1                     , 'vwExchangeTableNonPartitioned_Tables_NewTable_Statistics'    , 'RenameExistingTableStatisticsSQL'                , NULL                                                                                  , 19    , 0                 , 0)
,('ExchangeTableNonPartitioned'         , 'RenameNewTableStatistic'                                     , 1                     , 'vwExchangeTableNonPartitioned_Tables_NewTable_Statistics'    , 'RenameNewTableStatisticsSQL'                     , NULL                                                                                  , 20    , 0                 , 0)
,('ExchangeTableNonPartitioned'         , 'RenameExistingTableConstraint'                               , 1                     , 'vwExchangeTableNonPartitioned_Tables_NewTable_Constraints'   , 'RenameExistingTableConstraintSQL'                , NULL                                                                                  , 21    , 0                 , 0)
,('ExchangeTableNonPartitioned'         , 'RenameNewTableConstraint'                                    , 1                     , 'vwExchangeTableNonPartitioned_Tables_NewTable_Constraints'   , 'RenameNewTableConstraintSQL'                     , NULL                                                                                  , 22    , 0                 , 0)
,('ExchangeTableNonPartitioned'         , 'TriggerDrop'                                                 , 1                     , 'vwExchangeTableNonPartitioned_Tables_NewTable_Triggers'      , 'DropTriggerSQL'                                  , NULL                                                                                  , 23    , 0                 , 0)
,('ExchangeTableNonPartitioned'         , 'RenameExistingTable'                                         , 1                     , 'vwExchangeTableNonPartitioned_Tables_NewTable'               , 'RenameExistingTableSQL'                          , NULL                                                                                  , 24    , 0                 , 0)
,('ExchangeTableNonPartitioned'         , 'RenameNewTable'                                              , 1                     , 'vwExchangeTableNonPartitioned_Tables_NewTable'               , 'RenameNewTableSQL'                               , NULL                                                                                  , 25    , 0                 , 0)
,('ExchangeTableNonPartitioned'         , 'TriggerCreate'                                               , 1                     , 'vwExchangeTableNonPartitioned_Tables_NewTable_Triggers'      , 'CreateTriggerSQL'                                , NULL                                                                                  , 26    , 0                 , 0)
,('ExchangeTableNonPartitioned'         , 'CommitTran'                                                  , 1                     , NULL                                                          , NULL                                              , 'COMMIT TRAN'                                                                         , 27    , 0                 , 0)
,('ExchangeTableNonPartitioned'         , 'DataSynchTriggerDrop'                                        , 1                     , 'vwExchangeTableNonPartitioned_Tables_NewTable'               , 'DropDataSynchTriggerSQL'                         , NULL                                                                                  , 28    , 0                 , 0)
,('ExchangeTableNonPartitioned'         , 'DataSynchTableDrop'                                          , 1                     , 'vwExchangeTableNonPartitioned_Tables_NewTable'               , 'DropDataSynchTableSQL'                           , NULL                                                                                  , 29    , 0                 , 0)
,('ExchangeTableNonPartitioned'         , 'ApplicationLockRelease'                                      , 1                     , 'vwExchangeTableNonPartitioned_Tables_NewTable'               , 'ReleaseApplicationLockSQL'                       , NULL                                                                                  , 30    , 0                 , 0)

--table switch, partitioned

--add partition state refresh
--add partition state validation
,('ExchangeTablePartitioned'            , 'ResourceGovernorEnable'                                      , 1                     , NULL                                                          , NULL                                              , 'EXEC DOI.spRun_ReEnableResourceGovernor'                                             , 1     , 0                 , 1)
,('ExchangeTablePartitioned'            , 'ApplicationLockGet'                                          , 1                     , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'GetApplicationLockSQL'                           , NULL                                                                                  , 2     , 0                 , 1)
,('ExchangeTablePartitioned'            , 'FreeSpaceValidationData'                                     , 1                     , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'FreeDataSpaceCheckSQL'                           , NULL                                                                                  , 3     , 0                 , 0)
,('ExchangeTablePartitioned'            , 'FreeSpaceValidationLog'                                      , 1                     , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'FreeLogSpaceCheckSQL'                            , NULL                                                                                  , 4     , 0                 , 0)
,('ExchangeTablePartitioned'            , 'FreeSpaceValidationTempDb'                                   , 1                     , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'FreeTempDBSpaceCheckSQL'                         , NULL                                                                                  , 5     , 0                 , 0)
,('ExchangeTablePartitioned'            , 'DataSynchTriggerCreate'                                      , 1                     , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.CreateDataSynchTriggerSQL'                    , NULL                                                                                  , 6     , 0                 , 1)
,('ExchangeTablePartitioned'            , 'PrepTableCreate'                                             , 1                     , 'vwPartitioning_Tables_PrepTables'                            , 'PT.CreatePrepTableSQL'                           , NULL                                                                                  , 7     , 0                 , 1)
,('ExchangeTablePartitioned'            , 'DataSynchTurnOn'                                             , 1                     , 'vwPartitioning_Tables_PrepTables'                            , 'PT.TurnOnDataSynchSQL'                           , NULL                                                                                  , 8     , 0                 , 1)
,('ExchangeTablePartitioned'            , 'CmdShellEnable'                                              , 1                     , 'vwPartitioning_Tables_PrepTables'                            , 'PT.EnableCmdShellSQL'                            , NULL                                                                                  , 9     , 0                 , 1)
,('ExchangeTablePartitioned'            , 'LoadDataBCPViewCreate'                                       , 1                     , 'vwPartitioning_Tables_PrepTables'                            , 'PT.CreateViewForBCPSQL'                          , NULL                                                                                  , 10    , 0                 , 1)
,('ExchangeTablePartitioned'            , 'LoadData'                                                    , 1                     , 'vwPartitioning_Tables_PrepTables'                            , 'PT.BCPSQL'                                       , NULL                                                                                  , 11    , 0                 , 1)
,('ExchangeTablePartitioned'            , 'CmdShellDisable'                                             , 1                     , 'vwPartitioning_Tables_PrepTables'                            , 'PT.DisableCmdShellSQL'                           , NULL                                                                                  , 12    , 0                 , 1)
,('ExchangeTablePartitioned'            , 'ConstraintPrepTableDataLoadCreate'                           , 1                     , 'vwPartitioning_Tables_PrepTables'                            , 'PT.CheckConstraintSQL'                           , NULL                                                                                  , 13    , 0                 , 1)
,('ExchangeTablePartitioned'            , 'IndexPrepTableCreate'                                        , 1                     , 'vwPartitioning_Tables_PrepTables_Indexes'                    , 'I.PrepTableIndexCreateSQL'                       , NULL                                                                                  , 14    , 0                 , 1)
,('ExchangeTablePartitioned'            , 'ConstraintPrepTableCreate'                                   , 1                     , 'vwPartitioning_Tables_PrepTables_Constraints'                , 'PTC.CreateConstraintStatement'                   , NULL                                                                                  , 15    , 0                 , 1)
,('ExchangeTablePartitioned'            , 'ValidationPriorError'                                        , 1                     , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.PriorErrorValidationSQL'                      , NULL                                                                                  , 16    , 0                 , 1)
,('ExchangeTablePartitioned'            , 'DataSynchTableCreate'                                        , 1                     , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.CreateFinalDataSynchTableSQL'                 , NULL                                                                                  , 17    , 0                 , 1)
,('ExchangeTablePartitioned'            , 'DataSynchTriggerCreate'                                      , 2                     , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.CreateFinalDataSynchTriggerSQL'               , NULL                                                                                  , 18    , 0                 , 1)
,('ExchangeTablePartitioned'            , 'DataSynchTurnOff'                                            , 1                     , 'vwPartitioning_Tables_PrepTables'                            , 'PT.TurnOffDataSynchSQL'                          , NULL                                                                                  , 19    , 0                 , 1)
,('ExchangeTablePartitioned'            , 'ValidationPartitionData'                                     , 1                     , 'vwPartitioning_Tables_PrepTables_Partitions'                 , 'PT.PartitionDataValidationSQL'                   , NULL                                                                                  , 20    , 0                 , 1)
,('ExchangeTablePartitioned'            , 'BeginTran'                                                   , 1                     , NULL                                                          , NULL                                              , 'SET TRANSACTION ISOLATION LEVEL SERIALIZABLE' + CHAR(13) + CHAR(10) + 'BEGIN TRAN'   , 21    , 0                 , 1)
,('ExchangeTablePartitioned'            , 'PartitionSwitch'                                             , 1                     , 'vwPartitioning_Tables_PrepTables_Partitions'                 , 'PT.PartitionSwitchSQL'                           , NULL                                                                                  , 22    , 0                 , 1)
,('ExchangeTablePartitioned'            , 'TableDrop'                                                   , 1                     , 'vwPartitioning_Tables_PrepTables_Partitions'                 , 'PT.DropTableSQL'                                 , NULL                                                                                  , 23    , 0                 , 1)
,('ExchangeTablePartitioned'            , 'CommitTran'                                                  , 1                     , NULL                                                          , NULL                                              , 'COMMIT TRAN'                                                                         , 24    , 0                 , 1)
,('ExchangeTablePartitioned'            , 'BeginTran'                                                   , 2                     , NULL                                                          , NULL                                              , 'SET TRANSACTION ISOLATION LEVEL SERIALIZABLE' + CHAR(13) + CHAR(10) + 'BEGIN TRAN'   , 25    , 0                 , 1)
,('ExchangeTablePartitioned'            , 'RenameExistingTableIndex'                                    , 1                     , 'vwPartitioning_Tables_PrepTables_Indexes'                    , 'I.RenameExistingTableIndexSQL'                   , NULL                                                                                  , 26    , 0                 , 1)
,('ExchangeTablePartitioned'            , 'RenameNewTableIndex'                                         , 1                     , 'vwPartitioning_Tables_PrepTables_Indexes'                    , 'I.RenameNewPartitionedPrepTableIndexSQL'         , NULL                                                                                  , 27    , 0                 , 1)
,('ExchangeTablePartitioned'            , 'RenameExistingTableConstraint'                               , 1                     , 'vwPartitioning_Tables_PrepTables_Constraints'                , 'PTC.RenameExistingTableConstraintSQL'            , NULL                                                                                  , 28    , 0                 , 1)
,('ExchangeTablePartitioned'            , 'RenameNewTableConstraint'                                    , 1                     , 'vwPartitioning_Tables_PrepTables_Constraints'                , 'PTC.RenameNewPartitionedPrepTableConstraintSQL'  , NULL                                                                                  , 29    , 0                 , 1)
,('ExchangeTablePartitioned'            , 'RenameExistingTableStatistic'                                , 1                     , 'vwPartitioning_Tables_PrepTables_Statistics'                 , 'PTS.RenameExistingTableStatisticsSQL'            , NULL                                                                                  , 30    , 0                 , 1)
,('ExchangeTablePartitioned'            , 'TriggerDrop'                                                 , 1                     , 'vwPartitioning_Tables_NewPartitionedTable_Triggers'          , 'PTT.DropTriggerSQL'                              , NULL                                                                                  , 31    , 0                 , 1)
,('ExchangeTablePartitioned'            , 'RenameExistingTable'                                         , 1                     , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.RenameExistingTableSQL'                       , NULL                                                                                  , 32    , 0                 , 1)
,('ExchangeTablePartitioned'            , 'RenameNewTable'                                              , 1                     , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.RenameNewPartitionedPrepTableSQL'             , NULL                                                                                  , 33    , 0                 , 1)
,('ExchangeTablePartitioned'            , 'TriggerCreate'                                               , 1                     , 'vwPartitioning_Tables_NewPartitionedTable_Triggers'          , 'PTT.CreateTriggerSQL'                            , NULL                                                                                  , 34    , 0                 , 1)
,('ExchangeTablePartitioned'            , 'DataSynchTriggerDrop'                                        , 1                     , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.DropDataSynchTriggerSQL'                      , NULL                                                                                  , 35    , 0                 , 0)
,('ExchangeTablePartitioned'            , 'DataSynchDeletes'                                            , 1                     , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.SynchDeletesPrepTableSQL'                     , NULL                                                                                  , 36    , 0                 , 0)
,('ExchangeTablePartitioned'            , 'DataSynchInserts'                                            , 1                     , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.SynchInsertsPrepTableSQL'                     , NULL                                                                                  , 37    , 0                 , 0)
,('ExchangeTablePartitioned'            , 'DataSynchUpdates'                                            , 1                     , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.SynchUpdatesPrepTableSQL'                     , NULL                                                                                  , 38    , 0                 , 0)
,('ExchangeTablePartitioned'            , 'CommitTran'                                                  , 2                     , NULL                                                          , NULL                                              , 'COMMIT TRAN'                                                                         , 39    , 0                 , 1)
,('ExchangeTablePartitioned'            , 'DataSynchTableDrop'                                          , 1                     , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.DropDataSynchTableSQL'                        , NULL                                                                                  , 40    , 0                 , 0)
,('ExchangeTablePartitioned'            , 'FKsDropParentTable'                                          , 1                     , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.DropParentOldTableFKSQL'                      , NULL                                                                                  , 41    , 0                 , 0)
,('ExchangeTablePartitioned'            , 'FKsDropRefTable'                                             , 1                     , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.DropRefOldTableFKSQL'                         , NULL                                                                                  , 42    , 0                 , 0)
,('ExchangeTablePartitioned'            , 'FKsAddBackParentTable'                                       , 1                     , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.AddBackParentTableFKSQL'                      , NULL                                                                                  , 43    , 0                 , 0)
,('ExchangeTablePartitioned'            , 'FKsAddBackRefTable'                                          , 1                     , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.AddBackRefTableFKSQL'                         , NULL                                                                                  , 44    , 0                 , 0)
,('ExchangeTablePartitioned'            , 'PartitionStateMetadataDelete'                                , 1                     , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.DeletePartitionStateMetadataSQL'              , NULL                                                                                  , 45    , 0                 , 0)
,('ExchangeTablePartitioned'            , 'ValidationPostPartitioningData'                              , 1                     , 'vwPartitioning_Tables_PrepTables'                            , 'PT.PostDataValidationMissingEventsSQL'           , NULL                                                                                  , 47    , 0                 , 0)
,('ExchangeTablePartitioned'            , 'StatisticsCreate'                                            , 1                     , 'vwPartitioning_Tables_PrepTables_Statistics'                 , 'PTS.CreateStatisticsStatement'                   , NULL                                                                                  , 48    , 0                 , 1)
,('ExchangeTablePartitioned'            , 'ApplicationLockRelease'                                      , 1                     , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.ReleaseApplicationLockSQL'                    , NULL                                                                                  , 49    , 0                 , 0)

 --if we are doing BCP strategy, then do nothing else on the table.  ONCE 'PartitionSwap' becomes its own IndexUpdateType, this check will no longer be necessary.


--standard singleton operations
,('Delete'                              , 'ResourceGovernorEnable'                                      , 1                     , NULL                                                          , NULL                                              , 'EXEC DOI.spRun_ReEnableResourceGovernor'                                             , 1     , 0                 , 1)
,('Delete'                              , 'ApplicationLockGet'                                          , 1                     , 'DOI.spRun_GetApplicationLock @DatabaseName = ''<DatabaseName>'', @BatchId = ''00000000-0000-0000-0000-000000000000'''                           , NULL                                                                                  , 2     , 0                 , 1)
,('Delete'                              , 'IndexDrop'                                                   , 1                     , 'DOI.spQueue_GenerateSQL_DropExistingIndex @DatabaseName = ''<DatabaseName>'', @SchemaName = ''<SchemaName>'', @TableName = ''<TableName>'', @IndexName = ''<IndexName>'''                   , 'DropStatement'                                   , NULL                                                                                  , 3     , 0                 , 0)
,('Delete'                              , 'ApplicationLockRelease'                                      , 1                     , 'DOI.spRun_ReleaseApplicationLock @DatabaseName = ''<DatabaseName>'', @BatchId = ''00000000-0000-0000-0000-000000000000'''                                                   , 'ReleaseApplicationLockSQL'                       , NULL                                                                                  , 4     , 0                 , 0)
                                                                                                                           
,('CreateMissing'                       , 'ResourceGovernorEnable'                                      , 1                     , NULL                                                          , NULL                                              , 'EXEC DOI.spRun_ReEnableResourceGovernor'                                             , 1     , 0                 , 1)
,('CreateMissing'                       , 'ApplicationLockGet'                                          , 1                     , 'DOI.spRun_GetApplicationLock @DatabaseName = ''<DatabaseName>'', @BatchId = ''00000000-0000-0000-0000-000000000000'''                                                   , 'GetApplicationLockSQL'                           , NULL                                                                                  , 2     , 0                 , 1)
,('CreateMissing'                       , 'FreeSpaceValidationData'                                     , 1                     , 'DOI.spQueue_GenerateSQL_FreeSpaceValidationData @DatabaseName = ''<DatabaseName>'', @SchemaName = ''<SchemaName>'', @TableName = ''<TableName>'', @IndexName = ''<IndexName>'''                                                   , 'FreeDataSpaceCheckSQL'                           , NULL                                                                                  , 3     , 0                 , 0)
,('CreateMissing'                       , 'FreeSpaceValidationLog'                                      , 1                     , 'DOI.spQueue_GenerateSQL_FreeSpaceValidationLog @DatabaseName = ''<DatabaseName>'', @SchemaName = ''<SchemaName>'', @TableName = ''<TableName>'', @IndexName = ''<IndexName>'''                                                   , 'FreeLogSpaceCheckSQL'                            , NULL                                                                                  , 4     , 0                 , 0)
,('CreateMissing'                       , 'FreeSpaceValidationTempDb'                                   , 1                     , 'DOI.spQueue_GenerateSQL_FreeSpaceValidationTempDb @DatabaseName = ''<DatabaseName>'', @SchemaName = ''<SchemaName>'', @TableName = ''<TableName>'', @IndexName = ''<IndexName>'''                                                   , 'FreeTempDBSpaceCheckSQL'                         , NULL                                                                                  , 5     , 0                 , 0)
,('CreateMissing'                       , 'IndexCreate'                                                 , 1                     , 'DOI.spQueue_GenerateSQL_CreateIndex @DatabaseName = ''<DatabaseName>'', @SchemaName = ''<SchemaName>'', @TableName = ''<TableName>'', @IndexName = ''<IndexName>'''                                  , NULL                                                                                  , 6     , 0                 , 0)
,('CreateMissing'                       , 'ApplicationLockRelease'                                      , 1                     , 'DOI.spRun_ReleaseApplicationLock @DatabaseName = ''<DatabaseName>'', @BatchId = ''00000000-0000-0000-0000-000000000000'''                       , NULL                                                                                  , 7     , 0                 , 0)
                                                                                                                            
,('CreateDropExisting'                  , 'ResourceGovernorEnable'                                      , 1                     , NULL                                                          , NULL                                              , 'EXEC DOI.spRun_ReEnableResourceGovernor'                                             , 1     , 0                 , 1)
,('CreateDropExisting'                  , 'ApplicationLockGet'                                          , 1                     , 'DOI.spRun_GetApplicationLock @DatabaseName = ''<DatabaseName>'', @BatchId = ''00000000-0000-0000-0000-000000000000'''                                                   , 'GetApplicationLockSQL'                           , NULL                                                                                  , 2     , 0                 , 1)
,('CreateDropExisting'                  , 'FreeSpaceValidationData'                                     , 1                     , 'vwIndexes'                                                   , 'FreeDataSpaceCheckSQL'                           , NULL                                                                                  , 3     , 0                 , 0)
,('CreateDropExisting'                  , 'FreeSpaceValidationLog'                                      , 1                     , 'vwIndexes'                                                   , 'FreeLogSpaceCheckSQL'                            , NULL                                                                                  , 4     , 0                 , 0)
,('CreateDropExisting'                  , 'FreeSpaceValidationTempDb'                                   , 1                     , 'vwIndexes'                                                   , 'FreeTempDBSpaceCheckSQL'                         , NULL                                                                                  , 5     , 0                 , 0)
,('CreateDropExisting'                  , 'IndexCreateDropExisting'                                     , 1                     , 'vwIndexes'                                                   , 'CreateDropExistingStatement'                     , NULL                                                                                  , 6     , 0                 , 0)
,('CreateDropExisting'                  , 'ApplicationLockRelease'                                      , 1                     , 'vwIndexes'                                                   , 'ReleaseApplicationLockSQL'                       , NULL                                                                                  , 7     , 0                 , 0)
                                                                                                                            
,('DropRecreate'                        , 'ResourceGovernorDisable'                                     , 1                     , NULL                                                          , NULL                                              , 'EXEC DOI.spRun_ReEnableResourceGovernor'                                             , 1     , 1                 , 1)
,('DropRecreate'                        , 'ApplicationLockGet'                                          , 1                     , 'DOI.spRun_GetApplicationLock @DatabaseName = ''<DatabaseName>'', @BatchId = ''00000000-0000-0000-0000-000000000000'''                                                   , 'GetApplicationLockSQL'                           , NULL                                                                                  , 2     , 1                 , 1)
,('DropRecreate'                        , 'FreeSpaceValidationData'                                     , 1                     , 'vwIndexes'                                                   , 'FreeDataSpaceCheckSQL'                           , NULL                                                                                  , 3     , 1                 , 0)
,('DropRecreate'                        , 'FreeSpaceValidationLog'                                      , 1                     , 'vwIndexes'                                                   , 'FreeLogSpaceCheckSQL'                            , NULL                                                                                  , 4     , 1                 , 0)
,('DropRecreate'                        , 'FreeSpaceValidationTempDb'                                   , 1                     , 'vwIndexes'                                                   , 'FreeTempDBSpaceCheckSQL'                         , NULL                                                                                  , 5     , 1                 , 0)
,('DropRecreate'                        , 'BeginTran'                                                   , 1                     , NULL                                                          , NULL                                              , 'SET TRANSACTION ISOLATION LEVEL SERIALIZABLE' + CHAR(13) + CHAR(10) + 'BEGIN TRAN'   , 6     , 1                 , 0)
,('DropRecreate'                        , 'IndexDrop'                                                   , 1                     , 'vwIndexes'                                                   , 'CreateDropExistingStatement'                     , NULL                                                                                  , 7     , 1                 , 0)
,('DropRecreate'                        , 'IndexCreate'                                                 , 1                     , 'vwIndexes'                                                   , 'ReleaseApplicationLockSQL'                       , NULL                                                                                  , 8     , 1                 , 0)
,('DropRecreate'                        , 'CommitTran'                                                  , 1                     , NULL                                                          , NULL                                              , 'COMMIT TRAN'                                                                         , 9     , 1                 , 0)
,('DropRecreate'                        , 'ApplicationLockRelease'                                      , 1                     , 'vwIndexes'                                                   , 'ReleaseApplicationLockSQL'                       , NULL                                                                                  , 10    , 1                 , 0)
                                                                                                                           
,('AlterRebuild-Online'                 , 'ResourceGovernorEnable'                                      , 1                     , NULL                                                          , NULL                                              , 'EXEC DOI.spRun_ReEnableResourceGovernor'                                             , 1     , 0                 , 1)
,('AlterRebuild-Online'                 , 'ApplicationLockGet'                                          , 1                     , 'vwIndexes'                                                   , 'GetApplicationLockSQL'                           , NULL                                                                                  , 2     , 0                 , 1)
,('AlterRebuild-Online'                 , 'FreeSpaceValidationData'                                     , 1                     , 'vwIndexes'                                                   , 'FreeDataSpaceCheckSQL'                           , NULL                                                                                  , 3     , 0                 , 0)
,('AlterRebuild-Online'                 , 'FreeSpaceValidationLog'                                      , 1                     , 'vwIndexes'                                                   , 'FreeLogSpaceCheckSQL'                            , NULL                                                                                  , 4     , 0                 , 0)
,('AlterRebuild-Online'                 , 'FreeSpaceValidationTempDb'                                   , 1                     , 'vwIndexes'                                                   , 'FreeTempDBSpaceCheckSQL'                         , NULL                                                                                  , 5     , 0                 , 0)
,('AlterRebuild-Online'                 , 'IndexAlterRebuild-Online'                                    , 1                     , 'vwIndexes'                                                   , 'AlterRebuildStatementOnline'                     , NULL                                                                                  , 6     , 0                 , 0)
,('AlterRebuild-Online'                 , 'ApplicationLockRelease'                                      , 1                     , 'vwIndexes'                                                   , 'ReleaseApplicationLockSQL'                       , NULL                                                                                  , 7     , 0                 , 0)
                                                                                                                            
,('AlterRebuild-Offline'                , 'ResourceGovernorDisable'                                     , 1                     , NULL                                                          , NULL                                              , 'EXEC DOI.spRun_DisableResourceGovernor'                                              , 1     , 0                 , 1)
,('AlterRebuild-Offline'                , 'ApplicationLockGet'                                          , 1                     , 'vwIndexes'                                                   , 'GetApplicationLockSQL'                           , NULL                                                                                  , 2     , 0                 , 1)
,('AlterRebuild-Offline'                , 'FreeSpaceValidationData'                                     , 1                     , 'vwIndexes'                                                   , 'FreeDataSpaceCheckSQL'                           , NULL                                                                                  , 3     , 0                 , 0)
,('AlterRebuild-Offline'                , 'FreeSpaceValidationLog'                                      , 1                     , 'vwIndexes'                                                   , 'FreeLogSpaceCheckSQL'                            , NULL                                                                                  , 4     , 0                 , 0)
,('AlterRebuild-Offline'                , 'FreeSpaceValidationTempDb'                                   , 1                     , 'vwIndexes'                                                   , 'FreeTempDBSpaceCheckSQL'                         , NULL                                                                                  , 5     , 0                 , 0)
,('AlterRebuild-Offline'                , 'IndexAlterRebuild-Offline'                                   , 1                     , 'vwIndexes'                                                   , 'AlterRebuildStatementOffline'                    , NULL                                                                                  , 6     , 0                 , 0)
,('AlterRebuild-Offline'                , 'ApplicationLockRelease'                                      , 1                     , 'vwIndexes'                                                   , 'ReleaseApplicationLockSQL'                       , NULL                                                                                  , 7     , 0                 , 0)
                                                                                                                            
,('AlterSet'                            , 'ResourceGovernorEnable'                                      , 1                     , NULL                                                          , NULL                                              , 'EXEC DOI.spRun_ReEnableResourceGovernor'                                             , 1     , 0                 , 1)
,('AlterSet'                            , 'ApplicationLockGet'                                          , 1                     , 'vwIndexes'                                                   , 'GetApplicationLockSQL'                           , NULL                                                                                  , 2     , 0                 , 1)
,('AlterSet'                            , 'IndexAlterSet'                                               , 1                     , 'vwIndexes'                                                   , 'AlterSetStatement'                               , NULL                                                                                  , 3     , 0                 , 0)
,('AlterSet'                            , 'ApplicationLockRelease'                                      , 1                     , 'vwIndexes'                                                   , 'ReleaseApplicationLockSQL'                       , NULL                                                                                  , 4     , 0                 , 0)
                                                                                                                             
,('AlterReorganize'                     , 'ResourceGovernorEnable'                                      , 1                     , NULL                                                          , NULL                                              , 'EXEC DOI.spRun_ReEnableResourceGovernor'                                             , 1     , 0                 , 1)
,('AlterReorganize'                     , 'ApplicationLockGet'                                          , 1                     , 'vwIndexes'                                                   , 'GetApplicationLockSQL'                           , NULL                                                                                  , 2     , 0                 , 1)
,('AlterReorganize'                     , 'FreeSpaceValidationData'                                     , 1                     , 'vwIndexes'                                                   , 'FreeDataSpaceCheckSQL'                           , NULL                                                                                  , 3     , 0                 , 0)
,('AlterReorganize'                     , 'FreeSpaceValidationLog'                                      , 1                     , 'vwIndexes'                                                   , 'FreeLogSpaceCheckSQL'                            , NULL                                                                                  , 4     , 0                 , 0)
,('AlterReorganize'                     , 'FreeSpaceValidationTempDb'                                   , 1                     , 'vwIndexes'                                                   , 'FreeTempDBSpaceCheckSQL'                         , NULL                                                                                  , 5     , 0                 , 0)
,('AlterReorganize'                     , 'IndexAlterReorganize'                                        , 1                     , 'vwIndexes'                                                   , 'AlterReorganizeStatement'                        , NULL                                                                                  , 6     , 0                 , 0)
,('AlterReorganize'                     , 'ApplicationLockRelease'                                      , 1                     , 'vwIndexes'                                                   , 'ReleaseApplicationLockSQL'                       , NULL                                                                                  , 7     , 0                 , 0)
                                                                                                                             
,('AlterRebuild-PartitionLevel-Online'  , 'ResourceGovernorEnable'                                      , 1                     , NULL                                                          , NULL                                              , 'EXEC DOI.spRun_ReEnableResourceGovernor'                                             , 1     , 0                 , 1)
,('AlterRebuild-PartitionLevel-Online'  , 'ApplicationLockGet'                                          , 1                     , 'vwIndexPartitions'                                           , 'GetApplicationLockSQL'                           , NULL                                                                                  , 2     , 0                 , 1)
,('AlterRebuild-PartitionLevel-Online'  , 'FreeSpaceValidationData'                                     , 1                     , 'vwIndexPartitions'                                           , 'FreeDataSpaceCheckSQL'                           , NULL                                                                                  , 3     , 0                 , 0)
,('AlterRebuild-PartitionLevel-Online'  , 'FreeSpaceValidationLog'                                      , 1                     , 'vwIndexPartitions'                                           , 'FreeLogSpaceCheckSQL'                            , NULL                                                                                  , 4     , 0                 , 0)
,('AlterRebuild-PartitionLevel-Online'  , 'FreeSpaceValidationTempDb'                                   , 1                     , 'vwIndexPartitions'                                           , 'FreeTempDBSpaceCheckSQL'                         , NULL                                                                                  , 5     , 0                 , 0)
,('AlterRebuild-PartitionLevel-Online'  , 'IndexAlterRebuild-PartitionLevel-Online'                     , 1                     , 'vwIndexPartitions'                                           , 'AlterRebuildStatementOnline'                     , NULL                                                                                  , 6     , 0                 , 0)
,('AlterRebuild-PartitionLevel-Online'  , 'ApplicationLockRelease'                                      , 1                     , 'vwIndexPartitions'                                           , 'ReleaseApplicationLockSQL'                       , NULL                                                                                  , 7     , 0                 , 0)
                                                                                                                             
,('AlterRebuild-PartitionLevel-Offline' , 'ResourceGovernorDisable'                                     , 1                     , NULL                                                          , NULL                                              , 'EXEC DOI.spRun_DisableResourceGovernor'                                              , 1     , 0                 , 1)
,('AlterRebuild-PartitionLevel-Offline' , 'ApplicationLockGet'                                          , 1                     , 'vwIndexPartitions'                                           , 'GetApplicationLockSQL'                           , NULL                                                                                  , 2     , 0                 , 1)
,('AlterRebuild-PartitionLevel-Offline' , 'FreeSpaceValidationData'                                     , 1                     , 'vwIndexPartitions'                                           , 'FreeDataSpaceCheckSQL'                           , NULL                                                                                  , 3     , 0                 , 0)
,('AlterRebuild-PartitionLevel-Offline' , 'FreeSpaceValidationLog'                                      , 1                     , 'vwIndexPartitions'                                           , 'FreeLogSpaceCheckSQL'                            , NULL                                                                                  , 4     , 0                 , 0)
,('AlterRebuild-PartitionLevel-Offline' , 'FreeSpaceValidationTempDb'                                   , 1                     , 'vwIndexPartitions'                                           , 'FreeTempDBSpaceCheckSQL'                         , NULL                                                                                  , 5     , 0                 , 0)
,('AlterRebuild-PartitionLevel-Offline' , 'IndexAlterRebuild-PartitionLevel-Offline'                    , 1                     , 'vwIndexPartitions'                                           , 'AlterRebuildStatementOffline'                    , NULL                                                                                  , 6     , 0                 , 0)
,('AlterRebuild-PartitionLevel-Offline' , 'ApplicationLockRelease'                                      , 1                     , 'vwIndexPartitions'                                           , 'ReleaseApplicationLockSQL'                       , NULL                                                                                  , 7     , 0                 , 0)
                                                                                                                            
,('AlterReorganize-PartitionLevel'      , 'ResourceGovernorEnable'                                      , 1                     , NULL                                                          , NULL                                              , 'EXEC DOI.spRun_ReEnableResourceGovernor'                                             , 1     , 0                 , 1)
,('AlterReorganize-PartitionLevel'      , 'ApplicationLockGet'                                          , 1                     , 'vwIndexPartitions'                                           , 'GetApplicationLockSQL'                           , NULL                                                                                  , 2     , 0                 , 1)
,('AlterReorganize-PartitionLevel'      , 'FreeSpaceValidationData'                                     , 1                     , 'vwIndexPartitions'                                           , 'FreeDataSpaceCheckSQL'                           , NULL                                                                                  , 3     , 0                 , 0)
,('AlterReorganize-PartitionLevel'      , 'FreeSpaceValidationLog'                                      , 1                     , 'vwIndexPartitions'                                           , 'FreeLogSpaceCheckSQL'                            , NULL                                                                                  , 4     , 0                 , 0)
,('AlterReorganize-PartitionLevel'      , 'FreeSpaceValidationTempDb'                                   , 1                     , 'vwIndexPartitions'                                           , 'FreeTempDBSpaceCheckSQL'                         , NULL                                                                                  , 5     , 0                 , 0)
,('AlterReorganize-PartitionLevel'      , 'IndexAlterReorganize-PartitionLevel'                         , 1                     , 'vwIndexPartitions'                                           , 'AlterReorganizeStatement'                        , NULL                                                                                  , 6     , 0                 , 0)
,('AlterReorganize-PartitionLevel'      , 'ApplicationLockRelease'                                      , 1                     , 'vwIndexPartitions'                                           , 'ReleaseApplicationLockSQL'                       , NULL                                                                                  , 7     , 0                 , 0)
                                                                                                                            
--Statistics operations                                                                                                     
,('CreateStatistics'                   , 'ResourceGovernorEnable'                                       , 1                     , NULL                                                          , NULL                                              , 'EXEC DOI.spRun_ReEnableResourceGovernor'                                             , 1     , 0                 , 1)
,('CreateStatistics'                   , 'ApplicationLockGet'                                           , 1                     , 'vwStatistics'                                                , 'GetApplicationLockSQL'                           , NULL                                                                                  , 2     , 0                 , 1)
,('CreateStatistics'                   , 'FreeSpaceValidationData'                                      , 1                     , 'vwStatistics'                                                , 'FreeDataSpaceCheckSQL'                           , NULL                                                                                  , 3     , 0                 , 0)
,('CreateStatistics'                   , 'FreeSpaceValidationLog'                                       , 1                     , 'vwStatistics'                                                , 'FreeLogSpaceCheckSQL'                            , NULL                                                                                  , 4     , 0                 , 0)
,('CreateStatistics'                   , 'FreeSpaceValidationTempDb'                                    , 1                     , 'vwStatistics'                                                , 'FreeTempDBSpaceCheckSQL'                         , NULL                                                                                  , 5     , 0                 , 0)
,('CreateStatistics'                   , 'StatisticsCreate'                                             , 1                     , 'vwStatistics'                                                , 'CreateStatisticsSQL'                             , NULL                                                                                  , 6     , 0                 , 0)
,('CreateStatistics'                   , 'ApplicationLockRelease'                                       , 1                     , 'vwStatistics'                                                , 'ReleaseApplicationLockSQL'                       , NULL                                                                                  , 7     , 0                 , 0)
                                                                                                                            
,('DropRecreateStatistics'             , 'ResourceGovernorEnable'                                       , 1                     , NULL                                                          , NULL                                              , 'EXEC DOI.spRun_ReEnableResourceGovernor'                                             , 1     , 1                 , 1)
,('DropRecreateStatistics'             , 'ApplicationLockGet'                                           , 1                     , 'vwStatistics'                                                , 'GetApplicationLockSQL'                           , NULL                                                                                  , 2     , 1                 , 1)
,('DropRecreateStatistics'             , 'FreeSpaceValidationData'                                      , 1                     , 'vwStatistics'                                                , 'FreeDataSpaceCheckSQL'                           , NULL                                                                                  , 3     , 1                 , 0)
,('DropRecreateStatistics'             , 'FreeSpaceValidationLog'                                       , 1                     , 'vwStatistics'                                                , 'FreeLogSpaceCheckSQL'                            , NULL                                                                                  , 4     , 1                 , 0)
,('DropRecreateStatistics'             , 'FreeSpaceValidationTempDb'                                    , 1                     , 'vwStatistics'                                                , 'FreeTempDBSpaceCheckSQL'                         , NULL                                                                                  , 5     , 1                 , 0)
,('DropRecreateStatistics'             , 'BeginTran'                                                    , 1                     , NULL                                                          , NULL                                              , 'SET TRANSACTION ISOLATION LEVEL SERIALIZABLE' + CHAR(13) + CHAR(10) + 'BEGIN TRAN'   , 6     , 1                 , 0)
,('DropRecreateStatistics'             , 'StatisticsDropRecreate'                                       , 1                     , 'vwStatistics'                                                , 'DropReCreateStatisticsSQL'                       , NULL                                                                                  , 7     , 1                 , 0)
,('DropRecreateStatistics'             , 'CommitTran'                                                   , 1                     , NULL                                                          , NULL                                              , 'COMMIT TRAN'                                                                         , 8     , 1                 , 0)
,('DropRecreateStatistics'             , 'ApplicationLockRelease'                                       , 1                     , 'vwStatistics'                                                , 'ReleaseApplicationLockSQL'                       , NULL                                                                                  , 9     , 1                 , 0)
                                                                                                                            
,('UpdateStatistics'                   , 'ResourceGovernorEnable'                                       , 1                     , NULL                                                          , NULL                                              , 'EXEC DOI.spRun_ReEnableResourceGovernor'                                             , 1     , 0                 , 1)
,('UpdateStatistics'                   , 'ApplicationLockGet'                                           , 1                     , 'vwStatistics'                                                , 'GetApplicationLockSQL'                           , NULL                                                                                  , 2     , 0                 , 1)
,('UpdateStatistics'                   , 'FreeSpaceValidationData'                                      , 1                     , 'vwStatistics'                                                , 'FreeDataSpaceCheckSQL'                           , NULL                                                                                  , 3     , 0                 , 0)
,('UpdateStatistics'                   , 'FreeSpaceValidationLog'                                       , 1                     , 'vwStatistics'                                                , 'FreeLogSpaceCheckSQL'                            , NULL                                                                                  , 4     , 0                 , 0)
,('UpdateStatistics'                   , 'FreeSpaceValidationTempDb'                                    , 1                     , 'vwStatistics'                                                , 'FreeTempDBSpaceCheckSQL'                         , NULL                                                                                  , 5     , 0                 , 0)
,('UpdateStatistics'                   , 'StatisticsUpdate'                                             , 1                     , 'vwStatistics'                                                , 'UpdateStatisticsSQL'                             , NULL                                                                                  , 6     , 0                 , 0)
,('UpdateStatistics'                   , 'StatisticsRename'                                             , 1                     , 'EXEC DOI.spQueue_RenameStatistics'                                                , 'StatisticsSQL'                             , NULL                                                                                  , 6     , 0                 , 0)

,('UpdateStatistics'                   , 'ApplicationLockRelease'                                       , 1                     , 'vwStatistics'                                                , 'ReleaseApplicationLockSQL'                       , NULL                                                                                  , 7     , 0                 , 0)

--take into account users choosing between online and offline options
--add FK to both lookup tables

/*
in the queue SP, write code generator that uses IndexUpdateTypeOperations table.  loop through each row there and generate SELECT SQLColumnName from the ViewName for that table/index.
below is this code:

SELECT I.DatabaseName, I.SchemaName, I.TableName, I.IndexName, 
    CASE 
        WHEN COALESCE(IUTO.ViewName, IUTO.SQLColumnName) IS NOT NULL 
        THEN '
    SELECT ' + IUTO.SQLColumnName + ' 
    FROM DOI.' + IUTO.ViewName + ' 
    WHERE DatabaseName = ''' + I.DatabaseName + ''' 
        AND SchemaName = ''' + I.SchemaName + ''' 
        AND TableName = ''' + I.TableName + ''''
        ELSE '
    SELECT ' + IUTO.SQLLiteral + CHAR(13) + CHAR(10)
    END AS x,
    IUTO.SeqNo
FROM DOI.vwIndexes I
    INNER JOIN DOI.IndexUpdateTypeOperations IUTO ON IUTO.IndexUpdateType = I.IndexUpdateType
ORDER BY I.DatabaseName, I.SchemaName, I.TableName, IUTO.SeqNo
*/

