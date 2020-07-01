-- <Migration ID="7caa18b5-2f16-4aa2-b72c-869a09b5542b" />
GO

PRINT N'Dropping [DOI].[fnRefreshMetadataForView]'
GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[DOI].[fnRefreshMetadataForView]') AND (type = 'IF' OR type = 'FN' OR type = 'TF'))
DROP FUNCTION [DOI].[fnRefreshMetadataForView]
GO
PRINT N'Dropping [DOI].[fnGetRefreshMetadataSPsForView]'
GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[DOI].[fnGetRefreshMetadataSPsForView]') AND (type = 'IF' OR type = 'FN' OR type = 'TF'))
DROP FUNCTION [DOI].[fnGetRefreshMetadataSPsForView]
GO
