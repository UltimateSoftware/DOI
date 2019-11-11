IF OBJECT_ID('[DDI].[spRefreshMetadata_User_IndexesColumnStore_InsertData]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_IndexesColumnStore_InsertData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [DDI].[spRefreshMetadata_User_IndexesColumnStore_InsertData]

AS

DELETE DDI.IndexesColumnStore

    INSERT DDI.[IndexesColumnStore] (
		    DatabaseName        , [SchemaName]	, [TableName]				, [IndexName]									, [IsClustered_Desired]	, [IsFiltered_Desired]	, [FilterPredicate_Desired]	, [OptionDataCompression_Desired]	, [OptionDataCompressionDelay_Desired]	, Storage_Desired				, PartitionColumn_Desired	) 
    VALUES	
		    (N'PaymentReporting', N'dbo'		, N'JournalEntries'			, N'NCCI_JournalEntries_LedgerBalanceReport'	, 0				        , 0				        , NULL				        , N'COLUMNSTORE'			        , 0							            , 'psMonthly'				    , 'TransactionUtcDt'	    ),
            (N'PaymentReporting', N'dbo'		, N'Liabilities'			, N'NCCI_Liabilities_CheckDateCover'	        , 0				        , 0				        , NULL				        , N'COLUMNSTORE'			        , 0							            , 'psYearly'			        , 'PayDate'                 ),
            (N'PaymentReporting', N'dbo'		, N'TaxAgencyTransactions'	, N'NCCI_TaxAgencyTransactions_PaymentsCount'	, 0				        , 0				        , NULL				        , N'COLUMNSTORE'			        , 0							            , 'PRIMARY'					    , NULL					    ),
		    (N'PaymentReporting', N'dbo'		, N'TaxAmounts'				, N'NCCI_TaxAmounts_SumByPayroll'				, 0				        , 0				        , NULL				        , N'COLUMNSTORE'			        , 0							            , 'PRIMARY'					    , NULL					    ),
		    (N'PaymentReporting', N'dbo'		, N'TaxPayrolls'			, N'NCCI_TaxPayrolls_CheckDateCover'	        , 0				        , 0				        , NULL				        , N'COLUMNSTORE'			        , 0							            , 'PRIMARY'				        , NULL	                    )

GO
