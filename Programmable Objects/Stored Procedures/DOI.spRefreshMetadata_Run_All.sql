IF OBJECT_ID('[DOI].[spRefreshMetadata_Run_All]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_Run_All];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_Run_All]

AS

/*
    EXEC DOI.spRefreshMetadata_Run_All
*/

BEGIN TRY
    --BEGIN TRAN
    EXEC DOI.spRefreshMetadata_User_0_Databases
    EXEC DOI.spRefreshMetadata_Run_System
    EXEC DOI.spRefreshMetadata_Run_User
    --COMMIT TRAN
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    THROW;
END CATCH
GO
