DROP TABLE IF EXISTS DOI.IndexUpdateTypeOperations
DROP TABLE IF EXISTS DOI.IndexOperation
DROP TABLE IF EXISTS DOI.IndexUpdateType

CREATE TABLE DOI.IndexOperation (Category VARCHAR(50) NOT NULL, IndexOperation VARCHAR(70) PRIMARY KEY CLUSTERED, ObjectType VARCHAR(50) NOT NULL)

INSERT INTO DOI.IndexOperation(IndexOperation, Category, ObjectType, Action, Section)
VALUES
('ApplicationLock', 'ApplicationLockGet'       , 'Application Lock')
,('ApplicationLock', 'ApplicationLockRelease'   , 'Application Lock')

,('Transaction', 'BeginTran'    , 'Transaction')
,('Transaction', 'CommitTran'   , 'Transaction')

,('Databases', 'Change DB', 'Database')

,('CmdShell', 'CmdShellDisable' , 'CmdShell')
,('CmdShell', 'CmdShellEnable'  , 'CmdShell')

,('Constraints', 'Check Constraint SQL'     , 'Constraint')
,('Constraints', 'ConstraintCreate'         , 'Constraint')
,('Constraints', 'ConstraintCreateNewTable' , 'Constraint')

,('DataSynch', 'DataSynchTableCreate'   , 'Table')
,('DataSynch', 'DataSynchTableDrop'     , 'Table')
,('DataSynch', 'DataSynchTriggerCreate' , 'Trigger')
,('DataSynch', 'DataSynchTriggerDrop'   , 'Trigger')
,('DataSynch', 'DataSynchTurnOff'       , 'Data')
,('DataSynch', 'DataSynchTurnOn'        , 'Data')
,('DataSynch', 'DataSynchUpdates'       , 'Data')
,('DataSynch', 'DataSynchInserts'       , 'Data')
,('DataSynch', 'DataSynchDeletes'       , 'Data')

,('FinalDataSynch', 'FinalDataSynchTableCreate'   , 'Table')
,('FinalDataSynch', 'FinalDataSynchTriggerCreate' , 'Trigger')

,('Miscellaneous', 'Clean Up Tables'            , 'Table')
,('Miscellaneous', 'Clear Queue of Other Tables', 'Data')
,('Miscellaneous', 'Delay'                      , 'Process')
,('Miscellaneous', 'Kill'                       , 'Process')
,('Miscellaneous', 'Rollback DDL'               , 'Process')
,('Miscellaneous', 'Manual SQL Command'         , 'Process')
,('Miscellaneous', 'Stop Processing'            , 'Process')

,('LoadData', 'LoadDataBCPViewCreate'   , 'View')
,('LoadData', 'LoadDataBCPViewDrop'     , 'View')
,('LoadData', 'LoadData'                , 'Table')

,('Foreign Keys', 'FKsAddBackParentTable'   , 'Foreign Keys')
,('Foreign Keys', 'FKsAddBackRefTable'      , 'Foreign Keys')
,('Foreign Keys', 'FKsDropParentTable'      , 'Foreign Keys')
,('Foreign Keys', 'FKsDropRefTable'         , 'Foreign Keys')
,('Foreign Keys', 'FKsRecreateAll'          , 'Foreign Keys')

,('Indexes', 'IndexAlter'              , 'Index')
,('Indexes', 'IndexCreate'             , 'Index')
,('Indexes', 'IndexCreateDropExisting' , 'Index')
,('Indexes', 'IndexCreateNewTable'     , 'Index')
,('Indexes', 'IndexDrop'               , 'Index')

,('PartitionState', 'PartitionStateMetadataDelete'      , 'Data')
,('PartitionState', 'PartitionStateMetadataValidation'  , 'Data')

,('PartitionSwitch', 'PartitionSwitch', 'Table')

,('Queue', 'QueueDeleteTransaction'     , 'Queue')
,('Queue', 'QueueUpdateToIn-Progress'   , 'Queue')

,('RenameDataSynch'     , 'RenameDataSynchTable'    , 'Table')
,('RenameExistingTable' , 'RenameExistingTable'     , 'Table')
,('RenameExistingTable' , 'RenameExistingConstraint', 'Constraint')
,('RenameExistingTable' , 'RenameExistingIndex'     , 'Index')
,('RenameExistingTable' , 'RenameExistingStatistic' , 'Statistic')
,('RenameNewTable'      , 'RenameNewTable'          , 'Table')
,('RenameNewTable'      , 'RenameNewTableConstraint', 'Constraint')
,('RenameNewTable'      , 'RenameNewTableIndex'     , 'Index')
,('RenameNewTable'      , 'RenameNewTableStatistic' , 'Statistic')

,('ResourceGovernor', 'ResourceGovernorSettingsCheck'   , 'ResourceGovernor')
,('ResourceGovernor', 'ResourceGovernorDisable'         , 'ResourceGovernor')
,('ResourceGovernor', 'ResourceGovernorEnable'          , 'ResourceGovernor')

,('RevertRename', 'RevertRenameCreateTrigger'   , 'RevertRename')
,('RevertRename', 'RevertRenameDataSynchTrigger', 'RevertRename')
,('RevertRename', 'RevertRenameDropTrigger'     , 'RevertRename')
,('RevertRename', 'RevertRenameTable'           , 'RevertRename')
,('RevertRename', 'RevertRenameTableConstraint' , 'RevertRename')
,('RevertRename', 'RevertRenameTableIndex'      , 'RevertRename')
,('RevertRename', 'RevertRenameTableStatistics' , 'Revert')

