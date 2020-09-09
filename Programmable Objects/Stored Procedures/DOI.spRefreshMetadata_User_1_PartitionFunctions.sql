--:setvar DatabaseName "DOI"

GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_User_1_PartitionFunctions]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_User_1_PartitionFunctions];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRefreshMetadata_User_1_PartitionFunctions]

AS
    DROP TRIGGER IF EXISTS DOI.trUpdPartitionFunctions

    --EXEC DOI.spRefreshMetadata_User_PartitionFunctions_CreateTables
    --EXEC DOI.spRefreshMetadata_User_PartitionFunctions_InsertData
    EXEC DOI.spRefreshMetadata_User_PartitionFunctions_UpdateData

GO
