
GO

DELETE DOI.MappingSqlServerDMVToDOITables 
GO

INSERT INTO DOI.MappingSqlServerDMVToDOITables 
        ( DOITableName              , SQLServerObjectName               , SQLServerObjectType   , HasDatabaseIdInOutput , DatabaseOutputString			, FunctionParameterList										, FunctionParentDMV	)
VALUES   ('SysFilegroups'           , 'sys.filegroups'                  , 'V'                   , 0                     , 'DB_ID(''{DatabaseName}'')'	, NULL														, NULL				)
        ,('SysDestinationDataSpaces', 'sys.destination_data_spaces'     , 'V'                   , 0                     , 'DB_ID(''{DatabaseName}'')'	, NULL														, NULL				)
        ,('SysSchemas'              , 'sys.schemas'                     , 'V'                   , 0                     , 'DB_ID(''{DatabaseName}'')'	, NULL														, NULL				)
        ,('SysTables'               , 'sys.tables'                      , 'V'                   , 0                     , 'DB_ID(''{DatabaseName}'')'	, NULL														, NULL				)
        ,('SysIndexes'              , 'sys.indexes'                     , 'V'                   , 0                     , 'DB_ID(''{DatabaseName}'')'	, NULL														, NULL				)
        ,('SysIndexPhysicalStats'   , 'sys.dm_db_index_physical_stats'  , 'FN'                  , 1                     , NULL							, 'DB_ID(''{DatabaseName}''), NULL, NULL, NULL, ''SAMPLED''', NULL				)
        ,('SysPartitions'           , 'sys.partitions'                  , 'V'                   , 0                     , 'DB_ID(''{DatabaseName}'')'	, NULL														, NULL				)
        ,('SysAllocationUnits'      , 'sys.allocation_units'            , 'V'                   , 0                     , 'DB_ID(''{DatabaseName}'')'	, NULL														, NULL				)
        ,('SysDatabaseFiles'        , 'sys.database_files'              , 'V'                   , 0                     , 'DB_ID(''{DatabaseName}'')'	, NULL														, NULL				)
        ,('SysDmOsVolumeStats'      , 'sys.dm_os_volume_stats'          , 'FN'                  , 1                     , 'DB_ID(''{DatabaseName}'')'	, 'DB_ID(''{DatabaseName}''), file_id'						, 'SysDatabaseFiles')
        ,('SysDatabases'            , 'sys.databases'                   , 'V'                   , 1                     , NULL							, NULL														, NULL				)
        ,('SysColumns'              , 'sys.columns'                     , 'V'                   , 0                     , 'DB_ID(''{DatabaseName}'')'	, NULL														, NULL				)
        ,('SysTypes'                , 'sys.types'                       , 'V'                   , 0                     , 'DB_ID(''{DatabaseName}'')'	, NULL														, NULL				)
        ,('SysPartitionFunctions'   , 'sys.partition_functions'         , 'V'                   , 0                     , 'DB_ID(''{DatabaseName}'')'	, NULL														, NULL				)
        ,('SysPartitionRangeValues' , 'sys.partition_range_values'      , 'V'                   , 0                     , 'DB_ID(''{DatabaseName}'')'	, NULL														, NULL				)
        ,('SysPartitionSchemes'     , 'sys.partition_schemes'           , 'V'                   , 0                     , 'DB_ID(''{DatabaseName}'')'	, NULL														, NULL				)
        ,('SysIndexColumns'         , 'sys.index_columns'               , 'V'                   , 0                     , 'DB_ID(''{DatabaseName}'')'	, NULL														, NULL				)
        ,('SysDataSpaces'           , 'sys.data_spaces'                 , 'V'                   , 0                     , 'DB_ID(''{DatabaseName}'')'	, NULL														, NULL				)
        ,('SysStats'                , 'sys.stats'                       , 'V'                   , 0                     , 'DB_ID(''{DatabaseName}'')'	, NULL														, NULL				)
        ,('SysDmDbStatsProperties'  , 'sys.dm_db_stats_properties'      , 'FN'                  , 0                     , 'DB_ID(''{DatabaseName}'')'	, 'p.object_id, p.stats_id'									, 'SysStats'		)
        ,('SysStatsColumns'         , 'sys.stats_columns'               , 'V'                   , 0                     , 'DB_ID(''{DatabaseName}'')'	, NULL														, NULL				)
        ,('SysForeignKeys'			, 'sys.foreign_keys'                , 'V'                   , 0                     , 'DB_ID(''{DatabaseName}'')'	, NULL														, NULL				)
        ,('SysForeignKeyColumns'	, 'sys.foreign_key_columns'         , 'V'                   , 0                     , 'DB_ID(''{DatabaseName}'')'	, NULL														, NULL				)
        ,('SysCheckConstraints'		, 'sys.check_constraints'			, 'V'                   , 0                     , 'DB_ID(''{DatabaseName}'')'	, NULL														, NULL				)
        ,('SysDefaultConstraints'	, 'sys.default_constraints'         , 'V'                   , 0                     , 'DB_ID(''{DatabaseName}'')'	, NULL														, NULL				)
        ,('SysTriggers'				, 'sys.triggers'					, 'V'                   , 0                     , 'DB_ID(''{DatabaseName}'')'	, NULL														, NULL				)
        ,('SysMasterFiles'			, 'sys.master_files'				, 'V'                   , 1                     , NULL							, NULL														, NULL				)
GO