,('Statistics', 'StatisticsUpdate'          , 'Statistics')
,('Statistics', 'StatisticsCreate'          , 'Statistics')
,('Statistics', 'StatisticsCreateMissing'   , 'Statistics')
,('Statistics', 'StatisticsCreateNewTable'  , 'Statistics')
,('Statistics', 'StatisticsDrop'            , 'Statistics')

,('Tables', 'Partition Prep Table SQL'  , 'Tables')
,('Tables', 'Prep Table SQL'            , 'Tables')
,('Tables', 'CreateNewTable'            , 'Tables')
,('Tables', 'TableDrop'                 , 'Tables')
,('Tables', 'Temp Table SQL'            , 'Tables')

,('Triggers', 'TriggerCreate'   , 'Triggers')
,('Triggers', 'TriggerDrop'     , 'Triggers')

,('Validation', 'FreeSpaceValidationData'       , 'Space')
,('Validation', 'FreeSpaceValidationLog'        , 'Space')
,('Validation', 'FreeSpaceValidationTempDb'     , 'Space')
,('Validation', 'ValidationFinal'               , 'Validation')
,('Validation', 'ValidationPartitionData'       , 'Data')
,('Validation', 'ValidationPostPartitioningData', 'Data')
,('Validation', 'ValidationPriorError'          , 'Error')

                                          
CREATE TABLE DOI.IndexUpdateType (
    IndexUpdateType VARCHAR(50) PRIMARY KEY CLUSTERED,
    IsOnlineOperation BIT NOT NULL);
GO

INSERT INTO DOI.IndexUpdateType(IndexUpdateType, IsOnlineOperation)
VALUES
 ('Delete', 1)
,('CreateMissing', 1)
,('CreateDropExisting', 1)
,('ExchangeTableNonPartitioned', 1)
,('ExchangeTablePartitioned', 1)
,('AlterRebuild-Online', 1)
,('AlterRebuild-PartitionLevel-Online', 1)
,('DropRecreate', 0)
,('AlterRebuild-Offline', 0)
,('AlterRebuild-PartitionLevel-Offline', 0)
,('AlterSet', 1)
,('AlterReorganize', 1)
,('AlterReorganize-PartitionLevel', 1)
,('Create Statistics', 1)
,('DropRecreate Statistics', 0)
,('Update Statistics', 1)
,('None', 1);



CREATE TABLE DOI.IndexUpdateTypeOperations (
    IndexUpdateType VARCHAR(50) NOT NULL  
        CONSTRAINT FK_IndexUpdateTypeOperations_IndexUpdateType
            FOREIGN KEY REFERENCES DOI.IndexUpdateType(IndexUpdateType),
    IndexOperation VARCHAR(70) NOT NULL
        CONSTRAINT FK_IndexUpdateTypeOperations_IndexOperation
            FOREIGN KEY REFERENCES DOI.IndexOperation(IndexOperation),
    ViewName NVARCHAR(128) NULL,
    SQLColumnName NVARCHAR(128) NULL,
    SQLLiteral NVARCHAR(128) NULL,
    SeqNo INT NOT NULL,
    CONSTRAINT PK_IndexUpdateTypeOperations
        PRIMARY KEY CLUSTERED (IndexUpdateType, IndexOperation),
    CONSTRAINT Chk_IndexUpdateTypeOperations_SQLLiteralOrNot
        CHECK ((ViewName IS NULL AND SQLColumnName IS NULL AND SQLLiteral IS NOT NULL)
                    OR (ViewName IS NOT NULL AND SQLColumnName IS NOT NULL AND SQLLiteral IS NULL)));
GO

INSERT INTO DOI.IndexUpdateTypeOperations(IndexUpdateType, IndexOperation, ViewName, SQLColumnName, SQLLiteral, SeqNo)
VALUES
--table switch, non-partitioned
 ('ExchangeTableNonPartitioned'         , 'Enable Resource Governor'                                    , NULL                                                          , NULL                                              , 'EXEC DOI.spRun_ReEnableResourceGovernor'                                             , 1)
