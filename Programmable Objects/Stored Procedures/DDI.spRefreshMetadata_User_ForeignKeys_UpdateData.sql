IF OBJECT_ID('[DDI].[spRefreshMetadata_User_ForeignKeys_UpdateData]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshMetadata_User_ForeignKeys_UpdateData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DDI].[spRefreshMetadata_User_ForeignKeys_UpdateData]
AS

UPDATE FKU
SET FKU.ParentColumnList_Actual = FKS.ParentColumnList_Actual,
    FKU.ReferencedColumnList_Actual = FKS.ReferencedColumnList_Actual,
    FKU.DeploymentTime =     CASE 
                                WHEN ptu.IsStorageChanging = 1
                                THEN 'Job'
                                ELSE 'Deployment'
                            END 
--SELECT count(*)
FROM DDI.ForeignKeys FKU
    INNER JOIN DDI.SysDatabases d ON d.name = FKU.DatabaseName
    INNER JOIN DDI.Tables ptu ON d.name = ptu.DatabaseName
        AND ptu.SchemaName = FKU.ParentSchemaName
        AND ptu.TableName = FKU.ParentTableName
    INNER JOIN DDI.Tables rtu ON d.name = rtu.DatabaseName
        AND rtu.SchemaName = FKU.ReferencedSchemaName
        AND rtu.TableName = FKU.ReferencedTableName
    INNER JOIN DDI.SysSchemas ps ON ps.name = ptu.SchemaName
    INNER JOIN DDI.SysSchemas rs ON rs.name = rtu.SchemaName
    INNER JOIN DDI.SysTables pts ON pts.database_id = d.database_id
        AND pts.schema_id = ps.schema_id
        AND pts.name = ptu.TableName
    INNER JOIN DDI.SysTables rts ON rts.database_id = d.database_id
        AND rts.schema_id = rs.schema_id
        AND rts.name = rtu.TableName
    INNER JOIN DDI.SysForeignKeys FKS ON FKS.database_id = d.database_id
        AND FKS.schema_id = pts.schema_id
        AND FKS.parent_object_id = pts.object_id
        AND FKS.referenced_object_id = rts.object_id
GO
