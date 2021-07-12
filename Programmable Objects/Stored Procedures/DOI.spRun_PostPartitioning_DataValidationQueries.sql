

IF OBJECT_ID('[DOI].[spRun_PostPartitioning_DataValidationQueries]') IS NOT NULL
	DROP PROCEDURE [DOI].spRun_PostPartitioning_DataValidationQueries;

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].spRun_PostPartitioning_DataValidationQueries
    @DatabaseName SYSNAME,
	@SchemaName SYSNAME,
	@TableName SYSNAME,
	@PostDataValidationQueriesSQL VARCHAR(MAX) = '' OUTPUT

AS

/*
	EXEC DOI.spRun_PostPartitioning_DataValidationQueries
		@DatabaseName = 'PaymentReporting',
		@SchemaName = 'dbo',
		@TableName = 'Pays',
		@Debug = 1
*/

SELECT @PostDataValidationQueriesSQL = PostDataValidationMissingEventsSQL + CHAR(13) + CHAR(10) + PostDataValidationCompareByPartitionSQL
FROM DOI.vwPartitioning_Tables_PrepTables
WHERE DatabaseName = @DatabaseName
	AND SchemaName = @SchemaName
	AND TableName = @TableName
	AND IsNewPartitionedPrepTable = 1

SELECT @PostDataValidationQueriesSQL
GO