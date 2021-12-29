-- <Migration ID="a09baee5-ee77-5b4e-bce6-1ccf8c660917" TransactionHandling="Custom" />

IF OBJECT_ID('[DOI].[spRefreshMetadata_1_CheckConstraints]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_1_CheckConstraints];
GO

CREATE PROCEDURE [DOI].[spRefreshMetadata_1_CheckConstraints]
    @DatabaseName NVARCHAR(128) = NULL

--WITH NATIVE_COMPILATION, SCHEMABINDING
AS

/*
    EXEC DOI.[spRefreshMetadata_1_CheckConstraints]
        @DatabaseName = 'DOIUnitTests'
*/

--BEGIN ATOMIC WITH (LANGUAGE = 'English', TRANSACTION ISOLATION LEVEL = SNAPSHOT)
    EXEC DOI.spRefreshMetadata_0_Databases
        @DatabaseName = @DatabaseName

    EXEC DOI.spRefreshMetadata_System_SysCheckConstraints
        @DatabaseName = @DatabaseName

    EXEC DOI.spRefreshMetadata_User_Constraints_UpdateData
        @DatabaseName = @DatabaseName
--END
GO