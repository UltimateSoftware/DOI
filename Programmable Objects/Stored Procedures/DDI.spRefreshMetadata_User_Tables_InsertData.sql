IF OBJECT_ID('[DDI].[spRefreshMetadata_User_Tables_InsertData]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_Tables_InsertData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_User_Tables_InsertData]

AS

BEGIN TRY 
    EXEC DDI.spRefreshMetadata_User_Tables_DropRefFKs

    DELETE DDI.Tables

    --SELECT '(''' + SchemaName + ''', ''' + TableName + ''', ' + CASE WHEN X.PartitionColumn IS NULL THEN 'NULL' ELSE '''' + X.PartitionColumn + '''' END + ', ''' + NewTableStorage + ''', ' + CAST(0 AS VARCHAR(1)) + ', '+ CAST(0 AS VARCHAR(1)) + ')' + CHAR(13) + CHAR(10)
    --FROM (SELECT DISTINCT SchemaName, TableName, PartitionColumn, NewTableStorage FROM Utility.IndexesRowStore)X
    --The following tables are not in our metadata: dbo.NettedCollectionConfirmationInfos,dbo.NettedCollections,dbo.NettedCollectionsLiabilityCollections,DataMart.NettedCollectionStatusDim,
    INSERT INTO DDI.Tables 
	    (DatabaseName       , SchemaName    ,TableName									,PartitionColumn			,Storage_Desired					, IntendToPartition	,  ReadyToQueue)
    VALUES 
	    ('PaymentReporting' , 'DataMart'	, 'AgencyLocalityTypeDim'					, NULL						, 'PRIMARY'							, 0					,  1)
    ,	('PaymentReporting' , 'DataMart'	, 'Bai2BankTransactionTypeDim'				, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'BankAccountPurposeDim'					, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'BankAccountStatusDim'					, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'BankAccountTypeDim'						, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'BankTransactionTypeDim'					, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'CheckAddModeDim'							, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'CheckStatusDim'							, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'Company_TaxStatusDim'					, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'CompanyTaxAgencyStatusDim'				, NULL						, 'PRIMARY'							, 0					,  1)
    ,	('PaymentReporting' , 'DataMart'	, 'CompanyStatusDim'						, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'CompanyTypeDim'							, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'CreditEffectOnLiabilityDim'				, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'FileRequestProcessingStatusDim'			, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'GarnishmentActionTypeDim'				, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'GarnishmentActionReasonDim'				, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'GarnishmentExceptionDim'					, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'GarnishmentIsInArrearsDim'				, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'GarnishmentLiabilityStatusDim'			, NULL						, 'PRIMARY'							, 0					,  1)
    ,	('PaymentReporting' , 'DataMart'	, 'GarnishmentLiabilityTypeDim'				, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'GarnishmentMedIndicatorDim'				, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'GarnishmentPayableStatusDim'				, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'GarnishmentPaymentTypeDim'				, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'GarnishmentPayrollInstanceReconStatusDim', NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'GarnishmentsSupportsOthersDim'			, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'GarnishmentStatusDim'					, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'GarnishmentTypeDim'						, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'GLAccountClassificationDim'				, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'GLAccountStatusDim'						, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'GLAccountTypeDim'						, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'InboundFileTypeDim'						, NULL						, 'PRIMARY'							, 0					,  1)
    ,	('PaymentReporting' , 'DataMart'	, 'JournalEntryTransactionTypeDim'			, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'LiabilityCollectionPaymentMethodDim'		, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'LiabilityCollectionStatusDim'			, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'LiabilityCollectionTypeDim'				, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'LiabilityStatusDim'						, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'LiabilityTypeDim'						, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'    , 'NettedCollectionStatusDim'				, NULL						, 'PRIMARY'							, 0					,  1)
    ,	('PaymentReporting' , 'DataMart'	, 'PayExceptionTypeDim'						, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'PayPortionStateDim'						, NULL						, 'PRIMARY'							, 0					,  1)
    ,	('PaymentReporting' , 'DataMart'	, 'PayProcessingStatusDim'					, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'PayrollPaymentStatusDim'					, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'PayrollPaymentTypeDim'					, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'PayrollTypeDim'							, NULL						, 'PRIMARY'							, 0					,  1)
    ,	('PaymentReporting' , 'DataMart'	, 'ProductActivationStatus'					, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'ProductCodeDim'							, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'ProductStatus'							, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'QEADJFilterOptions'						, NULL						, 'PRIMARY'							, 0					,  1)
    ,	('PaymentReporting' , 'DataMart'	, 'RefundPortionDim'						, NULL						, 'PRIMARY'							, 0					,  1)
    ,	('PaymentReporting' , 'DataMart'	, 'ReportRequestorTypeDim'					, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'ReportRequestStatusDim'					, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'TaxAgencyTransactionStatusDim'			, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'TaxCodeActiveStatus'						, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'TaxCodeProcessingFrequencyDim'			, NULL						, 'PRIMARY'							, 0					,  1)
    ,	('PaymentReporting' , 'DataMart'	, 'TaxLiabilityOriginTypeDim'				, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'TaxPaymentCreditStatusDim'				, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'TaxPaymentStatusDim'						, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'TaxPaymentTypeDim'						, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'TenantStatusDim'							, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'UTETaxDataSourceTableSetDim'				, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'DataMart'	, 'YEProcessingStatusDim'					, NULL						, 'PRIMARY'							, 0					,  1)
    ,	('PaymentReporting' , 'DataMart'	, 'YEFileStatusDim'							, NULL						, 'PRIMARY'							, 0					,  1)
    ,	('PaymentReporting' , 'DataMart'	, 'YEIngestionTypeDim'						, NULL						, 'PRIMARY'							, 0					,  1)
    --	 DatabaseName       , SchemaName	,TableName									,PartitionColumn			,NewStorage							, IntendToPartition	,  ReadyToQueue
    ,	('PaymentReporting' , 'dbo'		    , 'Bai2BankTransactions'					, 'TransactionSysUtcDt'		, 'psYearlyNoSlidingWindow'			, 1					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'BankAccountDays'							, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'BankTransactions'						, 'TransactionUtcDateTime'	, 'psYearlyNoSlidingWindow'			, 1					,  1)  
    --,	('PaymentReporting' , 'dbo'		    , 'changelog'								, NULL						, 'PRIMARY'							, 0					,  1)
    ,	('PaymentReporting' , 'dbo'		    , 'Companies'								, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'Company_Tax'								, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'CompanyTaxAgency'						, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'CompanyTaxAgency_Audit'					, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'CompanyProduct'							, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'CustomerBankAccounts'					, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'DBDefragLog'								, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'EFilingAcknowledgmentAlerts'				, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'EFilingAcknowledgments'					, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'FileRequestPayments'						, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'FileRequests'							, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'GarnishmentLiabilities'					, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'GarnishmentPayrollInstances'				, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'GeneralLedgerAccounts'					, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'JournalEntries'							, 'TransactionUtcDt'		, 'psMonthly'						, 1					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'Liabilities'								, 'PayDate'					, 'psYearlyNoSlidingWindow'			, 1					,  0)  
    ,	('PaymentReporting' , 'dbo'		    , 'LiabilityCollectionComments'				, NULL      				, 'PRIMARY' 						, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'LiabilityCollectionConfirmationInfos'	, NULL      				, 'PRIMARY' 						, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'LiabilityCollections'					, 'PayUtcDt'				, 'psYearlyNoSlidingWindow'			, 1					,  0)  
    ,	('PaymentReporting' , 'dbo'		    , 'LiabilityPayments'						, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'NettedCollections'						, NULL						, 'PRIMARY'							, 0					,  1)
    ,	('PaymentReporting' , 'dbo'		    , 'NettedCollectionsLiabilityCollections'   , NULL						, 'PRIMARY'							, 0					,  1)
    ,	('PaymentReporting' , 'dbo'		    , 'PayActions'								, NULL						, 'PRIMARY'							, 0					,  1)
    ,	('PaymentReporting' , 'dbo'		    , 'PayGarnishment_Deductions'				, 'PayUtcDate'				, 'psYearlyNoSlidingWindow'			, 1					,  0)  
    ,	('PaymentReporting' , 'dbo'		    , 'PayGarnishment_Employees'				, 'PayUtcDate'				, 'psYearlyNoSlidingWindow'			, 1					,  0)  
    ,	('PaymentReporting' , 'dbo'		    , 'PayGarnishment_Payees'					, 'PayUtcDate'				, 'psYearlyNoSlidingWindow'			, 1					,  0)  
    ,	('PaymentReporting' , 'dbo'		    , 'PayGarnishmentActions'					, 'PayUtcDate'				, 'psYearlyNoSlidingWindow'			, 1					,  0)  
    ,	('PaymentReporting' , 'dbo'		    , 'PayGarnishmentExceptions'				, 'PayUtcDate'				, 'psYearlyNoSlidingWindow'			, 1					,  0)  
    ,	('PaymentReporting' , 'dbo'		    , 'PayGarnishmentLiabilities'				, 'PayUtcDate'				, 'psYearlyNoSlidingWindow'			, 1					,  0)  
    ,	('PaymentReporting' , 'dbo'		    , 'PayGarnishments'							, 'PayUtcDate'				, 'psYearlyNoSlidingWindow'			, 1					,  0)  
    ,	('PaymentReporting' , 'dbo'		    , 'PayLiabilities'							, 'PayUtcDate'				, 'psMonthly'						, 1					,  1)
    ,	('PaymentReporting' , 'dbo'		    , 'PayrollInstances'						, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'PayrollPayments'							, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'PayrollUnits'							, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'Pays'									, 'PayUtcDate'				, 'psMonthly'						, 1					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'PayTaxes'								, 'PayUtcDate'				, 'psMonthly'						, 1					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'ReportFileInformation'					, NULL						, 'PRIMARY'							, 0					,  1)
    ,	('PaymentReporting' , 'dbo'		    , 'ReportObjectStoreInfo'					, NULL						, 'PRIMARY'							, 0					,  1)
    ,	('PaymentReporting' , 'dbo'		    , 'ReportParameters'						, NULL						, 'PRIMARY'							, 0					,  1)
    ,	('PaymentReporting' , 'dbo'		    , 'ReportRequests'							, NULL						, 'PRIMARY'							, 0					,  1)
    ,	('PaymentReporting' , 'dbo'		    , 'ReportStatistics'						, NULL						, 'PRIMARY'							, 0					,  1)
    ,	('PaymentReporting' , 'dbo'		    , 'States'									, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'SystemSettings'							, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'TaxAgency'								, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'TaxAgency_Audit'						    , NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'TaxAgencyTransactions'					, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'TaxAgencyTransactionAmounts'				, NULL						, 'PRIMARY'							, 0					,  1)
    ,	('PaymentReporting' , 'dbo'		    , 'TaxAmounts'								, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'TaxAmountsUltiTaxCodes'					, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'TaxCodes'								, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'TaxLiabilities'							, 'PayUtcDate'				, 'psYearlyNoSlidingWindow'	        , 1					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'TaxPaymentCredits'						, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'TaxPayrolls'							    , NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'TaxSchedules'							, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'TenantProduct'							, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'Tenants'								    , NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'TenantStatus'							, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'UltiProTaxCodeMapping'					, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'UsgBankAccounts'							, NULL						, 'PRIMARY'							, 0					,  1)  
    ,	('PaymentReporting' , 'dbo'		    , 'YEProcessing'							, NULL						, 'PRIMARY'							, 0					,  1)
    ,	('PaymentReporting' , 'dbo'		    , 'YEProcessingFiles'						, NULL						, 'PRIMARY'							, 0					,  1)
    --	 DatabaseName       , SchemaName	,TableName									,PartitionColumn			,NewStorage							, IntendToPartition	,  ReadyToQueue

    EXEC [DDI].[spRefreshMetadata_User_Tables_AddRefFKs]

END TRY
BEGIN CATCH
    EXEC [DDI].[spRefreshMetadata_User_Tables_AddRefFKs];

    THROW;
END CATCH

GO