,('ExchangeTableNonPartitioned'         , 'Get Application Lock'                                        , 'vwExchangeTableNonPartitioned_Tables_NewTable'               , 'GetApplicationLockSQL'                           , NULL                                                                                  , 1)
,('ExchangeTableNonPartitioned'         , 'Free Data Space Validation'                                  , 'vwExchangeTableNonPartitioned_Tables_NewTable'               , 'FreeDataSpaceCheckSQL'                           , NULL                                                                                  , 1)
,('ExchangeTableNonPartitioned'         , 'Free Log Space Validation'                                   , 'vwExchangeTableNonPartitioned_Tables_NewTable'               , 'FreeLogSpaceCheckSQL'                            , NULL                                                                                  , 1)
,('ExchangeTableNonPartitioned'         , 'Free TempDB Space Validation'                                , 'vwExchangeTableNonPartitioned_Tables_NewTable'               , 'FreeTempDBSpaceCheckSQL'                         , NULL                                                                                  , 1)
,('ExchangeTableNonPartitioned'         , 'CreateNewTable'                  , 'vwExchangeTableNonPartitioned_Tables_NewTable'               , 'CreateNewTableSQL'                               , NULL                                                                                  , 1)
,('ExchangeTableNonPartitioned'         , 'CreateNewTableConstraints'       , 'vwExchangeTableNonPartitioned_Tables_NewTable_Constraints'   , 'CreateConstraintStatement'                       , NULL                                                                                  , 2)
,('ExchangeTableNonPartitioned'         , 'CreateDataSynchTable'            , 'vwExchangeTableNonPartitioned_Tables_NewTable'               , 'CreateDataSynchTableSQL'                         , NULL                                                                                  , 3)
,('ExchangeTableNonPartitioned'         , 'CreateDataSynchTrigger'          , 'vwExchangeTableNonPartitioned_Tables_NewTable'               , 'CreateDataSynchTriggerSQL'                       , NULL                                                                                  , 4)
--Rename 2 data synch process to 'partition data synch' and 'table data synch'.
,('ExchangeTablePartitioned'            , 'EnableCmdShell'                     , 'vwExchangeTableNonPartitioned_Tables_NewTable'               , 'EnableCmdShellSQL'                               , NULL                                                                                  , 4)
,('ExchangeTableNonPartitioned'         , 'CreateViewForBCP'                , 'vwExchangeTableNonPartitioned_Tables_NewTable'               , 'CreateViewForBCPSQL'                             , NULL                                                                                  , 5)
,('ExchangeTableNonPartitioned'         , 'LoadData'                        , 'vwExchangeTableNonPartitioned_Tables_NewTable'               , 'BCPSQL'                                          , NULL                                                                                  , 6)
,('ExchangeTablePartitioned'            , 'DisableCmdShell'                    , 'vwExchangeTableNonPartitioned_Tables_NewTable'               , 'DisableCmdShellSQL'                              , NULL                                                                                  , 7)
,('ExchangeTableNonPartitioned'         , 'CreateNewTableIndexes'           , 'vwExchangeTableNonPartitioned_Tables_NewTable_Indexes'       , 'NewTableIndexCreateSQL'                          , NULL                                                                                  , 8)
,('ExchangeTableNonPartitioned'         , 'CreateNewTableStatistics'        , 'vwExchangeTableNonPartitioned_Tables_NewTable_Statistics'    , 'CreateStatisticsStatement'                       , NULL                                                                                  , 9)
,('ExchangeTableNonPartitioned'         , 'BeginTran'                       , NULL                                                          , NULL                                              , 'SET TRANSACTION ISOLATION LEVEL SERIALIZABLE' + CHAR(13) + CHAR(10) + 'BEGIN TRAN'   , 10)
,('ExchangeTableNonPartitioned'         , 'RenameExistingIndex'             , 'vwExchangeTableNonPartitioned_Tables_NewTable_Indexes'       , 'RenameExistingTableIndexSQL'                     , NULL                                                                                  , 11)
,('ExchangeTableNonPartitioned'         , 'RenameNewTableIndex'             , 'vwExchangeTableNonPartitioned_Tables_NewTable_Indexes'       , 'RenameNewTableIndexSQL'                          , NULL                                                                                  , 12)
,('ExchangeTableNonPartitioned'         , 'RenameExistingTableStatistic'    , 'vwExchangeTableNonPartitioned_Tables_NewTable_Statistics'    , 'RenameExistingTableStatisticsSQL'                , NULL                                                                                  , 13)
,('ExchangeTableNonPartitioned'         , 'RenameNewTableStatistic'         , 'vwExchangeTableNonPartitioned_Tables_NewTable_Statistics'    , 'RenameNewTableStatisticsSQL'                     , NULL                                                                                  , 14)
,('ExchangeTableNonPartitioned'         , 'RenameExistingTableConstraint'   , 'vwExchangeTableNonPartitioned_Tables_NewTable_Constraints'   , 'RenameExistingTableConstraintSQL'                , NULL                                                                                  , 15)
,('ExchangeTableNonPartitioned'         , 'RenameNewTableConstraint'        , 'vwExchangeTableNonPartitioned_Tables_NewTable_Constraints'   , 'RenameNewTableConstraintSQL'                     , NULL                                                                                  , 16)
,('ExchangeTableNonPartitioned'         , 'DropTrigger'                     , 'vwExchangeTableNonPartitioned_Tables_NewTable_Triggers'      , 'DropTriggerSQL'                                  , NULL                                                                                  , 17)
,('ExchangeTableNonPartitioned'         , 'RenameExistingTable'             , 'vwExchangeTableNonPartitioned_Tables_NewTable'               , 'RenameExistingTableSQL'                          , NULL                                                                                  , 18)
,('ExchangeTableNonPartitioned'         , 'RenameNewTable'                  , 'vwExchangeTableNonPartitioned_Tables_NewTable'               , 'RenameNewTableSQL'                               , NULL                                                                                  , 19)
,('ExchangeTableNonPartitioned'         , 'CreateTrigger'                   , 'vwExchangeTableNonPartitioned_Tables_NewTable_Triggers'      , 'CreateTriggerSQL'                                , NULL                                                                                  , 20)
,('ExchangeTableNonPartitioned'         , 'CommitTran'                      , NULL                                                          , NULL                                              , 'COMMIT TRAN'                                                                         , 21)
,('ExchangeTableNonPartitioned'         , 'DropDataSynchTrigger'            , 'vwExchangeTableNonPartitioned_Tables_NewTable'               , 'DropDataSynchTriggerSQL'                         , NULL                                                                                  , 22)
,('ExchangeTableNonPartitioned'         , 'DropDataSynchTable'              , 'vwExchangeTableNonPartitioned_Tables_NewTable'               , 'DropDataSynchTableSQL'                           , NULL                                                                                  , 23)
,('ExchangeTableNonPartitioned'         , 'Release Application Lock'                                    , 'vwExchangeTableNonPartitioned_Tables_NewTable'               , 'ReleaseApplicationLockSQL'                       , NULL                                                                                  , 1)

