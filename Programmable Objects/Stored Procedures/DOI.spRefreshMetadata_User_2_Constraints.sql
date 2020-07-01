-- <Migration ID="97202a2f-ee2c-4ac4-9e07-9ee58e0fed22"  TransactionHandling="Custom"/>
IF OBJECT_ID('[DOI].[spRefreshMetadata_User_2_Constraints]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_2_Constraints];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- <Migration ID="97202a2f-ee2c-4ac4-9e07-9ee58e0fed22" />
CREATE   PROCEDURE [DOI].[spRefreshMetadata_User_2_Constraints]

WITH NATIVE_COMPILATION, SCHEMABINDING
AS

/*
    EXEC DOI.[spRefreshMetadata_User_2_Constraints]
*/

BEGIN ATOMIC WITH (LANGUAGE = 'English', TRANSACTION ISOLATION LEVEL = SNAPSHOT)
    --EXEC DOI.spRefreshMetadata_User_Constraints_CreateTables
    EXEC DOI.spRefreshMetadata_User_Constraints_InsertData
    EXEC DOI.spRefreshMetadata_User_Constraints_UpdateData
END
GO
