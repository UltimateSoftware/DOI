-- <Migration ID="7caa18b5-2f16-4aa2-b72c-869a09b5542b" />
GO

PRINT N'Dropping [DDI].[fnRefreshMetadataForView]'
GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[DDI].[fnRefreshMetadataForView]') AND (type = 'IF' OR type = 'FN' OR type = 'TF'))
DROP FUNCTION [DDI].[fnRefreshMetadataForView]
GO
PRINT N'Dropping [DDI].[fnGetRefreshMetadataSPsForView]'
GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[DDI].[fnGetRefreshMetadataSPsForView]') AND (type = 'IF' OR type = 'FN' OR type = 'TF'))
DROP FUNCTION [DDI].[fnGetRefreshMetadataSPsForView]
GO
