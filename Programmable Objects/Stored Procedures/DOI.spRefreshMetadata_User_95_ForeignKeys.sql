
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_User_95_ForeignKeys]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_95_ForeignKeys];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE     PROCEDURE [DOI].[spRefreshMetadata_User_95_ForeignKeys]
    @DatabaseName NVARCHAR(128) = NULL

AS

--EXEC DOI.spRefreshMetadata_User_ForeignKeys_InsertData
EXEC DOI.spRefreshMetadata_User_ForeignKeys_UpdateData
    @DatabaseName = @DatabaseName

GO
