IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysForeignKeys_CreateTables]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysForeignKeys_CreateTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysForeignKeys_CreateTables]
AS

DECLARE @DropSQL VARCHAR(MAX) = '',
        @RecreateSQL VARCHAR(MAX) = ''

EXEC DOI.spDropRecreateSchemaBoundObjectsOnTable
    @SchemaName = 'DOI',
    @TableName = 'SysForeignKeys',
    @DropSQL = @DropSQL OUTPUT,
    @RecreateSQL = @RecreateSQL OUTPUT

EXEC DOI.sp_ExecuteSQLByBatch @DropSQL

DROP TABLE IF EXISTS #SysForeignKeys

DROP TABLE IF EXISTS DOI.SysForeignKeys


CREATE TABLE DOI.SysForeignKeys (
    database_id INT NOT null,
    name	sysname,
    object_id	int NOT NULL,
    principal_id	int	NULL,
    schema_id	int	NOT NULL,
    parent_object_id	int	NOT NULL,
    type	char(2) NULL,
    type_desc	nvarchar(120) NULL,
    create_date	datetime NOT NULL,
    modify_date	datetime NOT NULL,
    is_ms_shipped	bit NOT NULL,
    is_published	bit NOT NULL,
    is_schema_published	bit NOT NULL,
    referenced_object_id	int NULL,
    key_index_id	int NULL,
    is_disabled	bit NOT NULL,
    is_not_for_replication	bit NOT NULL,
    is_not_trusted	bit NOT NULL,
    delete_referential_action	tinyint NULL,
    delete_referential_action_desc	nvarchar(120) NULL,
    update_referential_action	tinyint NULL,
    update_referential_action_desc	nvarchar(120) NULL,
    is_system_named	bit NOT NULL,
    ParentColumnList_Actual VARCHAR(MAX) NULL,
    ReferencedColumnList_Actual VARCHAR(MAX) NULL,
    DeploymentTime VARCHAR(10) NULL
        CONSTRAINT Chk_SysForeignKeys_DeploymentTime
            CHECK (DeploymentTime IN ('Job', 'Deployment')),
    
    CONSTRAINT PK_SysForeignKeys
        PRIMARY KEY NONCLUSTERED (database_id, name)/*,
    CONSTRAINT UQ_SysForeignKeys
        UNIQUE NONCLUSTERED (database_id, parent_object_id, ParentColumnList_Actual, referenced_object_id, ReferencedColumnList_Actual)*/
    )

    WITH (MEMORY_OPTIMIZED = ON)

--SELECT database_id, parent_object_id, ParentColumnList_Actual, referenced_object_id, ReferencedColumnList_Actual, COUNT(*)
--FROM DOI.SysForeignKeys
--GROUP BY database_id, parent_object_id, ParentColumnList_Actual, referenced_object_id, ReferencedColumnList_Actual
--HAVING COUNT(*) > 1
GO
