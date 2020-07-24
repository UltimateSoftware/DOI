
GO

IF OBJECT_ID('[DOI].[fnIndexPartitionAgg]') IS NOT NULL
	DROP FUNCTION [DOI].[fnIndexPartitionAgg];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   FUNCTION [DOI].[fnIndexPartitionAgg]()   

RETURNS TABLE 
WITH NATIVE_COMPILATION, SCHEMABINDING 
 
AS   

/*
    SELECT * FROM DOI.fnIndexPartitionAgg()   
*/

RETURN  (
    SELECT	SchemaName,
		    TableName,
		    IndexName, 
		    PartitionNumber,
		    TotalIndexPartitionSizeInMB, 
		    DataFileName, 
		    NumRows, 
		    TotalPages,
		    Fragmentation,
		    PartitionUpdateType,
		    PartitionType,
		    OptionDataCompression
--select count(*)
FROM DOI.IndexRowStorePartitions
       )



GO
