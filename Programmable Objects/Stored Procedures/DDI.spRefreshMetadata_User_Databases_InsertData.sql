-- <Migration ID="6a92f07d-eb33-548c-9be6-fb834ef39594" TransactionHandling="Custom" />
IF OBJECT_ID('[DDI].[spRefreshMetadata_User_Databases_InsertData]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_Databases_InsertData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE     PROCEDURE [DDI].[spRefreshMetadata_User_Databases_InsertData]

WITH NATIVE_COMPILATION, SCHEMABINDING
AS

/*
    EXEC DDI.spRefreshMetadata_User_Databases_InsertData
*/

BEGIN ATOMIC WITH (LANGUAGE = 'English', TRANSACTION ISOLATION LEVEL = SNAPSHOT)
    DELETE DDI.Databases

    INSERT INTO DDI.Databases ( DatabaseName )
    VALUES ( N'PaymentReporting')
END
GO
