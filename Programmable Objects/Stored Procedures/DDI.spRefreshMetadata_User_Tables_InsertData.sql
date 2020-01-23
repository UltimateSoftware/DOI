-- <Migration ID="bab1d4e0-df52-5dc1-825a-0c43c107ac28" TransactionHandling="Custom"/>
IF OBJECT_ID('[DDI].[spRefreshMetadata_User_Tables_InsertData]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_Tables_InsertData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE     PROCEDURE [DDI].[spRefreshMetadata_User_Tables_InsertData]

WITH NATIVE_COMPILATION, SCHEMABINDING
AS

/*
    EXEC DDI.spRefreshMetadata_User_Tables_InsertData
*/

BEGIN ATOMIC WITH (LANGUAGE = 'English', TRANSACTION ISOLATION LEVEL = SNAPSHOT)
    DELETE DDI.Tables

    --SELECT '(''' + SchemaName + ''', ''' + TableName + ''', ' + CASE WHEN X.PartitionColumn IS NULL THEN 'NULL' ELSE '''' + X.PartitionColumn + '''' END + ', ''' + NewTableStorage + ''', ' + CAST(0 AS VARCHAR(1)) + ', '+ CAST(0 AS VARCHAR(1)) + ')' + CHAR(13) + CHAR(10)
    --FROM (SELECT DISTINCT SchemaName, TableName, PartitionColumn, NewTableStorage FROM DDI.IndexesRowStore)X
    --The following tables are not in our metadata: dbo.NettedCollectionConfirmationInfos,dbo.NettedCollections,dbo.NettedCollectionsLiabilityCollections,DataMart.NettedCollectionStatusDim,
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName									,PartitionColumn			,Storage_Desired					, IntendToPartition	,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'AgencyLocalityTypeDim'					, NULL						, 'PRIMARY'							, 0					,  1)
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'Bai2BankTransactionTypeDim'				, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'BankAccountPurposeDim'					, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'BankAccountStatusDim'					, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'BankAccountTypeDim'						, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'BankTransactionTypeDim'					, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'CheckAddModeDim'							, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'CheckStatusDim'							, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'Company_TaxStatusDim'					, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'CompanyTaxAgencyStatusDim'				, NULL						, 'PRIMARY'							, 0					,  1)
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'CompanyStatusDim'						, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'CompanyTypeDim'							, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'CreditEffectOnLiabilityDim'				, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'FileRequestProcessingStatusDim'			, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'GarnishmentActionTypeDim'				, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'GarnishmentActionReasonDim'				, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'GarnishmentExceptionDim'					, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'GarnishmentIsInArrearsDim'				, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'GarnishmentLiabilityStatusDim'			, NULL						, 'PRIMARY'							, 0					,  1)
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'GarnishmentLiabilityTypeDim'				, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'GarnishmentMedIndicatorDim'				, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'GarnishmentPayableStatusDim'				, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'GarnishmentPaymentTypeDim'				, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'GarnishmentPayrollInstanceReconStatusDim', NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'GarnishmentsSupportsOthersDim'			, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'GarnishmentStatusDim'					, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'GarnishmentTypeDim'						, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'GLAccountClassificationDim'				, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'GLAccountStatusDim'						, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'GLAccountTypeDim'						, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'InboundFileTypeDim'						, NULL						, 'PRIMARY'							, 0					,  1)
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'JournalEntryTransactionTypeDim'			, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'LiabilityCollectionPaymentMethodDim'		, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'LiabilityCollectionStatusDim'			, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'LiabilityCollectionTypeDim'				, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'LiabilityStatusDim'						, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'LiabilityTypeDim'						, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'    , 'NettedCollectionStatusDim'				, NULL						, 'PRIMARY'							, 0					,  1)
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'PayExceptionTypeDim'						, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'PayPortionStateDim'						, NULL						, 'PRIMARY'							, 0					,  1)
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'PayProcessingStatusDim'					, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'PayrollPaymentStatusDim'					, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'PayrollPaymentTypeDim'					, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'PayrollTypeDim'							, NULL						, 'PRIMARY'							, 0					,  1)
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'ProductActivationStatus'					, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'ProductCodeDim'							, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'ProductStatus'							, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'QEADJFilterOptions'						, NULL						, 'PRIMARY'							, 0					,  1)
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'RefundPortionDim'						, NULL						, 'PRIMARY'							, 0					,  1)
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'ReportRequestorTypeDim'					, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'ReportRequestStatusDim'					, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'TaxAgencyTransactionStatusDim'			, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'TaxCodeActiveStatus'						, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'TaxCodeProcessingFrequencyDim'			, NULL						, 'PRIMARY'							, 0					,  1)
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'TaxLiabilityOriginTypeDim'				, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'TaxPaymentCreditStatusDim'				, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'TaxPaymentStatusDim'						, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'TaxPaymentTypeDim'						, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'TenantStatusDim'							, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'UTETaxDataSourceTableSetDim'				, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'YEProcessingStatusDim'					, NULL						, 'PRIMARY'							, 0					,  1)
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'YEFileStatusDim'							, NULL						, 'PRIMARY'							, 0					,  1)
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'DataMart'	, 'YEIngestionTypeDim'						, NULL						, 'PRIMARY'							, 0					,  1)
    --	 DatabaseName       , SchemaName	,TableName									,PartitionColumn			,NewStorage							, IntendToPartition	,  ReadyToQueue
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'Bai2BankTransactions'					, 'TransactionSysUtcDt'		, 'psMonthly'			, 1					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'BankAccountDays'							, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'BankTransactions'						, 'TransactionUtcDateTime'	, 'psYearlyNoSlidingWindow'			, 1					,  1)  
    --,	('PaymentReporting' , 'dbo'		    , 'changelog'								, NULL						, 'PRIMARY'							, 0					,  1)
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'Companies'								, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'Company_Tax'								, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'CompanyTaxAgency'						, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'CompanyTaxAgency_Audit'					, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'CompanyProduct'							, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'CustomerBankAccounts'					, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'DBDefragLog'								, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'EFilingAcknowledgmentAlerts'				, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'EFilingAcknowledgments'					, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'FileRequestPayments'						, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'FileRequests'							, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'GarnishmentLiabilities'					, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'GarnishmentPayrollInstances'				, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'GeneralLedgerAccounts'					, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'JournalEntries'							, 'TransactionUtcDt'		, 'psMonthly'						, 1					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'Liabilities'								, 'PayDate'					, 'psYearlyNoSlidingWindow'			, 1					,  0)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'LiabilityCollectionComments'				, NULL      				, 'PRIMARY' 						, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'LiabilityCollectionConfirmationInfos'	, NULL      				, 'PRIMARY' 						, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'LiabilityCollections'					, 'PayUtcDt'				, 'psYearlyNoSlidingWindow'			, 1					,  0)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'LiabilityPayments'						, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'NettedCollections'						, NULL						, 'PRIMARY'							, 0					,  1)
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'NettedCollectionsLiabilityCollections'   , NULL						, 'PRIMARY'							, 0					,  1)
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'PayActions'								, NULL						, 'PRIMARY'							, 0					,  1)
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'PayGarnishment_Deductions'				, 'PayUtcDate'				, 'psYearlyNoSlidingWindow'			, 1					,  0)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'PayGarnishment_Employees'				, 'PayUtcDate'				, 'psYearlyNoSlidingWindow'			, 1					,  0)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'PayGarnishment_Payees'					, 'PayUtcDate'				, 'psYearlyNoSlidingWindow'			, 1					,  0)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'PayGarnishmentActions'					, 'PayUtcDate'				, 'psYearlyNoSlidingWindow'			, 1					,  0)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'PayGarnishmentExceptions'				, 'PayUtcDate'				, 'psYearlyNoSlidingWindow'			, 1					,  0)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'PayGarnishmentLiabilities'				, 'PayUtcDate'				, 'psYearlyNoSlidingWindow'			, 1					,  0)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'PayGarnishments'							, 'PayUtcDate'				, 'psYearlyNoSlidingWindow'			, 1					,  0)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'PayLiabilities'							, 'PayUtcDate'				, 'psMonthly'						, 1					,  1)
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'PayrollInstances'						, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'PayrollPayments'							, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'PayrollUnits'							, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'Pays'									, 'PayUtcDate'				, 'psMonthly'						, 1					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'PayTaxes'								, 'PayUtcDate'				, 'psMonthly'						, 1					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'ReportFileInformation'					, NULL						, 'PRIMARY'							, 0					,  1)
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'ReportObjectStoreInfo'					, NULL						, 'PRIMARY'							, 0					,  1)
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'ReportParameters'						, NULL						, 'PRIMARY'							, 0					,  1)
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'ReportRequests'							, NULL						, 'PRIMARY'							, 0					,  1)
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'ReportStatistics'						, NULL						, 'PRIMARY'							, 0					,  1)
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'States'									, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'SystemSettings'							, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'TaxAgency'								, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'TaxAgency_Audit'						    , NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'TaxAgencyTransactions'					, 'CheckDate'				, 'psYearlyNoSlidingWindow'			, 1					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'TaxAgencyTransactionAmounts'				, NULL						, 'PRIMARY'							, 0					,  1)
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'TaxAmounts'								, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'TaxAmountsUltiTaxCodes'					, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'TaxCodes'								, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'TaxLiabilities'							, 'PayUtcDate'				, 'psYearlyNoSlidingWindow'	        , 1					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'TaxPaymentCredits'						, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'TaxPayrolls'							    , NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'TaxSchedules'							, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'TenantProduct'							, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'Tenants'								    , NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'TenantStatus'							, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'UltiProTaxCodeMapping'					, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'UsgBankAccounts'							, NULL						, 'PRIMARY'							, 0					,  1)  
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'YEProcessing'							, NULL						, 'PRIMARY'							, 0					,  1)
    INSERT INTO DDI.Tables (DatabaseName       , SchemaName    ,TableName         ,PartitionColumn   ,Storage_Desired     , IntendToPartition ,  ReadyToQueue) VALUES ('PaymentReporting' , 'dbo'		    , 'YEProcessingFiles'						, NULL						, 'PRIMARY'							, 0					,  1)
    --	 DatabaseName       , SchemaName	,TableName									,PartitionColumn			,NewStorage							, IntendToPartition	,  ReadyToQueue

END
GO
