-- <Migration ID="0f5f2171-aa3f-5085-a64c-7a35ece9898f" TransactionHandling="Custom" />
IF OBJECT_ID('DDI.spRefreshMetadata_User_Constraints_UpdateData') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_Constraints_UpdateData];
GO

CREATE OR ALTER PROCEDURE [DDI].[spRefreshMetadata_User_Constraints_UpdateData]

WITH NATIVE_COMPILATION, SCHEMABINDING
AS

/*
    EXEC DDI.[spRefreshMetadata_User_Constraints_UpdateData]
*/

BEGIN ATOMIC WITH (LANGUAGE = 'English', TRANSACTION ISOLATION LEVEL = SNAPSHOT)
    UPDATE DDI.DefaultConstraints
    SET DefaultConstraintName = 'Def_' + TableName + '_' + ColumnName 
END
GO