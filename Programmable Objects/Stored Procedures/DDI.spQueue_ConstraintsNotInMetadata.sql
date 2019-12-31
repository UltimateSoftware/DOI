IF OBJECT_ID('[DDI].[spQueue_ConstraintsNotInMetadata]') IS NOT NULL
	DROP PROCEDURE [DDI].[spQueue_ConstraintsNotInMetadata];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [DDI].[spQueue_ConstraintsNotInMetadata]

AS

/*
	EXEC DDI.spQueue_ConstraintsNotInMetadata

	SELECT * FROM DDI.DefaultConstraints
*/

DELETE DDI.CheckConstraintsNotInMetadata
DELETE DDI.DefaultConstraintsNotInMetadata

INSERT INTO DDI.CheckConstraintsNotInMetadata ( DatabaseName, SchemaName ,TableName ,ColumnName , CheckDefinition ,IsDisabled ,CheckConstraintName )
SELECT d.name, s.name, t.name, c.name, ch.definition, ch.is_disabled, ch.name
FROM DDI.SysCheckConstraints ch
    INNER JOIN DDI.SysDatabases d ON d.database_id = ch.database_id 
	INNER JOIN DDI.SysSchemas s ON s.schema_id = ch.schema_id
	INNER JOIN (SELECT	name, 
						object_id 
				FROM DDI.SysTables) t ON t.object_id = ch.parent_object_id
	LEFT JOIN DDI.SysColumns c ON c.object_id = t.object_id
		AND ch.parent_column_id = c.column_id
WHERE t.name NOT LIKE '%|_OLD' ESCAPE '|'
	AND t.name NOT IN ('DBDefragLog')
	AND NOT EXISTS (SELECT 'True' 
					FROM DDI.CheckConstraints CC 
					WHERE s.name = cc.SchemaName COLLATE DATABASE_DEFAULT
						AND t.name = cc.TableName COLLATE DATABASE_DEFAULT 
						AND ch.name = cc.CheckConstraintName COLLATE DATABASE_DEFAULT)
	AND NOT EXISTS(	SELECT 'True' 
					FROM DDI.CheckConstraintsNotInMetadata CH2 
					WHERE s.Name = CH2.SchemaName COLLATE DATABASE_DEFAULT
						AND t.Name = CH2.TableName COLLATE DATABASE_DEFAULT 
						AND ch.NAME = CH2.CheckConstraintName COLLATE DATABASE_DEFAULT)
																		
INSERT INTO DDI.DefaultConstraintsNotInMetadata ( DatabaseName, SchemaName ,TableName ,ColumnName ,DefaultDefinition )
SELECT d2.name, s.name, t.name, c.name, d.definition
FROM DDI.SysDefaultConstraints d 
    INNER JOIN DDI.SysDatabases d2 ON d2.database_id = d.database_id 
	INNER JOIN DDI.SysSchemas s ON s.schema_id = d.schema_id
	INNER JOIN (SELECT	name , 
						object_id 
				FROM DDI.SysTables) t ON t.object_id = d.parent_object_id
	INNER JOIN DDI.SysColumns c ON c.object_id = t.object_id
		AND d.parent_column_id = c.column_id
WHERE t.name NOT LIKE '%|_OLD' ESCAPE '|'
	AND t.name NOT IN ('DBDefragLog')
	AND NOT EXISTS (SELECT 'True' 
					FROM DDI.DefaultConstraints CC 
					WHERE s.name = cc.SchemaName COLLATE DATABASE_DEFAULT 
						AND t.name = cc.TableName COLLATE DATABASE_DEFAULT 
						AND d.name = cc.DefaultConstraintName COLLATE DATABASE_DEFAULT)
	AND NOT EXISTS(	SELECT 'True' 
					FROM DDI.DefaultConstraintsNotInMetadata D2 
					WHERE s.Name = D2.SchemaName COLLATE DATABASE_DEFAULT 
						AND t.Name = D2.TableName COLLATE DATABASE_DEFAULT 
						AND c.Name = D2.ColumnName COLLATE DATABASE_DEFAULT )--check definition here as well.
GO
