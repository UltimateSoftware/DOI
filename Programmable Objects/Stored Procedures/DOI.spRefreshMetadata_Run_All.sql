IF OBJECT_ID('[DOI].[spRefreshMetadata_Run_All]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_Run_All];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_Run_All]
    @DatabaseName NVARCHAR(128) = NULL,
    @Debug BIT = 0

AS

/*
    EXEC DOI.spRefreshMetadata_Run_All
        @Debug = 1
*/

BEGIN TRY
    --BEGIN TRAN
    IF @DatabaseName IS NOT NULL
    BEGIN
        DECLARE @DatabaseId INT = (SELECT database_id FROM sys.databases WHERE name = @DatabaseName)
    END

    EXEC DOI.spRefreshMetadata_Run_System
        @DatabaseId = @DatabaseId,
        @Debug = @Debug

    EXEC DOI.spRefreshMetadata_Run_User
        @DatabaseName = @DatabaseName,
        @Debug = @Debug
    --COMMIT TRAN
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    THROW;
END CATCH
GO