--table switch, partitioned
/*
--add partition state refresh
--add partition state validation
 ('ExchangeTablePartitioned'            , 'Enable Resource Governor'                                    , NULL                                                          , NULL                                              , 'EXEC DOI.spRun_ReEnableResourceGovernor'                                             , 1)
,('ExchangeTablePartitioned'            , 'Get Application Lock'                                        , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'GetApplicationLockSQL'                           , NULL                                                                                  , 1)
,('ExchangeTablePartitioned'            , 'Free Data Space Validation'                                  , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'FreeDataSpaceCheckSQL'                           , NULL                                                                                  , 1)
,('ExchangeTablePartitioned'            , 'Free Log Space Validation'                                   , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'FreeLogSpaceCheckSQL'                            , NULL                                                                                  , 1)
,('ExchangeTablePartitioned'            , 'Free TempDB Space Validation'                                , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'FreeTempDBSpaceCheckSQL'                         , NULL                                                                                  , 1)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_CreateDataSynchTrigger'             , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.CreateDataSynchTriggerSQL'                    , NULL                                                                                  , 1)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_CreatePrepTable'                    , 'vwPartitioning_Tables_PrepTables'                            , 'PT.CreatePrepTableSQL'                           , NULL                                                                                  , 2)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_TurnOnDataSynch'                    , 'vwPartitioning_Tables_PrepTables'                            , 'PT.TurnOnDataSynchSQL'                           , NULL                                                                                  , 3)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_EnableCmdShell'                     , 'vwPartitioning_Tables_PrepTables'                            , 'PT.EnableCmdShellSQL'                            , NULL                                                                                  , 4)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_CreateViewForBCP'                   , 'vwPartitioning_Tables_PrepTables'                            , 'PT.CreateViewForBCPSQL'                          , NULL                                                                                  , 5)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_LoadData'                           , 'vwPartitioning_Tables_PrepTables'                            , 'PT.BCPSQL'                                       , NULL                                                                                  , 6)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_DisableCmdShell'                    , 'vwPartitioning_Tables_PrepTables'                            , 'PT.DisableCmdShellSQL'                           , NULL                                                                                  , 4)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_CreatePrepTableDataLoadConstraints' , 'vwPartitioning_Tables_PrepTables'                            , 'PT.CheckConstraintSQL'                           , NULL                                                                                  , 7)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_CreatePrepTableIndexes'             , 'vwPartitioning_Tables_PrepTables_Indexes'                    , 'I.PrepTableIndexCreateSQL'                       , NULL                                                                                  , 8)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_CreatePrepTableConstraints'         , 'vwPartitioning_Tables_PrepTables_Constraints'                , 'PTC.CreateConstraintStatement'                   , NULL                                                                                  , 9)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_PriorErrorValidation'               , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.PriorErrorValidationSQL'                      , NULL                                                                                  , 10)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_CreateDataSynchTable'               , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.CreateFinalDataSynchTableSQL'                 , NULL                                                                                  , 11)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_CreateDataSynchTrigger'             , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.CreateFinalDataSynchTriggerSQL'               , NULL                                                                                  , 12)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_TurnOffDataSynch'                   , 'vwPartitioning_Tables_PrepTables'                            , 'PT.TurnOffDataSynchSQL'                          , NULL                                                                                  , 13)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_PartitionDataValidation'            , 'vwPartitioning_Tables_PrepTables_Partitions'                 , 'PT.PartitionDataValidationSQL'                   , NULL                                                                                  , 14)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_BeginTran'                          , NULL                                                          , NULL                                              , 'SET TRANSACTION ISOLATION LEVEL SERIALIZABLE' + CHAR(13) + CHAR(10) + 'BEGIN TRAN'   , 15)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_PartitionSwitch'                    , 'vwPartitioning_Tables_PrepTables_Partitions'                 , 'PT.PartitionSwitchSQL'                           , NULL                                                                                  , 16)
,('ExchangeTablePartitioned'            , 'DropTable SQL'                                               , 'vwPartitioning_Tables_PrepTables_Partitions'                 , 'PT.DropTableSQL'                                 , NULL                                                                                  , 17)
,('ExchangeTablePartitioned'            , 'Commit Tran'                                                 , NULL                                                          , NULL                                              , 'COMMIT TRAN'                                                                         , 18)
,('ExchangeTablePartitioned'            , 'Begin Tran'                                                  , NULL                                                          , NULL                                              , 'SET TRANSACTION ISOLATION LEVEL SERIALIZABLE' + CHAR(13) + CHAR(10) + 'BEGIN TRAN'   , 19)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_RenameExistingTableIndex'           , 'vwPartitioning_Tables_PrepTables_Indexes'                    , 'I.RenameExistingTableIndexSQL'                   , NULL                                                                                  , 20)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_RenameNewPartitionedPrepTableIndex' , 'vwPartitioning_Tables_PrepTables_Indexes'                    , 'I.RenameNewPartitionedPrepTableIndexSQL'         , NULL                                                                                  , 21)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_RenameExistingTableConstraints'     , 'vwPartitioning_Tables_PrepTables_Constraints'                , 'PTC.RenameExistingTableConstraintSQL'            , NULL                                                                                  , 22)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_RenameNewTableConstraints'          , 'vwPartitioning_Tables_PrepTables_Constraints'                , 'PTC.RenameNewPartitionedPrepTableConstraintSQL'  , NULL                                                                                  , 23)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_RenameExistingTableStatistic'       , 'vwPartitioning_Tables_PrepTables_Statistics'                 , 'PTS.RenameExistingTableStatisticsSQL'            , NULL                                                                                  , 24)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_DropTrigger'                        , 'vwPartitioning_Tables_NewPartitionedTable_Triggers'          , 'PTT.DropTriggerSQL'                              , NULL                                                                                  , 25)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_RenameExistingTable'                , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.RenameExistingTableSQL'                       , NULL                                                                                  , 26)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_RenameNewTable'                     , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.RenameNewPartitionedPrepTableSQL'             , NULL                                                                                  , 27)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_CreateTrigger'                      , 'vwPartitioning_Tables_NewPartitionedTable_Triggers'          , 'PTT.CreateTriggerSQL'                            , NULL                                                                                  , 28)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_DropDataSynchTrigger'               , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.DropDataSynchTriggerSQL'                      , NULL                                                                                  , 29)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_SynchDeletes'                       , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.SynchDeletesPrepTableSQL'                     , NULL                                                                                  , 30)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_SynchInserts'                       , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.SynchInsertsPrepTableSQL'                     , NULL                                                                                  , 31)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_SynchUpdates'                       , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.SynchUpdatesPrepTableSQL'                     , NULL                                                                                  , 32)
,('ExchangeTablePartitioned'            , 'Commit Tran'                                                 , NULL                                                          , NULL                                              , 'COMMIT TRAN'                                                                         , 33)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_DropDataSynchTable'                 , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.DropDataSynchTableSQL'                        , NULL                                                                                  , 34)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_DropParentOldTableFKs'              , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.DropParentOldTableFKSQL'                      , NULL                                                                                  , 35)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_DropRefOldTableFKs'                 , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.DropRefOldTableFKSQL'                         , NULL                                                                                  , 36)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_AddBackParentOldTableFKs'           , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.AddBackParentTableFKSQL'                      , NULL                                                                                  , 37)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_AddBackRefOldTableFKs'              , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.AddBackRefTableFKSQL'                         , NULL                                                                                  , 38)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_DeletePartitionStateMetadata'       , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.DeletePartitionStateMetadataSQL'              , NULL                                                                                  , 39)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_PostPartitioningDataValidation'     , 'vwPartitioning_Tables_PrepTables'                            , 'PT.PostDataValidationMissingEventsSQL'           , NULL                                                                                  , 40)
,('ExchangeTablePartitioned'            , 'ExchangeTablePartitioned_CreateMissingStatistic'             , 'vwPartitioning_Tables_PrepTables_Statistics'                 , 'PTS.CreateStatisticsStatement'                   , NULL                                                                                  , 41)
 ('ExchangeTablePartitioned'            , 'Release Application Lock'                                    , 'vwPartitioning_Tables_NewPartitionedTable'                   , 'PT.ReleaseApplicationLockSQL'                    , NULL                                                                                  , 1)

*/
--standard singleton operations
,('Delete'                              , 'Enable Resource Governor'                                      , NULL                                                        , NULL                                              , 'EXEC DOI.spRun_ReEnableResourceGovernor'                                             , 1)
,('Delete'                              , 'Get Application Lock'                                        , 'vwIndexes'                                                   , 'GetApplicationLockSQL'                           , NULL                                                                                  , 1)
,('Delete'                              , 'Delete'                                                      , 'vwIndexes'                                                   , 'DropStatement'                                   , NULL                                                                                  , 1)
,('Delete'                              , 'Release Application Lock'                                    , 'vwIndexes'                                                   , 'ReleaseApplicationLockSQL'                       , NULL                                                                                  , 1)

