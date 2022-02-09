
IF OBJECT_ID('[DOI].[spRefreshMetadata_User_Constraints_UpdateData]') IS NOT NULL
DROP PROCEDURE [DOI].[spRefreshMetadata_User_Constraints_UpdateData]
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_User_Constraints_UpdateData]
    @DatabaseName NVARCHAR(128) = NULL

WITH NATIVE_COMPILATION, SCHEMABINDING
AS

/*
    EXEC DOI.[spRefreshMetadata_User_Constraints_UpdateData]
*/

BEGIN ATOMIC WITH (LANGUAGE = 'English', TRANSACTION ISOLATION LEVEL = SNAPSHOT)
    IF @DatabaseName IS NULL
    BEGIN
        UPDATE DOI.DefaultConstraints
        SET DefaultConstraintName = 'Def_' + TableName + '_' + ColumnName 
    END
    ELSE
    BEGIN
        UPDATE DOI.DefaultConstraints
        SET DefaultConstraintName = 'Def_' + TableName + '_' + ColumnName 
        WHERE DatabaseName = @DatabaseName
    END
END
GO