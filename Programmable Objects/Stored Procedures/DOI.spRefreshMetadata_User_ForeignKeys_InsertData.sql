IF OBJECT_ID('[DOI].[spRefreshMetadata_User_ForeignKeys_InsertData]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_ForeignKeys_InsertData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_User_ForeignKeys_InsertData]

AS


SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
SET QUOTED_IDENTIFIER ON


DELETE DOI.ForeignKeys

INSERT [DOI].[ForeignKeys] 
        ([DatabaseName]         , [ParentSchemaName], [ParentTableName]                         , [ParentColumnList_Desired]                                    , [ReferencedSchemaName], [ReferencedTableName]                                 , [ReferencedColumnList_Desired]) 
VALUES	 (N'PaymentReporting'   ,N'DataMart'        , N'BankAccountPurposeDim'		            , N'ProductCodeKey'												, N'DataMart'	        , N'ProductCodeDim'										, N'ProductCodeKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'Bai2BankTransactions'		            , N'BankAccountDayId'											, N'dbo'		        , N'BankAccountDays'									, N'BankAccountDayId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'Bai2BankTransactions'		            , N'CounterpartUsgBankAccountId'								, N'dbo'		        , N'UsgBankAccounts'									, N'BankAccountId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'Bai2BankTransactions'		            , N'UsgBankAccountId'											, N'dbo'		        , N'UsgBankAccounts'									, N'BankAccountId')
--		,(N'PaymentReporting'   ,N'dbo'		        , N'BankTransactions'			            , N'Bai2BankTransactionMatchId'									, N'dbo'		        , N'Bai2BankTransactions'								, N'BankTransactionId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'BankTransactions'			            , N'TenantId'													, N'dbo'		        , N'Tenants'											, N'TenantId')
--		,(N'PaymentReporting'   ,N'dbo'		        , N'BankTransactions'			            , N'TenantId,CollectionId'										, N'dbo'		        , N'LiabilityCollections'								, N'CollectionId,TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'BankTransactions'			            , N'TenantId,CustomerBankAccountId'								, N'dbo'		        , N'CustomerBankAccounts'								, N'TenantId,BankAccountId')
--		,(N'PaymentReporting'   ,N'dbo'		        , N'BankTransactions'			            , N'PayId'														, N'dbo'		        , N'Pays'												, N'PayId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'BankTransactions'			            , N'Type'														, N'DataMart'	        , N'BankTransactionTypeDim'								, N'BankTransactionTypeKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'BankTransactions'			            , N'UsgBankAccountId'											, N'dbo'		        , N'UsgBankAccounts'									, N'BankAccountId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'BankTransactions'			            , N'FileRequestId'												, N'dbo'		        , N'FileRequests'										, N'FileRequestId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'Companies'					            , N'LegalEntityCompanyId,TenantId'								, N'dbo'		        , N'Companies'											, N'CompanyId,TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'Companies'					            , N'Status'														, N'DataMart'	        , N'CompanyStatusDim'									, N'CompanyStatusKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'Companies'					            , N'TenantId'													, N'dbo'		        , N'Tenants'											, N'TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'Companies'					            , N'Type'														, N'DataMart'	        , N'CompanyTypeDim'										, N'CompanyTypeKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'Company_Tax'			            	, N'CompanyId,TenantId'								            , N'dbo'		        , N'Companies'											, N'CompanyId,TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'Company_Tax'			            	, N'Company_TaxStatusKey'						            	, N'DataMart'	        , N'Company_TaxStatusDim'								, N'Company_TaxStatusKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'CompanyTaxAgency'			        	, N'Company_TaxGUID'								           	, N'dbo'		        , N'Company_Tax'										, N'Company_TaxGUID')
		,(N'PaymentReporting'   ,N'dbo'		        , N'CompanyTaxAgency'			        	, N'TaxAgencyId'								           		, N'dbo'		        , N'TaxAgency'											, N'TaxAgencyId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'CompanyTaxAgency'			        	, N'TenantId'								            		, N'dbo'		        , N'Tenants'											, N'TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'CompanyTaxAgency'			        	, N'TaxScheduleGUID'								            , N'dbo'		        , N'TaxSchedules'										, N'TaxScheduleGUID')
		,(N'PaymentReporting'   ,N'dbo'		        , N'CompanyTaxAgency'			        	, N'NextTaxScheduleGUID'								        , N'dbo'		        , N'TaxSchedules'										, N'TaxScheduleGUID')
		,(N'PaymentReporting'   ,N'dbo'		        , N'CompanyTaxAgency_Audit'			        , N'CompanyTaxAgencyId'								        	, N'dbo'		        , N'CompanyTaxAgency'									, N'CompanyTaxAgencyId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'CompanyProduct'				            , N'ProductCodeKey'										        , N'DataMart'	        , N'ProductCodeDim'										, N'ProductCodeKey'					)
		,(N'PaymentReporting'   ,N'dbo'		        , N'CompanyProduct'				            , N'Status'												        , N'DataMart'	        , N'ProductStatus'										, N'ProductStatusKey'				)
		,(N'PaymentReporting'   ,N'dbo'		        , N'CompanyProduct'				            , N'ActivationStatus'									        , N'DataMart'	        , N'ProductActivationStatus'							, N'ProductActivationStatusKey'		)
		,(N'PaymentReporting'   ,N'dbo'		        , N'CompanyProduct'				            , N'CompanyId'											        , N'dbo'		        , N'Companies'											, N'CompanyId'						)
		,(N'PaymentReporting'   ,N'dbo'		        , N'CustomerBankAccounts'		            , N'BankAccountType'											, N'DataMart'	        , N'BankAccountTypeDim'									, N'BankAccountTypeKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'CustomerBankAccounts'		            , N'Status'														, N'DataMart'	        , N'BankAccountStatusDim'								, N'BankAccountStatusKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'CustomerBankAccounts'		            , N'TenantId'													, N'dbo'		        , N'Tenants'											, N'TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'EFilingAcknowledgmentAlerts'            , N'SubmissionId'										        , N'dbo'		        , N'EFilingAcknowledgments'								, N'SubmissionId'			)
		,(N'PaymentReporting'   ,N'dbo'		        , N'EFilingAcknowledgments'		            , N'PayeeId'											        , N'dbo'		        , N'TaxAgency'											, N'TaxAgencyCode'			)
		,(N'PaymentReporting'   ,N'dbo'		        , N'FileRequests'				            , N'UsgBankAccountId'									        , N'dbo'		        , N'UsgBankAccounts'									, N'BankAccountId'			)
		,(N'PaymentReporting'   ,N'dbo'		        , N'FileRequests'				            , N'FileRequestProcessingStatusKey'						        , N'DataMart'	        , N'FileRequestProcessingStatusDim'						, N'FileRequestProcessingStatusKey'			)
		,(N'PaymentReporting'   ,N'dbo'		        , N'FileRequestPayments'		            , N'PaymentFileRequestId'								        , N'dbo'		        , N'FileRequests'										, N'FileRequestId'			)
		,(N'PaymentReporting'   ,N'dbo'		        , N'FileRequestPayments'		            , N'PaymentId'											        , N'dbo'		        , N'PayrollPayments'									, N'PayrollPaymentId'			)
		,(N'PaymentReporting'   ,N'dbo'		        , N'GarnishmentLiabilities'		            , N'GarnishmentLiabilityTypeKey'								, N'DataMart'	        , N'GarnishmentLiabilityTypeDim'						, N'GarnishmentLiabilityTypeKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'GarnishmentLiabilities'		            , N'LiabilityId'										        , N'dbo'		        , N'Liabilities'										, N'LiabilityId'			)
		,(N'PaymentReporting'   ,N'dbo'		        , N'GarnishmentLiabilities'		            , N'PayrollInstanceId,TenantId'							        , N'dbo'		        , N'PayrollInstances'									, N'PayrollInstanceId,TenantId'			)
		,(N'PaymentReporting'   ,N'dbo'		        , N'GarnishmentLiabilities'		            , N'GarnishmentLiabilityStatusKey'						        , N'DataMart'	        , N'GarnishmentLiabilityStatusDim'						, N'GarnishmentLiabilityStatusKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'GarnishmentPayrollInstances'            , N'TenantId'											        , N'dbo'		        , N'Tenants'											, N'TenantId'			)
		,(N'PaymentReporting'   ,N'dbo'		        , N'GarnishmentPayrollInstances'            , N'GarnishmentPayrollInstanceReconStatusKey'			        , N'DataMart'	        , N'GarnishmentPayrollInstanceReconStatusDim'			, N'GarnishmentPayrollInstanceReconStatusKey'			)
		,(N'PaymentReporting'   ,N'dbo'		        , N'GeneralLedgerAccounts'		            , N'ParentAccountId'											, N'dbo'		        , N'GeneralLedgerAccounts'								, N'AccountId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'JournalEntries'				            , N'AccountId'													, N'dbo'		        , N'GeneralLedgerAccounts'								, N'AccountId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'JournalEntries'				            , N'LiabilityId'												, N'dbo'		        , N'Liabilities'										, N'LiabilityId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'JournalEntries'				            , N'TenantId,CompanyId'											, N'dbo'		        , N'Companies'											, N'CompanyId,TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'JournalEntries'				            , N'TenantId,PayrollId'											, N'dbo'		        , N'PayrollUnits'										, N'PayrollId,TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'JournalEntries'				            , N'TransactionType'											, N'DataMart'	        , N'JournalEntryTransactionTypeDim'						, N'JournalEntryTransactionTypeDimKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'Liabilities'				            , N'Status'														, N'DataMart'	        , N'LiabilityStatusDim'									, N'LiabilityStatusKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'Liabilities'				            , N'TenantId'													, N'dbo'		        , N'Tenants'											, N'TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'Liabilities'				            , N'TenantId,CollectionId'										, N'dbo'		        , N'LiabilityCollections'								, N'CollectionId,TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'Liabilities'				            , N'TenantId,LegalEntityCompanyId'								, N'dbo'		        , N'Companies'											, N'CompanyId,TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'Liabilities'				            , N'TenantId,PayrollId'											, N'dbo'		        , N'PayrollUnits'										, N'PayrollId,TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'Liabilities'				            , N'Type'														, N'DataMart'	        , N'LiabilityTypeDim'									, N'LiabilityTypeKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'LiabilityCollections'		            , N'PaymentMethod'												, N'DataMart'	        , N'LiabilityCollectionPaymentMethoDOIm'				, N'LiabilityCollectionPaymentMethodKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'LiabilityCollections'		            , N'Status'														, N'DataMart'	        , N'LiabilityCollectionStatusDim'						, N'LiabilityCollectionStatusKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'LiabilityCollections'		            , N'TenantId'													, N'dbo'		        , N'Tenants'											, N'TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'LiabilityCollections'		            , N'TenantId,CustomerBankAccountId'								, N'dbo'		        , N'CustomerBankAccounts'								, N'TenantId,BankAccountId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'LiabilityCollections'		            , N'Type'														, N'DataMart'	        , N'LiabilityCollectionTypeDim'							, N'LiabilityCollectionTypeKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'LiabilityCollections'		            , N'UsgBankAccountId'											, N'dbo'		        , N'UsgBankAccounts'									, N'BankAccountId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'LiabilityCollections'		            , N'NettedCollectionId'											, N'dbo'		        , N'NettedCollections'									, N'NettedCollectionId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'LiabilityCollectionConfirmationInfos'	, N'LiabilityCollectionId,TenantId'				                , N'dbo'		        , N'LiabilityCollections'								, N'CollectionId,TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'LiabilityCollectionConfirmationInfos'	, N'TenantId'									                , N'dbo'		        , N'Tenants'											, N'TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'LiabilityCollectionConfirmationInfos'	, N'UsgBankAccountId'							                , N'dbo'		        , N'UsgBankAccounts'									, N'BankAccountId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'LiabilityCollectionComments'			, N'LiabilityCollectionId,TenantId'				                , N'dbo'		        , N'LiabilityCollections'								, N'CollectionId,TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'LiabilityCollectionComments'			, N'TenantId'									                , N'dbo'		        , N'Tenants'											, N'TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'LiabilityPayments'			            , N'LiabilityId'										        , N'dbo'		        , N'Liabilities'										, N'LiabilityId'			)
		,(N'PaymentReporting'   ,N'dbo'		        , N'LiabilityPayments'			            , N'PaymentId'											        , N'dbo'		        , N'PayrollPayments'									, N'PayrollPaymentId'			)
		,(N'PaymentReporting'   ,N'dbo'		        , N'NettedCollections'			            , N'Status'														, N'DataMart'	        , N'NettedCollectionStatusDim'							, N'NettedCollectionStatusKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'NettedCollections'			            , N'PaymentMethod'												, N'DataMart'	        , N'LiabilityCollectionPaymentMethoDOIm'				, N'LiabilityCollectionPaymentMethodKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'NettedCollections'			            , N'TenantId'													, N'dbo'		        , N'Tenants'											, N'TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'NettedCollections'			            , N'UsgBankAccountId'											, N'dbo'		        , N'UsgBankAccounts'									, N'BankAccountId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'NettedCollections'			            , N'TenantId,CustomerBankAccountId'								, N'dbo'		        , N'CustomerBankAccounts'								, N'TenantId,BankAccountId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'NettedCollectionsLiabilityCollections'	, N'NettedCollectionId'							                , N'dbo'		        , N'NettedCollections'									, N'NettedCollectionId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayActions'					            , N'FromState'											        , N'DataMart'	        , N'PayPortionStateDim'									, N'PayPortionStateKey'		)
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayActions'					            , N'ToState'											        , N'DataMart'	        , N'PayPortionStateDim'									, N'PayPortionStateKey'		)
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayActions'					            , N'Portion'											        , N'DataMart'	        , N'RefundPortionDim'									, N'RefundPortionKey'		)
--      ([ParentSchemaName]     , [ParentTableName]                         , [ParentColumnList]                                            , [ReferencedSchemaName], [ReferencedTableName]                                 , [ReferencedColumnList]) 
--		,(N'PaymentReporting'   ,N'dbo'		        , N'PayActions'					            , N'PayId'												        , N'dbo'		        , N'Pays'												, N'PayId'			)
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayActions'					            , N'LiabilityId'										        , N'dbo'		        , N'Liabilities'										, N'LiabilityId'			)
--		,(N'PaymentReporting'   ,N'dbo'		        , N'PayLiabilities'				            , N'PayId'												        , N'dbo'		        , N'Pays'												, N'PayId'			)
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayLiabilities'				            , N'LiabilityId'										        , N'dbo'		        , N'Liabilities'										, N'LiabilityId'	)
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayLiabilities'				            , N'ActionId'											        , N'dbo'		        , N'PayActions'											, N'ActionId'	)
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayGarnishment_Deductions'	            , N'MedIndicatorKey'											, N'DataMart'	        , N'GarnishmentMedIndicatorDim'							, N'MedIndicatorKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayGarnishment_Deductions'	            , N'PayUtcDate,GarnishmentId'									, N'dbo'		        , N'PayGarnishments'									, N'PayUtcDate,GarnishmentId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayGarnishment_Employees'	            , N'IsInArrearsKey'												, N'DataMart'	        , N'GarnishmentIsInArrearsDim'							, N'IsInArrearsKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayGarnishment_Employees'	            , N'CountryCode,StateCode'										, N'dbo'		        , N'States'												, N'CountryCode,StateCode')
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayGarnishment_Employees'	            , N'SupportsOthersKey'											, N'DataMart'	        , N'GarnishmentsSupportsOthersDim'						, N'SupportsOthersKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayGarnishment_Employees'	            , N'PayUtcDate,GarnishmentId'									, N'dbo'		        , N'PayGarnishments'									, N'PayUtcDate,GarnishmentId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayGarnishment_Payees'		            , N'PayUtcDate,GarnishmentId'									, N'dbo'		        , N'PayGarnishments'									, N'PayUtcDate,GarnishmentId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayGarnishmentActions'		            , N'ActionTypeKey'										        , N'DataMart'	        , N'GarnishmentActionTypeDim'							, N'GarnishmentActionTypeKey'		)
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayGarnishmentActions'		            , N'PayUtcDate,GarnishmentId'							        , N'dbo'		        , N'PayGarnishments'									, N'PayUtcDate,GarnishmentId'			)
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayGarnishmentExceptions'	            , N'GarnishmentExceptionKey'									, N'DataMart'	        , N'GarnishmentExceptionDim'							, N'GarnishmentExceptionKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayGarnishmentExceptions'	            , N'PayUtcDate,GarnishmentId'									, N'dbo'		        , N'PayGarnishments'									, N'PayUtcDate,GarnishmentId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayGarnishmentLiabilities'	            , N'PayUtcDate,GarnishmentId'							        , N'dbo'		        , N'PayGarnishments'									, N'PayUtcDate,GarnishmentId'			)
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayGarnishmentLiabilities'	            , N'GarnishmentLiabilityId,TenantId'					        , N'dbo'		        , N'GarnishmentLiabilities'								, N'GarnishmentLiabilityId,TenantId'	)
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayGarnishmentLiabilities'	            , N'PayUtcDate,GarnishmentId,ActionId'					        , N'dbo'		        , N'PayGarnishmentActions'								, N'PayUtcDate,GarnishmentId,ActionId'	)
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayGarnishments'			            , N'GarnishmentActionReasonKey'							        , N'DataMart'	        , N'GarnishmentActionReasonDim'							, N'GarnishmentActionReasonKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayGarnishments'			            , N'CheckAddModeKey'											, N'DataMart'	        , N'CheckAddModeDim'									, N'checkAddModeKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayGarnishments'			            , N'GarnishmentPayableStatusKey'								, N'DataMart'	        , N'GarnishmentPayableStatusDim'						, N'GarnishmentPayableStatusKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayGarnishments'			            , N'GarnishmentPaymentTypeKey'									, N'DataMart'	        , N'GarnishmentPaymentTypeDim'							, N'GarnishmentPaymentTypeKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayGarnishments'			            , N'GarnishmentStatusKey'										, N'DataMart'	        , N'GarnishmentStatusDim'								, N'GarnishmentStatusKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayGarnishments'			            , N'GarnishmentTypeKey'											, N'DataMart'	        , N'GarnishmentTypeDim'									, N'GarnishmentTypeKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayGarnishments'			            , N'TenantId,CompanyId'											, N'dbo'		        , N'Companies'											, N'CompanyId,TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayGarnishments'			            , N'TenantId,LegalEntityCompanyId'								, N'dbo'		        , N'Companies'											, N'CompanyId,TenantId')
--		,(N'PaymentReporting'   ,N'dbo'		        , N'PayGarnishments'			            , N'PayId'														, N'dbo'		        , N'Pays'												, N'PayId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayGarnishments'			            , N'TenantId,PayrollId'											, N'dbo'		        , N'PayrollUnits'										, N'PayrollId,TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayGarnishments'			            , N'TenantId,PayrollInstanceId'									, N'dbo'		        , N'PayrollInstances'									, N'PayrollInstanceId,TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayGarnishments'			            , N'GarnishmentLiabilityId,TenantId'							, N'dbo'		        , N'GarnishmentLiabilities'								, N'GarnishmentLiabilityId,TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayrollInstances'			            , N'TenantId'													, N'dbo'		        , N'Tenants'											, N'TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayrollInstances'			            , N'PayrollTypeKey'										        , N'DataMart'	        , N'PayrollTypeDim'										, N'PayrollTypeKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayrollPayments'		                , N'Status'												        , N'DataMart'	        , N'PayrollPaymentStatusDim'							, N'PayrollPaymentStatusKey'			)
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayrollPayments'			            , N'PaymentType'										        , N'DataMart'	        , N'PayrollPaymentTypeDim'								, N'PayrollPaymentTypeKey'			)
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayrollPayments'			            , N'UsgBankAccountId'									        , N'dbo'		        , N'UsgBankAccounts'									, N'BankAccountId'			)
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayrollUnits'				            , N'TenantId'													, N'dbo'		        , N'Tenants'											, N'TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'PayrollUnits'				            , N'TenantId,LegalEntityCompanyId'								, N'dbo'		        , N'Companies'											, N'CompanyId,TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'Pays'						            , N'ExceptionType'												, N'DataMart'	        , N'PayExceptionTypeDim'								, N'PayExceptionTypeKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'Pays'						            , N'ProcessingStatus'											, N'DataMart'	        , N'PayProcessingStatusDim'								, N'PayProcessingStatusKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'Pays'						            , N'TenantId'													, N'dbo'		        , N'Tenants'											, N'TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'Pays'						            , N'TenantId,CompanyId'											, N'dbo'		        , N'Companies'											, N'CompanyId,TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'Pays'						            , N'NetPayLiabilityId'											, N'dbo'		        , N'Liabilities'										, N'LiabilityId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'Pays'						            , N'TenantId,PayrollId'											, N'dbo'		        , N'PayrollUnits'										, N'PayrollId,TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'Pays'						            , N'TenantId,PayrollInstanceId'									, N'dbo'		        , N'PayrollInstances'									, N'PayrollInstanceId,TenantId')
--		,(N'PaymentReporting'   ,N'dbo'		        , N'PayTaxes'					            , N'PayId'														, N'dbo'		        , N'Pays'												, N'PayId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'ReportRequests'				            , N'TenantId'											        , N'dbo'		        , N'Tenants'											, N'TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'ReportRequests'				            , N'Status'											        	, N'DataMart'	        , N'ReportRequestStatusDim'								, N'ReportRequestStatusKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'ReportParameters'			            , N'ReportRequestId'									        , N'dbo'		        , N'ReportRequests'										, N'ReportRequestId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'ReportFileInformation'		            , N'ReportRequestId'									        , N'dbo'		        , N'ReportRequests'										, N'ReportRequestId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'ReportStatistics'			            , N'ReportRequestId'									        , N'dbo'		        , N'ReportRequests'										, N'ReportRequestId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'ReportObjectStoreInfo'		            , N'ReportRequestId'									        , N'dbo'		        , N'ReportRequests'										, N'ReportRequestId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxAgency_Audit'			            , N'TaxAgencyId'									 			, N'dbo'		        , N'TaxAgency'											, N'TaxAgencyId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxAgencyTransactions'		            , N'TaxAgencyId'												, N'dbo'		        , N'TaxAgency'											, N'TaxAgencyId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxAgencyTransactions'		            , N'TaxAgencyTransactionStatusKey'								, N'DataMart'	        , N'TaxAgencyTransactionStatusDim'						, N'TaxAgencyTransactionStatusKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxAgencyTransactions'		            , N'TenantId'													, N'dbo'		        , N'Tenants'											, N'TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxAgencyTransactions'		            , N'TenantId,LegalEntityCompanyId'								, N'dbo'		        , N'Companies'											, N'CompanyId,TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxAgencyTransactions'		            , N'PaymentLiabilityId'											, N'dbo'		        , N'Liabilities'										, N'LiabilityId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxAgencyTransactions'		            , N'PaymentVoidLiabilityId'										, N'dbo'		        , N'Liabilities'										, N'LiabilityId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxAgencyTransactions'		            , N'PaymentType'												, N'DataMart'	        , N'TaxPaymentTypeDim'									, N'TaxPaymentTypeKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxAmounts'					            , N'TenantId'													, N'dbo'		        , N'Tenants'											, N'TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxAmounts'					            , N'TaxPayrollGUID,UTETaxDataSourceTableSetKey,TenantId'		, N'dbo'		        , N'TaxPayrolls'										, N'TaxPayrollGUID,UTETaxDataSourceTableSetKey,TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxAmounts'					            , N'UTETaxDataSourceTableSetKey'								, N'DataMart'	        , N'UTETaxDataSourceTableSetDim'						, N'UTETaxDataSourceTableSetKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxAmounts'					            , N'TaxId'                      								, N'dbo'	            , N'TaxCodes'                     						, N'TaxId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxAmountsUltiTaxCodes'		            , N'TenantId'													, N'dbo'		        , N'Tenants'											, N'TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxAmountsUltiTaxCodes'		            , N'TaxPayrollGUID,UTETaxDataSourceTableSetKey,TaxId,TenantId'	, N'dbo'		        , N'TaxAmounts'											, N'TaxPayrollGUID,UTETaxDataSourceTableSetKey,TaxId, TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxAmountsUltiTaxCodes'		            , N'UTETaxDataSourceTableSetKey'								, N'DataMart'	        , N'UTETaxDataSourceTableSetDim'						, N'UTETaxDataSourceTableSetKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxCodes'					            , N'ActiveStatus'												, N'DataMart'	        , N'TaxCodeActiveStatus'								, N'TaxCodeActiveStatusKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxCodes'					            , N'TaxAgencyId'												, N'dbo'		        , N'TaxAgency'											, N'TaxAgencyId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxLiabilities'				            , N'LiabilityId'										        , N'dbo'		        , N'Liabilities'										, N'LiabilityId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxLiabilities'				            , N'TenantId,LegalEntityCompanyId'						        , N'dbo'		        , N'Companies'											, N'CompanyId,TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxLiabilities'				            , N'CollectedFromTenantId,CollectedFromCompanyId'		        , N'dbo'		        , N'Companies'											, N'CompanyId,TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxLiabilities'				            , N'CollectionId,CollectedFromTenantId'					        , N'dbo'		        , N'LiabilityCollections'								, N'CollectionId,TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxLiabilities'				            , N'PayrollId,TenantId'									        , N'dbo'		        , N'PayrollUnits'										, N'PayrollId,TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxLiabilities'				            , N'CollectedFromPayrollId,CollectedFromTenantId'		        , N'dbo'		        , N'PayrollUnits'										, N'PayrollId,TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxLiabilities'				            , N'TaxLiabilityOriginTypeKey'							        , N'DataMart'	        , N'TaxLiabilityOriginTypeDim'							, N'TaxLiabilityOriginTypeKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxPaymentCredits'			            , N'CreditEffectOnLiabilityKey'									, N'DataMart'	        , N'CreditEffectOnLiabilityDim'							, N'CreditEffectOnLiabilityKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxPaymentCredits'			            , N'TaxPaymentCreditStatusKey'									, N'DataMart'	        , N'TaxPaymentCreditStatusDim'							, N'TaxPaymentCreditStatusKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxPaymentCredits'			            , N'LiabilityId'												, N'dbo'		        , N'Liabilities'										, N'LiabilityId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxPaymentCredits'			            , N'TaxCreditId'										        , N'dbo'		        , N'TaxAgencyTransactions'								, N'TransactionGUID')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxPaymentCredits'			            , N'TaxPaymentId'										        , N'dbo'		        , N'TaxAgencyTransactions'								, N'TransactionGUID')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxPaymentCredits'			            , N'ReducedQEAdjLiabilityPaymentId'						        , N'dbo'		        , N'TaxAgencyTransactions'								, N'TransactionGUID')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxPayrolls'				            , N'TenantId'													, N'dbo'		        , N'Tenants'											, N'TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxPayrolls'				            , N'LiabilityId'												, N'dbo'		        , N'Liabilities'										, N'LiabilityId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxPayrolls'				            , N'TenantId,PayrollId'											, N'dbo'		        , N'PayrollUnits'										, N'PayrollId,TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TaxPayrolls'				            , N'UTETaxDataSourceTableSetKey'								, N'DataMart'	        , N'UTETaxDataSourceTableSetDim'						, N'UTETaxDataSourceTableSetKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TenantProduct'				            , N'ActivationStatus'											, N'DataMart'	        , N'ProductActivationStatus'							, N'ProductActivationStatusKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TenantProduct'				            , N'ProductCodeKey'												, N'DataMart'	        , N'ProductCodeDim'										, N'ProductCodeKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TenantProduct'				            , N'Status'														, N'DataMart'	        , N'ProductStatus'										, N'ProductStatusKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TenantProduct'				            , N'TenantId'													, N'dbo'		        , N'Tenants'											, N'TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TenantStatus'				            , N'TenantId'													, N'dbo'		        , N'Tenants'											, N'TenantId')
		,(N'PaymentReporting'   ,N'dbo'		        , N'TenantStatus'				            , N'TenantStatusCode'											, N'DataMart'	        , N'TenantStatusDim'									, N'TenantStatusCode')
		,(N'PaymentReporting'   ,N'dbo'		        , N'UltiProTaxCodeMapping'		            , N'ProcessingFrequency'								        , N'DataMart'	        , N'TaxCodeProcessingFrequencyDim'						, N'TaxCodeProcessingFrequencyKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'UsgBankAccounts'			            , N'AccountPurpose'												, N'DataMart'	        , N'BankAccountPurposeDim'								, N'BankAccountPurposeKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'UsgBankAccounts'			            , N'BankAccountType'											, N'DataMart'	        , N'BankAccountTypeDim'									, N'BankAccountTypeKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'UsgBankAccounts'			            , N'Status'														, N'DataMart'	        , N'BankAccountStatusDim'								, N'BankAccountStatusKey')
--		,(N'PaymentReporting'   ,N'dbo'		        , N'PayActions'					            , N'PayId'												        , N'dbo'		        , N'Pays'												, N'PayId'			)
--		,(N'PaymentReporting'   ,N'dbo'		        , N'PayLiabilities'				            , N'PayId'												        , N'dbo'		        , N'Pays'												, N'PayId'			)
		,(N'PaymentReporting'   ,N'dbo'		        , N'YEProcessing'				            , N'YEProcessingStatusKey'										, N'DataMart'	        , N'YEProcessingStatusDim'								, N'YEProcessingStatusKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'YEProcessing'				            , N'TenantId'													, N'dbo'		        , N'Tenants'											, N'TenantId'			)
		,(N'PaymentReporting'   ,N'dbo'		        , N'YEProcessingFiles'			            , N'YEProcessingId'												, N'dbo'		        , N'YEProcessing'										, N'YEProcessingId'			)
		,(N'PaymentReporting'   ,N'dbo'		        , N'YEProcessingFiles'			            , N'InboundFileTypeKey'											, N'DataMart'	        , N'InboundFileTypeDim'									, N'InboundFileTypeKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'YEProcessingFiles'			            , N'AgencyLocalityTypeKey'										, N'DataMart'	        , N'AgencyLocalityTypeDim'								, N'AgencyLocalityTypeKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'YEProcessingFiles'			            , N'YEFileStatusKey'											, N'DataMart'	        , N'YEFileStatusDim'									, N'YEFileStatusKey')
		,(N'PaymentReporting'   ,N'dbo'		        , N'YEProcessingFiles'			            , N'Agency'														, N'dbo'		        , N'TaxAgency'											, N'TaxAgencyCode')
		,(N'PaymentReporting'   ,N'dbo'		        , N'YEProcessingFiles'			            , N'YEIngestionTypeKey'											, N'DataMart'	        , N'YEIngestionTypeDim'									, N'YEIngestionTypeKey')
--      ([ParentSchemaName]     , [ParentTableName]                         , [ParentColumnList]                                            , [ReferencedSchemaName], [ReferencedTableName]                                 , [ReferencedColumnList]) 
GO