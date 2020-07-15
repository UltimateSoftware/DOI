-- <Migration ID="ebe0a54c-6fb5-5dbc-bc07-1d2b12481ea4" TransactionHandling="Custom" />
--:setvar DatabaseName "DOI"

USE [$(DatabaseName2)]
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_User_0_Databases]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_0_Databases];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE     PROCEDURE [DOI].[spRefreshMetadata_User_0_Databases]

WITH NATIVE_COMPILATION, SCHEMABINDING
AS

/*
    EXEC DOI.spRefreshMetadata_User_0_Databases
*/

BEGIN ATOMIC WITH (LANGUAGE = 'English', TRANSACTION ISOLATION LEVEL = SNAPSHOT)
    SELECT 'We are not doing anything here yet.'
    --EXEC [DOI].[spRefreshMetadata_User_Databases_InsertData]
END

GO
