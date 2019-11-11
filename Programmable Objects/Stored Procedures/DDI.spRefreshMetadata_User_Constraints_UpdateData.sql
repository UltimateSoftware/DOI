IF OBJECT_ID('[DDI].[spRefreshMetadata_User_Constraints_UpdateData]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_Constraints_UpdateData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [DDI].[spRefreshMetadata_User_Constraints_UpdateData]
AS

UPDATE DDI.DefaultConstraints
SET DefaultConstraintName = 'Def_' + TableName + '_' + ColumnName 

GO
