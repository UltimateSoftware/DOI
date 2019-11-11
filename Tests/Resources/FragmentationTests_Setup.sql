--NIDX_TempA_Report

DELETE Utility.IndexesRowStore WHERE IndexName = 'NIDX_TempA_Report'

INSERT INTO Utility.IndexesRowStore 
		(	SchemaName	,TableName	,IndexName				,IsUnique	,IsPrimaryKey	, IsUniqueConstraint, IsClustered	,KeyColumnList							,IncludedColumnList	,IsFiltered ,FilterPredicate	,[Fillfactor]	,OptionPadIndex ,OptionStatisticsNoRecompute	,OptionStatisticsIncremental	,OptionIgnoreDupKey ,OptionResumable	,OptionMaxDuration	,OptionAllowRowLocks	,OptionAllowPageLocks	,OptionDataCompression	, NewStorage	, PartitionColumn	)
VALUES	(	N'dbo'		, N'TempA'	, N'NIDX_TempA_Report'	, 0			, 0				, 0					, 0				, N'TransactionUtcDt ASC'				,N'TextCol'			, 0			, NULL				, 80			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, 'NONE'				, 'PRIMARY'		, NULL				)