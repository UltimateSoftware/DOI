
GO

IF OBJECT_ID('[DOI].[spQueue_ConstraintsNotInMetadata]') IS NOT NULL
	DROP PROCEDURE [DOI].[spQueue_ConstraintsNotInMetadata];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [DOI].[spQueue_ConstraintsNotInMetadata]
	@DatabaseName NVARCHAR(128) = NULL

AS

/*
	EXEC DOI.spQueue_ConstraintsNotInMetadata

	SELECT * FROM DOI.DefaultConstraints
*/

DELETE DOI.CheckConstraintsNotInMetadata
WHERE DatabaseName = CASE WHEN @DatabaseName IS NULL THEN DatabaseName ELSE @DatabaseName END 

DELETE DOI.DefaultConstraintsNotInMetadata
WHERE DatabaseName = CASE WHEN @DatabaseName IS NULL THEN DatabaseName ELSE @DatabaseName END 

INSERT INTO DOI.CheckConstraintsNotInMetadata ( DatabaseName, SchemaName ,TableName ,ColumnName , CheckDefinition ,IsDisabled ,CheckConstraintName )
SELECT d.name, s.name, t.name, c.name, ch.definition, ch.is_disabled, ch.name
FROM DOI.SysCheckConstraints ch
    INNER JOIN DOI.SysDatabases d ON d.database_id = ch.database_id 
	INNER JOIN DOI.SysSchemas s ON s.schema_id = ch.schema_id
	INNER JOIN (SELECT	name, 
						object_id 
				FROM DOI.SysTables) t ON t.object_id = ch.parent_object_id
	LEFT JOIN DOI.SysColumns c ON c.object_id = t.object_id
		AND ch.parent_column_id = c.column_id
WHERE t.name NOT LIKE '%|_OLD' ESCAPE '|'
	AND t.name NOT IN ('DBDefragLog')
	AND NOT EXISTS (SELECT 'True' 
					FROM DOI.CheckConstraints CC 
					WHERE s.name = cc.SchemaName COLLATE DATABASE_DEFAULT
						AND t.name = cc.TableName COLLATE DATABASE_DEFAULT 
						AND ch.name = cc.CheckConstraintName COLLATE DATABASE_DEFAULT)
	AND NOT EXISTS(	SELECT 'True' 
					FROM DOI.CheckConstraintsNotInMetadata CH2 
					WHERE s.Name = CH2.SchemaName COLLATE DATABASE_DEFAULT
						AND t.Name = CH2.TableName COLLATE DATABASE_DEFAULT 
						AND ch.NAME = CH2.CheckConstraintName COLLATE DATABASE_DEFAULT)
	AND d.name = CASE WHEN @DatabaseName IS NULL THEN d.name ELSE @DatabaseName END 
																		
INSERT INTO DOI.DefaultConstraintsNotInMetadata ( DatabaseName, SchemaName ,TableName ,ColumnName ,DefaultDefinition )
SELECT d.name, s.name, t.name, c.name, df.definition
FROM DOI.SysDefaultConstraints df 
    INNER JOIN DOI.SysDatabases d ON d.database_id = df.database_id 
	INNER JOIN DOI.SysSchemas s ON s.database_id = df.database_id
		AND s.schema_id = df.schema_id
	INNER JOIN (SELECT	database_id,
						name , 
						object_id 
				FROM DOI.SysTables) t ON t.database_id = df.database_id
		AND t.object_id = df.parent_object_id
	INNER JOIN DOI.SysColumns c ON c.database_id = t.database_id
		AND c.object_id = t.object_id
		AND df.parent_column_id = c.column_id
WHERE t.name NOT LIKE '%|_OLD' ESCAPE '|'
	AND t.name NOT IN ('DBDefragLog')
	AND NOT EXISTS (SELECT 'True' 
					FROM DOI.DefaultConstraints CC 
					WHERE d.name = CC.DatabaseName
						AND s.name = cc.SchemaName COLLATE DATABASE_DEFAULT 
						AND t.name = cc.TableName COLLATE DATABASE_DEFAULT 
						AND df.name = cc.DefaultConstraintName COLLATE DATABASE_DEFAULT)
	AND NOT EXISTS(	SELECT 'True' 
					FROM DOI.DefaultConstraintsNotInMetadata D2 
					WHERE d.name = d2.DatabaseName
						AND s.Name = D2.SchemaName COLLATE DATABASE_DEFAULT 
						AND t.Name = D2.TableName COLLATE DATABASE_DEFAULT 
						AND c.Name = D2.ColumnName COLLATE DATABASE_DEFAULT )--check definition here as well.
	AND d.name = CASE WHEN @DatabaseName IS NULL THEN d.name ELSE @DatabaseName END 
GO