,('CreateMissing'                       , 'Enable Resource Governor'                                    , NULL                                                          , NULL                                              , 'EXEC DOI.spRun_ReEnableResourceGovernor'                                             , 1)
,('CreateMissing'                       , 'Get Application Lock'                                        , 'vwIndexes'                                                   , 'GetApplicationLockSQL'                           , NULL                                                                                  , 1)
,('CreateMissing'                       , 'Free Data Space Validation'                                  , 'vwIndexes'                                                   , 'FreeDataSpaceCheckSQL'                           , NULL                                                                                  , 1)
,('CreateMissing'                       , 'Free Log Space Validation'                                   , 'vwIndexes'                                                   , 'FreeLogSpaceCheckSQL'                            , NULL                                                                                  , 1)
,('CreateMissing'                       , 'Free TempDB Space Validation'                                , 'vwIndexes'                                                   , 'FreeTempDBSpaceCheckSQL'                         , NULL                                                                                  , 1)
,('CreateMissing'                       , 'Create Index'                                                , 'vwIndexes'                                                   , 'CreateStatement'                                 , NULL                                                                                  , 1)
,('CreateMissing'                       , 'Release Application Lock'                                    , 'vwIndexes'                                                   , 'ReleaseApplicationLockSQL'                       , NULL                                                                                  , 1)

