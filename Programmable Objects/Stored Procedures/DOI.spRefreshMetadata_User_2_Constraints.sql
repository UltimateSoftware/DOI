-- <Migration ID="a09baee5-ee77-5b4e-bce6-1ccf8c660917" TransactionHandling="Custom" />

GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_User_2_Constraints]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_2_Constraints];
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_User_0_Databases]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_0_Databases];
GO


SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE OR ALTER PROCEDURE [DOI].[spRefreshMetadata_User_Constraints_UpdateData]

WITH NATIVE_COMPILATION, SCHEMABINDING
AS

/*
    EXEC DOI.[spRefreshMetadata_User_Constraints_UpdateData]
*/

BEGIN ATOMIC WITH (LANGUAGE = 'English', TRANSACTION ISOLATION LEVEL = SNAPSHOT)
    UPDATE DOI.DefaultConstraints
    SET DefaultConstraintName = 'Def_' + TableName + '_' + ColumnName 
END
GO

CREATE OR ALTER PROCEDURE [DOI].[spRefreshMetadata_User_2_Constraints]

WITH NATIVE_COMPILATION, SCHEMABINDING
AS

/*
    EXEC DOI.[spRefreshMetadata_User_2_Constraints]
*/

BEGIN ATOMIC WITH (LANGUAGE = 'English', TRANSACTION ISOLATION LEVEL = SNAPSHOT)
    --EXEC DOI.spRefreshMetadata_User_Constraints_CreateTables
    --EXEC DOI.spRefreshMetadata_User_Constraints_InsertData
    EXEC DOI.spRefreshMetadata_User_Constraints_UpdateData
END
GO