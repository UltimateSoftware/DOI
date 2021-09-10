
IF OBJECT_ID('[DOI].[fnGetPKColumnListForTable_Desired]') IS NOT NULL
	DROP FUNCTION [DOI].[fnGetPKColumnListForTable_Desired];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   FUNCTION [DOI].[fnGetPKColumnListForTable_Desired](
    @DatabaseName               SYSNAME,
	@SchemaName					SYSNAME, 
	@TableName					SYSNAME)

RETURNS NVARCHAR(MAX)
AS

/*
	select DOI.[fnGetPKColumnListForTable_Desired]('PaymentReporting', 'dbo', 'Pays')
*/

BEGIN
	DECLARE @ColumnList NVARCHAR(MAX) = ''
    
    SELECT @ColumnList += IRS.KeyColumnList_Desired
    --select *
    FROM DOI.IndexesRowStore IRS
    WHERE IRS.IsPrimaryKey_Desired = 1
        AND IRS.DatabaseName = @DatabaseName
        AND IRS.SchemaName = @SchemaName
        AND IRS.TableName = @TableName

    RETURN @ColumnList
END

GO