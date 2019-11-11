IF OBJECT_ID('[DDI].[spRefreshMetadata_System_SysForeignKeys_UpdateData]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_System_SysForeignKeys_UpdateData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_System_SysForeignKeys_UpdateData]
AS

UPDATE FKS
SET FKS.ParentColumnList_Actual = STUFF(FKParentColumnList,LEN(FKParentColumnList),1,''),
    FKS.ReferencedColumnList_Actual = STUFF(FKReferencedColumnList,LEN(FKReferencedColumnList),1,''),
    FKS.DeploymentTime =     CASE 
                                WHEN ptu.IsStorageChanging = 1
                                THEN 'Job'
                                ELSE 'Deployment'
                            END 
--SELECT pts.name,ptu.*
FROM DDI.SysForeignKeys FKS
    INNER JOIN DDI.SysDatabases d ON d.database_id = FKS.database_id
    INNER JOIN DDI.SysTables pts ON pts.database_id = d.database_id
        AND FKS.parent_object_id = pts.object_id
    INNER JOIN DDI.SysSchemas s ON pts.schema_id = s.schema_id
    INNER JOIN DDI.Tables ptu ON d.name = ptu.DatabaseName
        AND ptu.SchemaName = s.name
        AND pts.name = ptu.TableName
    CROSS APPLY (	SELECT c.name + ',' 
					FROM DDI.SysForeignKeyColumns FKC
						INNER JOIN DDI.SysColumns c ON FKC.parent_object_id = c.object_id
							AND FKC.parent_column_id = c.column_id
					WHERE FKC.constraint_object_id = FKS.object_id 
                    ORDER BY FKC.constraint_column_id ASC
					FOR XML PATH('')) FKParentColumns(FKParentColumnList)
    CROSS APPLY (	SELECT c.name + ',' 
					FROM DDI.SysForeignKeyColumns FKC
						INNER JOIN DDI.SysColumns c ON FKC.referenced_object_id = c.object_id
							AND FKC.parent_column_id = c.column_id
					WHERE FKC.constraint_object_id = FKS.object_id 
                    ORDER BY FKC.constraint_column_id ASC
					FOR XML PATH('')) FKReferencedColumns(FKReferencedColumnList)
    --INNER JOIN Utility.Tables T2 ON S.NAME = T2.SchemaName
    --    AND T.NAME = T2.TableName


GO
