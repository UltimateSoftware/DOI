
GO

IF OBJECT_ID('[DOI].[fnGetJoinClauseForTable_Desired]') IS NOT NULL
	DROP FUNCTION [DOI].[fnGetJoinClauseForTable_Desired];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   FUNCTION [DOI].[fnGetJoinClauseForTable_Desired](
    @DatabaseName               SYSNAME,
	@SchemaName					SYSNAME, 
	@TableName					SYSNAME, 
	@NumberOfTabs				TINYINT = 1,
	@SourceTableAlias			VARCHAR(50) = '',
	@DestinationTableAlias		VARCHAR(50) = '')

RETURNS NVARCHAR(MAX)
AS

/*
	select [DOI].[fnGetJoinClauseForTable_Desired]('PaymentReporting', 'DBO', 'Pays', 1, 'S', 'D')
    select [DOI].[fnGetJoinClauseForTable_Desired]('DBO', 'Pays', 1)
*/

BEGIN
	DECLARE @JoinClauseSQL NVARCHAR(MAX) = '',
            @TabString NVARCHAR(50) = REPLICATE(CHAR(9), @NumberOfTabs)

    SELECT @JoinClauseSQL += CASE WHEN @JoinClauseSQL = '' THEN '' ELSE @TabString + 'AND ' END + @SourceTableAlias + '.' + ColumnName + ' = ' + @DestinationTableAlias + '.' + ColumnName + CHAR(13) + CHAR(10)
    --select *
    FROM DOI.IndexColumns IC
        INNER JOIN DOI.IndexesRowStore IRS ON IRS.DatabaseName = IC.DatabaseName
            AND IRS.SchemaName = IC.SchemaName
            AND IRS.TableName = IC.TableName
            AND IRS.IndexName = IC.IndexName
    WHERE IRS.IsPrimaryKey_Desired = 1
        AND IC.DatabaseName = @DatabaseName
        AND IC.SchemaName = @SchemaName
        AND IC.TableName = @TableName
    ORDER BY KeyColumnPosition

    RETURN @JoinClauseSQL
END

GO
