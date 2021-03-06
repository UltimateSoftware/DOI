
GO

IF OBJECT_ID('[DOI].[fnNumberTable]') IS NOT NULL
	DROP FUNCTION [DOI].[fnNumberTable];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   FUNCTION [DOI].[fnNumberTable](
	@NumRows INT)

RETURNS TABLE

/*
	SELECT * FROM DOI.fnNumberTable(10)
*/

AS
RETURN
(
	SELECT TOP (@NumRows) ROW_NUMBER() OVER(ORDER BY object_id) AS RowNum
	FROM SYS.OBJECTS
)
GO
