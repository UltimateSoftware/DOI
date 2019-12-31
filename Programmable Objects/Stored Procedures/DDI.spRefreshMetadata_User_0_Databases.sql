-- <Migration ID="ebe0a54c-6fb5-5dbc-bc07-1d2b12481ea4" TransactionHandling="Custom" />
IF OBJECT_ID('[DDI].[spRefreshMetadata_User_0_Databases]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_0_Databases];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE     PROCEDURE [DDI].[spRefreshMetadata_User_0_Databases]

WITH NATIVE_COMPILATION, SCHEMABINDING
AS

/*
    EXEC DDI.spRefreshMetadata_User_0_Databases
*/

BEGIN ATOMIC WITH (LANGUAGE = 'English', TRANSACTION ISOLATION LEVEL = SNAPSHOT)
    EXEC [DDI].[spRefreshMetadata_User_Databases_InsertData]
END

GO
