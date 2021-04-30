-- <Migration ID="ebe0a54c-6fb5-5dbc-bc07-1d2b12481ea4" TransactionHandling="Custom" />
--:setvar DatabaseName "DOI"


GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_0_Databases]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_0_Databases];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE     PROCEDURE [DOI].[spRefreshMetadata_0_Databases]
    @DatabaseName NVARCHAR(128) = NULL

--WITH NATIVE_COMPILATION, SCHEMABINDING
AS

/*
    EXEC DOI.spRefreshMetadata_0_Databases
*/

--BEGIN ATOMIC WITH (LANGUAGE = 'English', TRANSACTION ISOLATION LEVEL = SNAPSHOT)
    EXEC [DOI].[spRefreshMetadata_System_SysDatabases]
        @DatabaseName = @DatabaseName
--END

GO