,('CreateDropExisting'                  , 'Enable Resource Governor'                                    , NULL                                                          , NULL                                              , 'EXEC DOI.spRun_ReEnableResourceGovernor'                                             , 1)
,('CreateDropExisting'                  , 'Get Application Lock'                                        , 'vwIndexes'                                                   , 'GetApplicationLockSQL'                           , NULL                                                                                  , 1)
,('CreateDropExisting'                  , 'Free Data Space Validation'                                  , 'vwIndexes'                                                   , 'FreeDataSpaceCheckSQL'                           , NULL                                                                                  , 1)
,('CreateDropExisting'                  , 'Free Log Space Validation'                                   , 'vwIndexes'                                                   , 'FreeLogSpaceCheckSQL'                            , NULL                                                                                  , 1)
,('CreateDropExisting'                  , 'Free TempDB Space Validation'                                , 'vwIndexes'                                                   , 'FreeTempDBSpaceCheckSQL'                         , NULL                                                                                  , 1)
,('CreateDropExisting'                  , 'CreateDropExisting'                                          , 'vwIndexes'                                                   , 'CreateDropExistingStatement'                     , NULL                                                                                  , 1)
,('CreateDropExisting'                  , 'Release Application Lock'                                    , 'vwIndexes'                                                   , 'ReleaseApplicationLockSQL'                       , NULL                                                                                  , 1)

--do we need a drop-recreate offline?  if so, it needs a transaction.

,('AlterRebuild-Online'                 , 'Enable Resource Governor'                                    , NULL                                                          , NULL                                              , 'EXEC DOI.spRun_ReEnableResourceGovernor'                                             , 1)
,('AlterRebuild-Online'                 , 'Get Application Lock'                                        , 'vwIndexes'                                                   , 'GetApplicationLockSQL'                           , NULL                                                                                  , 1)
,('AlterRebuild-Online'                 , 'Free Data Space Validation'                                  , 'vwIndexes'                                                   , 'FreeDataSpaceCheckSQL'                           , NULL                                                                                  , 1)
,('AlterRebuild-Online'                 , 'Free Log Space Validation'                                   , 'vwIndexes'                                                   , 'FreeLogSpaceCheckSQL'                            , NULL                                                                                  , 1)
,('AlterRebuild-Online'                 , 'Free TempDB Space Validation'                                , 'vwIndexes'                                                   , 'FreeTempDBSpaceCheckSQL'                         , NULL                                                                                  , 1)
,('AlterRebuild-Online'                 , 'Alter Index'                                                 , 'vwIndexes'                                                   , 'AlterRebuildStatementOnline'                     , NULL                                                                                  , 1)
,('AlterRebuild-Online'                 , 'Release Application Lock'                                    , 'vwIndexes'                                                   , 'ReleaseApplicationLockSQL'                       , NULL                                                                                  , 1)

,('AlterRebuild-Offline'                , 'Disable Resource Governor'                                   , NULL                                                          , NULL                                              , 'EXEC DOI.spRun_DisableResourceGovernor'                                              , 1)
,('AlterRebuild-Offline'                , 'Get Application Lock'                                        , 'vwIndexes'                                                   , 'GetApplicationLockSQL'                           , NULL                                                                                  , 1)
,('AlterRebuild-Offline'                , 'Free Data Space Validation'                                  , 'vwIndexes'                                                   , 'FreeDataSpaceCheckSQL'                           , NULL                                                                                  , 1)
,('AlterRebuild-Offline'                , 'Free Log Space Validation'                                   , 'vwIndexes'                                                   , 'FreeLogSpaceCheckSQL'                            , NULL                                                                                  , 1)
,('AlterRebuild-Offline'                , 'Free TempDB Space Validation'                                , 'vwIndexes'                                                   , 'FreeTempDBSpaceCheckSQL'                         , NULL                                                                                  , 1)
,('AlterRebuild-Offline'                , 'Alter Index'                                                 , 'vwIndexes'                                                   , 'AlterRebuildStatementOffline'                  , NULL                                                                                  , 1)
,('AlterRebuild-Offline'                , 'Release Application Lock'                                    , 'vwIndexes'                                                   , 'ReleaseApplicationLockSQL'                       , NULL                                                                                  , 1)

,('AlterSet'                            , 'Enable Resource Governor'                                    , NULL                                                          , NULL                                              , 'EXEC DOI.spRun_ReEnableResourceGovernor'                                             , 1)
,('AlterSet'                            , 'Get Application Lock'                                        , 'vwIndexes'                                                   , 'GetApplicationLockSQL'                           , NULL                                                                                  , 1)
,('AlterSet'                            , 'Alter Index'                                                 , 'vwIndexes'                                                   , 'AlterSetStatement'                             , NULL                                                                                  , 1)
,('AlterSet'                            , 'Release Application Lock'                                    , 'vwIndexes'                                                   , 'ReleaseApplicationLockSQL'                       , NULL                                                                                  , 1)

