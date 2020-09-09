-- <Migration ID="6a92f07d-eb33-548c-9be6-fb834ef39594" TransactionHandling="Custom" />

GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_User_Databases_InsertData]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_Databases_InsertData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE     PROCEDURE [DOI].[spRefreshMetadata_User_Databases_InsertData]
    @DatabaseName NVARCHAR(128) = NULL

--WITH NATIVE_COMPILATION, SCHEMABINDING
AS

/*
    EXEC DOI.spRefreshMetadata_User_Databases_InsertData
*/

--BEGIN ATOMIC WITH (LANGUAGE = 'English', TRANSACTION ISOLATION LEVEL = SNAPSHOT)
    DELETE DOI.Databases
    WHERE DatabaseName = CASE WHEN @DatabaseName IS NULL THEN DatabaseName ELSE @DatabaseName END

    INSERT INTO DOI.Databases ( DatabaseName )
    SELECT NAME
    FROM sys.databases
    WHERE NAME = CASE WHEN @DatabaseName IS NULL THEN NAME ELSE @DatabaseName END
        AND name NOT IN ('master', 'tempdb', 'model', 'msdb')
--END
GO