-- <Migration ID="67d29018-b4a4-5d34-ae44-104246c90891" TransactionHandling="Custom"/>

GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_User_IndexesColumnStore_InsertData]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_IndexesColumnStore_InsertData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [DOI].[spRefreshMetadata_User_IndexesColumnStore_InsertData]

WITH NATIVE_COMPILATION, SCHEMABINDING
AS

BEGIN ATOMIC WITH (LANGUAGE = 'English', TRANSACTION ISOLATION LEVEL = SNAPSHOT)
    DELETE DOI.IndexesColumnStore
                                                                                                                                                                                                                                                                                                                                                                                                          --(DatabaseName        ,[SchemaName]	, [TableName]				, [IndexName]									, [IsClustered_Desired]	, [ColumnList_Desired]                                                                                                                                                                                  , [IsFiltered_Desired]	, [FilterPredicate_Desired]	, [OptionDataCompression_Desired]	, [OptionDataCompressionDelay_Desired]	, Storage_Desired				, PartitionColumn_Desired	)           
    INSERT DOI.[IndexesColumnStore] (DatabaseName        , [SchemaName]	, [TableName]				, [IndexName]									, [IsClustered_Desired]	, [ColumnList_Desired] , [IsFiltered_Desired]	, [FilterPredicate_Desired]	, [OptionDataCompression_Desired]	, [OptionDataCompressionDelay_Desired]	, Storage_Desired				, PartitionColumn_Desired	) VALUES	(N'PaymentReporting', N'dbo'		, N'JournalEntries'			, N'NCCI_JournalEntries_LedgerBalanceReport'	, 0				        , 'JournalEntryId,LiabilityId,TransactionType,Amount,TenantId,AccountId,AccountNumber,TransactionUtcDt,GLSegment,TenantAlias,CompanyId,CompanyCode,PayrollId,PayGroup,ProductCode,StateCode,AgencyCode' , 0				        , NULL				        , N'COLUMNSTORE'			        , 0							            , 'psMonthly'				    , 'TransactionUtcDt'	    )
    INSERT DOI.[IndexesColumnStore] (DatabaseName        , [SchemaName]	, [TableName]				, [IndexName]									, [IsClustered_Desired]	, [ColumnList_Desired] , [IsFiltered_Desired]	, [FilterPredicate_Desired]	, [OptionDataCompression_Desired]	, [OptionDataCompressionDelay_Desired]	, Storage_Desired				, PartitionColumn_Desired	) VALUES	(N'PaymentReporting', N'dbo'		, N'Liabilities'			, N'NCCI_Liabilities_CheckDateCover'	        , 0				        , 'CollectionId,PayDate'                                                                                                                                                                                , 0				        , NULL				        , N'COLUMNSTORE'			        , 0							            , 'psYearly'			        , 'PayDate'                 )
    INSERT DOI.[IndexesColumnStore] (DatabaseName        , [SchemaName]	, [TableName]				, [IndexName]									, [IsClustered_Desired]	, [ColumnList_Desired] , [IsFiltered_Desired]	, [FilterPredicate_Desired]	, [OptionDataCompression_Desired]	, [OptionDataCompressionDelay_Desired]	, Storage_Desired				, PartitionColumn_Desired	) VALUES	(N'PaymentReporting', N'dbo'		, N'TaxAgencyTransactions'	, N'NCCI_TaxAgencyTransactions_PaymentsCount'	, 0				        , 'TaxAgencyId,PostPayrollGUID'                                                                                                                                                                         , 0				        , NULL				        , N'COLUMNSTORE'			        , 0							            , 'PRIMARY'					    , NULL					    )
    INSERT DOI.[IndexesColumnStore] (DatabaseName        , [SchemaName]	, [TableName]				, [IndexName]									, [IsClustered_Desired]	, [ColumnList_Desired] , [IsFiltered_Desired]	, [FilterPredicate_Desired]	, [OptionDataCompression_Desired]	, [OptionDataCompressionDelay_Desired]	, Storage_Desired				, PartitionColumn_Desired	) VALUES	(N'PaymentReporting', N'dbo'		, N'TaxAmounts'				, N'NCCI_TaxAmounts_SumByPayroll'				, 0				        , 'TenantId,TaxPayrollGUID,UTETaxDataSourceTableSetKey,CurrentAmount'                                                                                                                                   , 0				        , NULL				        , N'COLUMNSTORE'			        , 0							            , 'PRIMARY'					    , NULL					    )
    INSERT DOI.[IndexesColumnStore] (DatabaseName        , [SchemaName]	, [TableName]				, [IndexName]									, [IsClustered_Desired]	, [ColumnList_Desired] , [IsFiltered_Desired]	, [FilterPredicate_Desired]	, [OptionDataCompression_Desired]	, [OptionDataCompressionDelay_Desired]	, Storage_Desired				, PartitionColumn_Desired	) VALUES	(N'PaymentReporting', N'dbo'		, N'TaxPayrolls'			, N'NCCI_TaxPayrolls_CheckDateCover'	        , 0				        , 'LiabilityId,PayUtcDate'                                                                                                                                                                              , 0				        , NULL				        , N'COLUMNSTORE'			        , 0							            , 'PRIMARY'				        , NULL	                    )
END
GO
