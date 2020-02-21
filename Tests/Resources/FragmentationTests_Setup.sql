USE DDI

--NIDX_TempA_Report

DELETE DDI.IndexesRowStore WHERE IndexName = 'NIDX_TempA_Report'

INSERT INTO DDI.IndexesRowStore 
		(	DatabaseName		, SchemaName	,TableName	,IndexName				,IsUnique_Desired	,IsPrimaryKey_Desired	, IsUniqueConstraint_Desired, IsClustered_Desired	,KeyColumnList_Desired							,IncludedColumnList_Desired	,IsFiltered_Desired ,FilterPredicate_Desired	,[Fillfactor_Desired]	,OptionPadIndex_Desired ,OptionStatisticsNoRecompute_Desired	,OptionStatisticsIncremental_Desired	,OptionIgnoreDupKey_Desired ,OptionResumable_Desired	,OptionMaxDuration_Desired	,OptionAllowRowLocks_Desired	,OptionAllowPageLocks_Desired	,OptionDataCompression_Desired	, Storage_Desired	, PartitionColumn_Desired	)
VALUES	(	'PaymentReporting'	, N'dbo'		, N'TempA'	, N'NIDX_TempA_Report'	, 0					, 0						, 0					, 0				, N'TransactionUtcDt ASC'				,N'TextCol'			, 0			, NULL				, 80			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, 'NONE'				, 'PRIMARY'		, NULL				)