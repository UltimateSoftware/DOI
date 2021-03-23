
IF OBJECT_ID('[DOI].[vwForeignKeys]') IS NOT NULL
	DROP VIEW [DOI].[vwForeignKeys];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   VIEW [DOI].[vwForeignKeys]

/*
    select * from DOI.vwForeignKeys
    
*/

AS

SELECT  FK.*,
        ('
USE ' + DatabaseName + ';
ALTER TABLE ' + FK.DatabaseName + '.' + ParentSchemaName + '.[' + ParentTableName + '] WITH NOCHECK ADD 
	CONSTRAINT ' + 'FK_' + ParentTableName + '_' + ReferencedTableName + '_' + REPLACE(ParentColumnList_Desired, ',', '_') + ' 
	    FOREIGN KEY (' + ParentColumnList_Desired + ') 
	    	REFERENCES ' + FK.DatabaseName + '.' + ReferencedSchemaName + '.[' + ReferencedTableName + '](' + ParentColumnList_Desired + ')') 
AS CreateFKSQL,
		('
USE ' + DatabaseName + ';
IF NOT EXISTS(  SELECT ''True''
                FROM DOI.SysForeignKeys fku
                    INNER JOIN DOI.SysForeignKeys fks ON fk.parent_object_id = pt.object_id
                WHERE fku.ParentSchemaName = ''' + ParentSchemaName + '''
                    AND fku.ParentTableName = ''' + ParentTableName + '''
                    AND fku.ReferencedSchemaName = ''' + ReferencedSchemaName + '''
                    AND fku.ReferencedTableName = ''' + ReferencedTableName + '''
                    AND fku.ParentColumnList_Desired = ''' + ParentColumnList_Desired + '''
                    AND fku.ReferencedColumnList_Desired = ''' + ReferencedColumnList_Desired + ''')
    AND EXISTS( SELECT ''True''
                FROM DOI.SysTables t
                    INNER JOIN DOI.SysDatabases d ON d.database_id = t.database_id
                    INNER JOIN DOI.SysSchemas s ON t.schema_id = s.schema_id
                WHERE d.name = ''' + DatabaseName + '''
                    AND s.name = ''' + ParentSchemaName + '''
                    AND t.name = ''' + ParentTableName + ''')
    AND EXISTS( SELECT ''True''
                FROM DOI.SysTables t
                    INNER JOIN DOI.SysDatabases d ON d.database_id = t.database_id
                    INNER JOIN DOI.SysSchemas s ON t.schema_id = s.schema_id
                WHERE d.name = ''' + DatabaseName + '''
                    AND s.name = ''' + ReferencedSchemaName + '''
                    AND t.name = ''' + ReferencedTableName + ''')
BEGIN
    ALTER TABLE ' + FK.DatabaseName + '.' + ParentSchemaName + '.[' + ParentTableName + '] WITH NOCHECK ADD 
	    CONSTRAINT ' + 'FK_' + ParentTableName + '_' + ReferencedTableName + '_' + REPLACE(ParentColumnList_Desired, ',', '_') + ' 
	    	FOREIGN KEY (' + ParentColumnList_Desired + ') 
	    		REFERENCES ' + ReferencedSchemaName + '.[' + ReferencedTableName + '](' + ReferencedColumnList_Desired + ')
END') AS CreateFKWithExistenceCheckSQL,
        ('
USE ' + DatabaseName + ';
IF EXISTS(  SELECT ''True''
            FROM DOI.SysForeignKeys fku
                INNER JOIN DOI.SysForeignKeys fks ON fk.parent_object_id = pt.object_id
            WHERE fku.ParentSchemaName = ''' + ParentSchemaName + '''
                AND fku.ParentTableName = ''' + ParentTableName + '''
                AND fku.ReferencedSchemaName = ''' + ReferencedSchemaName + '''
                AND fku.ReferencedTableName = ''' + ReferencedTableName + '''
                AND fku.ParentColumnList_Desired = ''' + ParentColumnList_Desired + '''
                AND fku.ReferencedColumnList_Desired = ''' + ReferencedColumnList_Desired + ''')
    AND EXISTS( SELECT ''True''
                FROM DOI.SysTables t
                    INNER JOIN DOI.SysDatabases d ON d.database_id = t.database_id
                    INNER JOIN DOI.SysSchemas s ON t.schema_id = s.schema_id
                WHERE d.name = ''' + DatabaseName + '''
                    AND s.name = ''' + ParentSchemaName + '''
                    AND t.name = ''' + ParentTableName + ''')
    AND EXISTS( SELECT ''True''
                FROM DOI.SysTables t
                    INNER JOIN DOI.SysDatabases d ON d.database_id = t.database_id
                    INNER JOIN DOI.SysSchemas s ON t.schema_id = s.schema_id
                WHERE d.name = ''' + DatabaseName + '''
                    AND s.name = ''' + ReferencedSchemaName + '''
                    AND t.name = ''' + ReferencedTableName + ''')
BEGIN
    ALTER TABLE ' + FK.DatabaseName + '.' + ParentSchemaName + '.[' + ParentTableName + '] DROP CONSTRAINT ' + 'FK_' + ParentTableName + '_' + ReferencedTableName + '_' + REPLACE(ParentColumnList_Desired, ',', '_') + '
END') AS DropFKSQL,
	   ('
USE ' + DatabaseName + ';
ALTER TABLE ' + FK.DatabaseName + '.' + ParentSchemaName + '.[' + ParentTableName + '] NOCHECK CONSTRAINT FK_' + ParentTableName + '_' + ReferencedTableName + '_' + REPLACE(ParentColumnList_Desired, ',', '_')) 
AS DisableFKSQL

FROM DOI.ForeignKeys FK

GO