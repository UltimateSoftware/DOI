IF OBJECT_ID('[DDI].[spRefreshMetadata_User_1_PartitionFunctions]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_1_PartitionFunctions];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DDI].[spRefreshMetadata_User_1_PartitionFunctions]

AS
    DROP TRIGGER IF EXISTS DDI.trUpdPartitionFunctions

    --EXEC DDI.spRefreshMetadata_User_PartitionFunctions_CreateTables
    EXEC DDI.spRefreshMetadata_User_PartitionFunctions_InsertData
    EXEC DDI.spRefreshMetadata_User_PartitionFunctions_UpdateData

GO
