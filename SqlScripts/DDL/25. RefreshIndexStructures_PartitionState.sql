USE DDI
GO

DROP TABLE IF EXISTS DDI.RefreshIndexStructures_PartitionState
GO

	CREATE TABLE DDI.RefreshIndexStructures_PartitionState (
        DatabaseName SYSNAME,
		SchemaName SYSNAME ,
		ParentTableName SYSNAME ,
		PrepTableName SYSNAME ,
		PartitionFromValue DATE NOT NULL,
		PartitionToValue DATE NOT NULL,
		DataSynchState BIT NOT NULL,
		LastUpdateDateTime DATETIME 
			CONSTRAINT Def_RefreshIndexStructures_PartitionState_LastUpdateDateTime
				DEFAULT (GETDATE())

		CONSTRAINT PK_RefreshIndexStructures_PartitionState 
			PRIMARY KEY NONCLUSTERED(DatabaseName, SchemaName, ParentTableName, PrepTableName, PartitionFromValue))
        WITH (MEMORY_OPTIMIZED = ON)
GO
