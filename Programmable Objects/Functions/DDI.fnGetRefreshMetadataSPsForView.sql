IF OBJECT_ID('[DDI].[fnGetRefreshMetadataSPsForView]') IS NOT NULL
	DROP FUNCTION [DDI].[fnGetRefreshMetadataSPsForView];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   FUNCTION [DDI].[fnGetRefreshMetadataSPsForView](@ViewName SYSNAME)

RETURNS TABLE

AS 

/*
    SELECT * FROM DDI.fnGetRefreshMetadataSPsForView('vwPartitionFunctionPartitions')
*/
RETURN
(
    WITH Anchor AS (
    SELECT  ReferencingObjects.name AS ReferencingObjectName, 
            CAST(d.referenced_schema_name + '.' + d.referenced_entity_name AS SYSNAME) AS ReferencedObjectName,
            ReferencedObjects.TYPE AS ReferencedObjectType,
            0 AS Level
    FROM sys.sql_expression_dependencies d
        INNER JOIN sys.objects ReferencingObjects ON d.referencing_id = ReferencingObjects.object_id
        INNER JOIN sys.objects ReferencedObjects ON d.referenced_id = ReferencedObjects.object_id
    WHERE ReferencingObjects.name = @ViewName
        AND ReferencedObjects.type = 'U'
    UNION ALL
    SELECT  CAST(d.referenced_schema_name + '.' + d.referenced_entity_name AS SYSNAME) AS ReferencedObjectName,
            ReferencingSP.name, 
            ReferencingSP.TYPE AS ReferencedObjectType,
            a.Level + 1
    FROM sys.objects ReferencingSP
        INNER JOIN sys.sql_expression_dependencies d ON ReferencingSP.object_id = d.referencing_id
        INNER JOIN Anchor a ON a.ReferencedObjectName = d.referenced_schema_name + '.' + d.referenced_entity_name
    WHERE ReferencingSP.TYPE = 'P'
        AND ReferencingSP.name LIKE 'spRefreshMetadata%')

    SELECT DISTINCT Anchor.ReferencedObjectName
    FROM Anchor
    WHERE Anchor.ReferencedObjectType = 'P'
)
GO