,('AlterReorganize'                     , 'Enable Resource Governor'                                    , NULL                                                          , NULL                                              , 'EXEC DOI.spRun_ReEnableResourceGovernor'                                             , 1)
,('AlterReorganize'                     , 'Get Application Lock'                                        , 'vwIndexes'                                                   , 'GetApplicationLockSQL'                           , NULL                                                                                  , 1)
,('AlterReorganize'                     , 'Free Data Space Validation'                                  , 'vwIndexes'                                                   , 'FreeDataSpaceCheckSQL'                           , NULL                                                                                  , 1)
,('AlterReorganize'                     , 'Free Log Space Validation'                                   , 'vwIndexes'                                                   , 'FreeLogSpaceCheckSQL'                            , NULL                                                                                  , 1)
,('AlterReorganize'                     , 'Free TempDB Space Validation'                                , 'vwIndexes'                                                   , 'FreeTempDBSpaceCheckSQL'                         , NULL                                                                                  , 1)
,('AlterReorganize'                     , 'Alter Index'                                                 , 'vwIndexes'                                                   , 'AlterReorganizeStatement'                      , NULL                                                                                  , 1)
,('AlterReorganize'                     , 'Release Application Lock'                                    , 'vwIndexes'                                                   , 'ReleaseApplicationLockSQL'                       , NULL                                                                                  , 1)

,('AlterRebuild-PartitionLevel-Online'  , 'Enable Resource Governor'                                    , NULL                                                          , NULL                                              , 'EXEC DOI.spRun_ReEnableResourceGovernor'                                             , 1)
,('AlterRebuild-PartitionLevel-Online'  , 'Get Application Lock'                                        , 'vwIndexPartitions'                                           , 'GetApplicationLockSQL'                           , NULL                                                                                  , 1)
,('AlterRebuild-PartitionLevel-Online'  , 'Free Data Space Validation'                                  , 'vwIndexPartitions'                                           , 'FreeDataSpaceCheckSQL'                           , NULL                                                                                  , 1)
,('AlterRebuild-PartitionLevel-Online'  , 'Free Log Space Validation'                                   , 'vwIndexPartitions'                                           , 'FreeLogSpaceCheckSQL'                            , NULL                                                                                  , 1)
,('AlterRebuild-PartitionLevel-Online'  , 'Free TempDB Space Validation'                                , 'vwIndexPartitions'                                           , 'FreeTempDBSpaceCheckSQL'                         , NULL                                                                                  , 1)
,('AlterRebuild-PartitionLevel-Online'  , 'Alter Index'                                                 , 'vwIndexPartitions'                                           , 'AlterRebuildStatementOnline'                  , NULL                                                                                  , 1)
,('AlterRebuild-PartitionLevel-Online'  , 'Release Application Lock'                                    , 'vwIndexPartitions'                                           , 'ReleaseApplicationLockSQL'                       , NULL                                                                                  , 1)

,('AlterRebuild-PartitionLevel-Offline' , 'Disable Resource Governor'                                   , NULL                                                          , NULL                                              , 'EXEC DOI.spRun_DisableResourceGovernor'                                              , 1)
,('AlterRebuild-PartitionLevel-Offline' , 'Get Application Lock'                                        , 'vwIndexPartitions'                                           , 'GetApplicationLockSQL'                           , NULL                                                                                  , 1)
,('AlterRebuild-PartitionLevel-Offline' , 'Free Data Space Validation'                                  , 'vwIndexPartitions'                                           , 'FreeDataSpaceCheckSQL'                           , NULL                                                                                  , 1)
,('AlterRebuild-PartitionLevel-Offline' , 'Free Log Space Validation'                                   , 'vwIndexPartitions'                                           , 'FreeLogSpaceCheckSQL'                            , NULL                                                                                  , 1)
,('AlterRebuild-PartitionLevel-Offline' , 'Free TempDB Space Validation'                                , 'vwIndexPartitions'                                           , 'FreeTempDBSpaceCheckSQL'                         , NULL                                                                                  , 1)
,('AlterRebuild-PartitionLevel-Offline' , 'Alter Index'                                                 , 'vwIndexPartitions'                                           , 'AlterRebuildStatementOffline'                 , NULL                                                                                  , 1)
,('AlterRebuild-PartitionLevel-Offline' , 'Release Application Lock'                                    , 'vwIndexPartitions'                                           , 'ReleaseApplicationLockSQL'                       , NULL                                                                                  , 1)

