USE [$(DatabaseName2)]
GO

IF OBJECT_ID('[DOI].[fn_ListToTable]') IS NOT NULL
	DROP FUNCTION [DOI].[fn_ListToTable];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   FUNCTION [DOI].[fn_ListToTable]
  (@p_List VARCHAR(MAX))
  RETURNS @r_List TABLE (Item VARCHAR(200) PRIMARY KEY CLUSTERED)
AS
BEGIN
DECLARE @v_POS INT,
        @v_OldPOS INT,
        @v_Done BIT,
        @v_Str VARCHAR(200)

SET @v_OldPOS = 0
SET @v_Done = 0

WHILE NOT (@v_Done = 1)
  BEGIN
  SET @v_POS = CHARINDEX(',', SUBSTRING(@p_List, @v_OldPos + 1, 250))
  IF (@v_POS > 0)
    SET @v_Str = SUBSTRING(@p_List, @v_OldPos + 1, ABS(@v_POS - 1))
    ELSE
    BEGIN
    SET @v_Str = SUBSTRING(@p_List, @v_OldPos + 1, 200)
    SET @v_Done = 1
    END

  SET @v_OldPOS = @v_OldPOS + @v_POS
  SET @v_Str = COALESCE(RTRIM(LTRIM(REPLACE(REPLACE(@v_Str,'''',''),'"',''))),'')

  IF NOT EXISTS(SELECT * FROM @r_List WHERE Item = @v_Str) AND (@v_Str <> '')
    INSERT INTO @r_List (Item) VALUES(@v_Str);
  END

RETURN

END


GO
