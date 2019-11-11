IF OBJECT_ID('[DDI].[fnIndexPartitionAgg]') IS NOT NULL
	DROP FUNCTION [DDI].[fnIndexPartitionAgg];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   FUNCTION [DDI].[fnIndexPartitionAgg]()   

RETURNS TABLE 
WITH NATIVE_COMPILATION, SCHEMABINDING 
 
AS   

/*
    SELECT * FROM DDI.fnIndexPartitionAgg()   
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
FROM DDI.IndexRowStorePartitions
       )



GO
