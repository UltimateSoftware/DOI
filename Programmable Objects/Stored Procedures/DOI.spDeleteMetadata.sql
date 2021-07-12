USE DOI
GO

IF OBJECT_ID('[DOI].[spDeleteMetadata]') IS NOT NULL
	DROP PROCEDURE [DOI].[spDeleteMetadata];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spDeleteMetadata]
    @DatabaseName NVARCHAR(128)
AS

/*
    exec [DOI].[spDeleteMetadata]
        @DAtabaseName = 'PaymentReporting'
*/

DELETE DOI.Databases WHERE DatabaseName = @DatabaseName
DELETE DOI.DOISettings WHERE DatabaseName = @DatabaseName
DELETE DOI.PartitionFunctions WHERE DatabaseName = @DatabaseName
DELETE DOI.CheckConstraints WHERE DatabaseName = @DatabaseName
DELETE DOI.DefaultConstraints WHERE DatabaseName = @DatabaseName
DELETE DOI.Tables WHERE DatabaseName = @DatabaseName
DELETE DOI.IndexesColumnStore WHERE DatabaseName = @DatabaseName
DELETE DOI.IndexesRowStore WHERE DatabaseName = @DatabaseName
DELETE DOI.IndexColumns WHERE DatabaseName = @DatabaseName
DELETE DOI.IndexPartitionsColumnStore WHERE DatabaseName = @DatabaseName
DELETE DOI.IndexPartitionsRowStore WHERE DatabaseName = @DatabaseName
DELETE DOI.[Statistics] WHERE DatabaseName = @DatabaseName
DELETE DOI.ForeignKeys WHERE DatabaseName = @DatabaseName

GO