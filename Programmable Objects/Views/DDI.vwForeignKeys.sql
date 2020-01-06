IF OBJECT_ID('[DDI].[vwForeignKeys]') IS NOT NULL
	DROP VIEW [DDI].[vwForeignKeys];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   VIEW [DDI].[vwForeignKeys]

/*
    select * from DDI.vwForeignKeys
    
*/

AS

SELECT  FK.*,
		('FK_' + ParentTableName + '_' + ReferencedTableName + '_' + REPLACE(FK.ParentColumnList_Desired, ',', '_')) AS FKName,
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
                FROM DDI.SysForeignKeys fku
                    INNER JOIN DDI.SysForeignKeys fks ON fk.parent_object_id = pt.object_id
                WHERE fku.ParentSchemaName = ''' + ParentSchemaName + '''
                    AND fku.ParentTableName = ''' + ParentTableName + '''
                    AND fku.ReferencedSchemaName = ''' + ReferencedSchemaName + '''
                    AND fku.ReferencedTableName = ''' + ReferencedTableName + '''
                    AND fku.ParentColumnList_Desired = ''' + ParentColumnList_Actual + '''
                    AND fku.ReferencedColumnList_Desired = ''' + ReferencedColumnList_Actual + ''')
    AND EXISTS( SELECT ''True''
                FROM DDI.SysTables t
                    INNER JOIN DDI.SysDatabases d ON d.database_id = t.database_id
                    INNER JOIN DDI.SysSchemas s ON t.schema_id = s.schema_id
                WHERE d.name = ''' + DatabaseName + '''
                    AND s.name = ''' + ParentSchemaName + '''
                    AND t.name = ''' + ParentTableName + ''')
    AND EXISTS( SELECT ''True''
                FROM DDI.SysTables t
                    INNER JOIN DDI.SysDatabases d ON d.database_id = t.database_id
                    INNER JOIN DDI.SysSchemas s ON t.schema_id = s.schema_id
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
            FROM DDI.SysForeignKeys fku
                INNER JOIN DDI.SysForeignKeys fks ON fk.parent_object_id = pt.object_id
            WHERE fku.ParentSchemaName = ''' + ParentSchemaName + '''
                AND fku.ParentTableName = ''' + ParentTableName + '''
                AND fku.ReferencedSchemaName = ''' + ReferencedSchemaName + '''
                AND fku.ReferencedTableName = ''' + ReferencedTableName + '''
                AND fku.ParentColumnList_Desired = ''' + ParentColumnList_Actual + '''
                AND fku.ReferencedColumnList_Desired = ''' + ReferencedColumnList_Actual + ''')
    AND EXISTS( SELECT ''True''
                FROM DDI.SysTables t
                    INNER JOIN DDI.SysDatabases d ON d.database_id = t.database_id
                    INNER JOIN DDI.SysSchemas s ON t.schema_id = s.schema_id
                WHERE d.name = ''' + DatabaseName + '''
                    AND s.name = ''' + ParentSchemaName + '''
                    AND t.name = ''' + ParentTableName + ''')
    AND EXISTS( SELECT ''True''
                FROM DDI.SysTables t
                    INNER JOIN DDI.SysDatabases d ON d.database_id = t.database_id
                    INNER JOIN DDI.SysSchemas s ON t.schema_id = s.schema_id
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


FROM DDI.ForeignKeys FK
    --OUTER APPLY (   SELECT  CASE 
				--		  WHEN ISNULL(NewPf.name, '') <> ISNULL(ExistingPf.name, '') 
				--			 AND TTP.IntendToPartition = 1 
				--		  THEN 1 
				--		  ELSE 0 
				--	   END AS IsPartitioningChanging
    --                FROM DDI.Tables TTP
				--    INNER JOIN ' + DatabaseName + '.sys.schemas s ON TTP.SchemaName = s.name
				--    INNER JOIN ' + DatabaseName + '.sys.tables t ON s.schema_id = t.schema_id
				--	   AND t.name = TTP.TableName
				--    INNER JOIN ' + DatabaseName + '.sys.indexes i ON i.object_id = t.object_id
				--    INNER JOIN DDI.IndexesRowStore IRS ON s.name = IRS.SchemaName
				--	   AND t.name = IRS.TableName
				--	   AND i.name = IRS.IndexName 
				--    INNER JOIN (SELECT name AS ExistingStorage, data_space_id, type_desc COLLATE DATABASE_DEFAULT AS ExistingStorageType
				--			 FROM ' + DatabaseName + '.sys.data_spaces) ExistingDS 
				--	   ON ExistingDS.data_space_id = I.data_space_id
				--    INNER JOIN (SELECT name AS NewStorage, data_space_id, type_desc COLLATE DATABASE_DEFAULT AS NewStorageType
				--			 FROM ' + DatabaseName + '.sys.data_spaces) NewDS 
				--	   ON NewDS.NewStorage = IRS.NewStorage
				--    LEFT JOIN ' + DatabaseName + '.sys.partition_schemes ExistingPs ON ExistingDS.ExistingStorage = ExistingPs.name
				--    LEFT JOIN ' + DatabaseName + '.sys.partition_functions ExistingPf ON ExistingPs.function_id = ExistingPf.function_id
				--    LEFT JOIN ' + DatabaseName + '.sys.partition_schemes NewPs ON NewPs.name = NewDS.NewStorage
				--    LEFT JOIN ' + DatabaseName + '.sys.partition_functions NewPf ON NewPf.function_id = NewPs.function_id
    --                WHERE s.name = FK.ParentSchemaName
    --                    AND t.name = FK.ParentTableName
    --                    AND s.name  <> 'DDI'
    --                    AND (ISNULL(NewPf.name, '') <> ISNULL(ExistingPf.name, '')))ipc2



GO
