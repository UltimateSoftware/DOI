-- <Migration ID="a09baee5-ee77-5b4e-bce6-1ccf8c660917" TransactionHandling="Custom" />

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_1_DefaultConstraints]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_1_DefaultConstraints];
GO

CREATE PROCEDURE [DOI].[spRefreshMetadata_1_DefaultConstraints]
    @DatabaseName NVARCHAR(128) = NULL

--WITH NATIVE_COMPILATION, SCHEMABINDING
AS

/*
    EXEC DOI.[spRefreshMetadata_1_DefaultConstraints]
        @DatabaseName = 'DOIUnitTests'
*/

--BEGIN ATOMIC WITH (LANGUAGE = 'English', TRANSACTION ISOLATION LEVEL = SNAPSHOT)
    EXEC DOI.spRefreshMetadata_0_Databases
        @DatabaseName = @DatabaseName

    EXEC DOI.spRefreshMetadata_System_SysDefaultConstraints
        @DatabaseName = @DatabaseName

    EXEC DOI.spRefreshMetadata_User_Constraints_UpdateData
        @DatabaseName = @DatabaseName

--END
GO