,('AlterReorganize-PartitionLevel'      , 'Enable Resource Governor'                                    , NULL                                                          , NULL                                              , 'EXEC DOI.spRun_ReEnableResourceGovernor'                                             , 1)
,('AlterReorganize-PartitionLevel'      , 'Get Application Lock'                                        , 'vwIndexPartitions'                                           , 'GetApplicationLockSQL'                           , NULL                                                                                  , 1)
,('AlterReorganize-PartitionLevel'      , 'Free Data Space Validation'                                  , 'vwIndexPartitions'                                           , 'FreeDataSpaceCheckSQL'                           , NULL                                                                                  , 1)
,('AlterReorganize-PartitionLevel'      , 'Free Log Space Validation'                                   , 'vwIndexPartitions'                                           , 'FreeLogSpaceCheckSQL'                            , NULL                                                                                  , 1)
,('AlterReorganize-PartitionLevel'      , 'Free TempDB Space Validation'                                , 'vwIndexPartitions'                                           , 'FreeTempDBSpaceCheckSQL'                         , NULL                                                                                  , 1)
,('AlterReorganize-PartitionLevel'      , 'Alter Index'                                                 , 'vwIndexPartitions'                                           , 'AlterReorganizeStatement'                     , NULL                                                                                  , 1)
,('AlterReorganize-PartitionLevel'      , 'Release Application Lock'                                    , 'vwIndexPartitions'                                           , 'ReleaseApplicationLockSQL'                       , NULL                                                                                  , 1)

--Statistics operations
,('Create Statistics'                   , 'Enable Resource Governor'                                    , NULL                                                          , NULL                                              , 'EXEC DOI.spRun_ReEnableResourceGovernor'                                             , 1)
,('Create Statistics'                   , 'Get Application Lock'                                        , 'vwStatistics'                                                , 'GetApplicationLockSQL'                           , NULL                                                                                  , 1)
,('Create Statistics'                   , 'Free Data Space Validation'                                  , 'vwStatistics'                                                , 'FreeDataSpaceCheckSQL'                           , NULL                                                                                  , 1)
,('Create Statistics'                   , 'Free Log Space Validation'                                   , 'vwStatistics'                                                , 'FreeLogSpaceCheckSQL'                            , NULL                                                                                  , 1)
,('Create Statistics'                   , 'Free TempDB Space Validation'                                , 'vwStatistics'                                                , 'FreeTempDBSpaceCheckSQL'                         , NULL                                                                                  , 1)
,('Create Statistics'                   , 'Create Statistics'                                           , 'vwStatistics'                                                , 'CreateStatisticsSQL'                             , NULL                                                                                  , 1)
,('Create Statistics'                   , 'Release Application Lock'                                    , 'vwStatistics'                                                , 'ReleaseApplicationLockSQL'                       , NULL                                                                                  , 1)

,('DropRecreate Statistics'             , 'Enable Resource Governor'                                    , NULL                                                          , NULL                                              , 'EXEC DOI.spRun_ReEnableResourceGovernor'                                             , 1)
,('DropRecreate Statistics'             , 'Get Application Lock'                                        , 'vwStatistics'                                                , 'GetApplicationLockSQL'                           , NULL                                                                                  , 1)
,('DropRecreate Statistics'             , 'Free Data Space Validation'                                  , 'vwStatistics'                                                , 'FreeDataSpaceCheckSQL'                           , NULL                                                                                  , 1)
,('DropRecreate Statistics'             , 'Free Log Space Validation'                                   , 'vwStatistics'                                                , 'FreeLogSpaceCheckSQL'                            , NULL                                                                                  , 1)
,('DropRecreate Statistics'             , 'Free TempDB Space Validation'                                , 'vwStatistics'                                                , 'FreeTempDBSpaceCheckSQL'                         , NULL                                                                                  , 1)
,('DropRecreate Statistics'             , 'BeginTran'                                                   , NULL                                                          , NULL                                              , 'SET TRANSACTION ISOLATION LEVEL SERIALIZABLE' + CHAR(13) + CHAR(10) + 'BEGIN TRAN'   , 10)
,('DropRecreate Statistics'             , 'DropRecreate Statistics'                                     , 'vwStatistics'                                                , 'DropReCreateStatisticsSQL'                       , NULL                                                                                  , 1)
,('DropRecreate Statistics'             , 'CommitTran'                                                  , NULL                                                          , NULL                                              , 'COMMIT TRAN'                                                                         , 21)
,('DropRecreate Statistics'             , 'Release Application Lock'                                    , 'vwStatistics'                                                , 'ReleaseApplicationLockSQL'                       , NULL                                                                                  , 1)

,('Update Statistics'                   , 'Enable Resource Governor'                                    , NULL                                                          , NULL                                              , 'EXEC DOI.spRun_ReEnableResourceGovernor'                                             , 1)
,('Update Statistics'                   , 'Get Application Lock'                                        , 'vwStatistics'                                                , 'GetApplicationLockSQL'                           , NULL                                                                                  , 1)
,('Update Statistics'                   , 'Free Data Space Validation'                                  , 'vwStatistics'                                                , 'FreeDataSpaceCheckSQL'                           , NULL                                                                                  , 1)
,('Update Statistics'                   , 'Free Log Space Validation'                                   , 'vwStatistics'                                                , 'FreeLogSpaceCheckSQL'                            , NULL                                                                                  , 1)
,('Update Statistics'                   , 'Free TempDB Space Validation'                                , 'vwStatistics'                                                , 'FreeTempDBSpaceCheckSQL'                         , NULL                                                                                  , 1)
,('Update Statistics'                   , 'Update Statistics'                                           , 'vwStatistics'                                                , 'UpdateStatisticsSQL'                             , NULL                                                                                  , 1)
,('Update Statistics'                   , 'Release Application Lock'                                    , 'vwStatistics'                                                , 'ReleaseApplicationLockSQL'                       , NULL                                                                                  , 1)

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

