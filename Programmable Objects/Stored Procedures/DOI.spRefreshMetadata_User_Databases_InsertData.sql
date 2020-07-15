-- <Migration ID="6a92f07d-eb33-548c-9be6-fb834ef39594" TransactionHandling="Custom" />
USE [$(DatabaseName2)]
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_User_Databases_InsertData]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_Databases_InsertData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE     PROCEDURE [DOI].[spRefreshMetadata_User_Databases_InsertData]

WITH NATIVE_COMPILATION, SCHEMABINDING
AS

/*
    EXEC DOI.spRefreshMetadata_User_Databases_InsertData
*/

BEGIN ATOMIC WITH (LANGUAGE = 'English', TRANSACTION ISOLATION LEVEL = SNAPSHOT)
    DELETE DOI.Databases

    INSERT INTO DOI.Databases ( DatabaseName )
    VALUES ( N'PaymentReporting')
END
GO
