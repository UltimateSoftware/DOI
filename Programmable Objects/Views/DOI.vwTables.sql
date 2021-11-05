

IF OBJECT_ID('[DOI].[vwTables]') IS NOT NULL
	DROP VIEW [DOI].[vwTables];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   VIEW [DOI].[vwTables]

AS

/*
    SELECT * FROM DOI.vwTables
*/

SELECT	T.*,
'
CREATE OR ALTER TRIGGER ' + T.SchemaName + '.tr' + T.TableName + '_DataSynch
ON ' + T.SchemaName + '.' + T.TableName + '
AFTER INSERT, UPDATE, DELETE
AS
' + 		DSTrigger.DSTriggerSQL AS CreateDataSynchTriggerSQL,

'IF OBJECT_ID(''' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch'') IS NOT NULL
BEGIN
	DROP TABLE ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch
END

IF OBJECT_ID(''' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch'') IS NULL
BEGIN
	CREATE TABLE ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch (' + CHAR(13) + CHAR(10) + T.ColumnListWithTypes + CHAR(13) + CHAR(10) + ' ,DMLType CHAR(1) NOT NULL) ON [' + T.Storage_Desired + '] (' + T.PartitionColumn + ')
END
'		AS CreateFinalDataSynchTableSQL,
		'
CREATE OR ALTER TRIGGER ' + T.SchemaName + '.tr' + T.TableName + '_DataSynch
ON ' + T.SchemaName + '.' + T.TableName + '
AFTER INSERT, UPDATE, DELETE
AS' + CASE WHEN T.TableHasIdentityColumn = 1 THEN '
SET IDENTITY_INSERT ' + T.SchemaName + '.' + T.TableName + '_DataSynch ON' + CHAR(13) + CHAR(10) ELSE '' END + '

INSERT INTO ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch (' + T.ColumnListForDataSynchTriggerInsert + ', DMLType)
SELECT ' + REPLACE(T.ColumnListForDataSynchTriggerSelect, 'PT.', 'ST.') + ', ''I''
FROM inserted T
' + CASE WHEN [TableHasOldBlobColumns] = 1 THEN '
	INNER JOIN ' + T.SchemaName + '.' + T.TableName + ' ST ON ' + REPLACE(T.PKColumnListJoinClause, 'PT.', 'ST.') + CHAR(13) + CHAR(10) ELSE '' END + '
WHERE NOT EXISTS(SELECT ''True'' FROM deleted PT WHERE ' + T.PKColumnListJoinClause + ')

INSERT INTO ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch (' + T.ColumnListForDataSynchTriggerInsert + ', DMLType)
SELECT ' + REPLACE(T.ColumnListForDataSynchTriggerSelect, 'PT.', 'ST.') + ', ''U''
FROM inserted T
' + CASE WHEN [TableHasOldBlobColumns] = 1 THEN '
	INNER JOIN ' + T.SchemaName + '.' + T.TableName + ' ST ON ' + REPLACE(T.PKColumnListJoinClause, 'PT.', 'ST.') + CHAR(13) + CHAR(10) ELSE '' END + '
WHERE EXISTS (SELECT * FROM deleted PT WHERE ' + T.PKColumnListJoinClause + ')

INSERT INTO ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch (' + T.ColumnListForDataSynchTriggerInsert + ', DMLType)
SELECT ' + REPLACE(T.ColumnListForDataSynchTriggerSelect, 'PT.', 'ST.') + ', ''D''
FROM deleted T
' + CASE WHEN [TableHasOldBlobColumns] = 1 THEN '
	INNER JOIN ' + T.SchemaName + '.' + T.TableName + ' ST ON ' + REPLACE(T.PKColumnListJoinClause, 'PT.', 'ST.') + CHAR(13) + CHAR(10) ELSE '' END + '
WHERE NOT EXISTS(SELECT ''True'' FROM inserted PT WHERE ' + T.PKColumnListJoinClause + ')
' + CASE WHEN T.TableHasIdentityColumn = 1 THEN '

SET IDENTITY_INSERT ' + T.SchemaName + '.' + T.TableName + '_DataSynch OFF' + CHAR(13) + CHAR(10) ELSE '' END		AS CreateFinalDataSynchTriggerSQL,

'UPDATE DOI.DOI.Run_PartitionState
SET DataSynchState = 0
WHERE DatabaseName = ''' + T.DatabaseName + '''
	AND SchemaName = ''' + T.SchemaName + '''
	AND ParentTableName = ''' + T.TableName + '''
'		AS TurnOffDataSynchSQL,

		'
USE ' + T.DatabaseName + '
IF EXISTS(SELECT * FROM sys.triggers tr WHERE tr.name = ''tr' + T.TableName + '_DataSynch'' AND OBJECT_NAME(parent_id) = ''' + T.TableName + '_OLD'')
BEGIN
	DROP TRIGGER tr' + T.TableName + '_DataSynch
END' 
		AS DropDataSynchTriggerSQL,

		'
IF OBJECT_ID(''' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch'') IS NOT NULL
	AND OBJECT_ID(''' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + ''') IS NOT NULL
BEGIN
	IF (SELECT SUM(Counts)
		FROM (
				SELECT ''Inserts Left'' AS Type, COUNT(*) AS Counts
				FROM ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch PT
				WHERE PT.DMLType = ''I''
					AND NOT EXISTS (SELECT ''True'' 
									FROM ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + ' T
									WHERE ' + T.PKColumnListJoinClause + ')
				UNION ALL
				SELECT ''Updates Left'' AS Type, COUNT(*)
				FROM ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch PT
				WHERE PT.DMLType = ''U''
					AND EXISTS (SELECT ''True'' 
								FROM ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + ' T
								WHERE ' + T.PKColumnListJoinClause + '
									AND T.UpdatedUtcDt < PT.UpdatedUtcDt)
				UNION ALL
				SELECT ''Deletes Left'' AS Type, COUNT(*)
				FROM ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch PT
				WHERE PT.DMLType = ''D''
					AND EXISTS (SELECT ''True'' 
								FROM ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + ' T
								WHERE ' + T.PKColumnListJoinClause + '))c) = 0
	BEGIN
		DROP TABLE ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch
	END
	ELSE
	BEGIN
		RAISERROR(''Not all data was synched to the new table.  ' + T.DatabaseName + '.' + T.SchemaName + '.' + T.TableName + '_DataSynch Table was not dropped'', 10, 1)
	END
END
ELSE
BEGIN
	RAISERROR(''Not all necessary tables have been created.'' , 16 , 1);
END'
AS DropDataSynchTableSQL,
'
DELETE DOI.DOI.Run_PartitionState 
WHERE DatabaseName = ''' + T.DatabaseName + '''
	AND SchemaName = ''' + T.SchemaName + ''' 
    AND ParentTableName = ''' + T.TableName + '''' 
AS DeletePartitionStateMetadataSQL,

        '
DECLARE @ErrorMessage NVARCHAR(500),
        @DataSpaceNeeded BIGINT,
        @DataSpaceAvailable BIGINT,
        @DriveLetter CHAR(1)  

SELECT @DataSpaceAvailable = available_MB, 
        @DataSpaceNeeded = FSI.SpaceNeededOnDrive,
        @DriveLetter = FS.DriveLetter
FROM DOI.vwFreeSpaceOnDisk FS
    INNER JOIN DOI.fnFreeSpaceNeededForTableIndexOperations(''' + T.DatabaseName + ''', ''' + T.SchemaName + ''', ''' + T.TableName + ''', ''data'') FSI ON FSI.DriveLetter = FS.DriveLetter
WHERE DBName = ''' + T.DatabaseName + '''
    AND FS.FileType = ''DATA''
    AND EXISTS(	SELECT ''True''
				FROM DOI.Queue Q 
				WHERE Q.DatabaseName = FSI.DatabaseName
					AND Q.ParentSchemaName = FSI.SchemaName
					AND Q.ParentTableName = FSI.TableName)

IF @DataSpaceAvailable <= @DataSpaceNeeded
BEGIN
    SET @ErrorMessage = ''NOT ENOUGH FREE SPACE ON DATA DRIVE '' + @DriveLetter + '':  TO REFRESH INDEX STRUCTURES.  NEED '' + CAST(@DataSpaceNeeded AS NVARCHAR(50)) + ''MB AND ONLY HAVE '' + CAST(@DataSpaceAvailable AS NVARCHAR(50)) + ''MB AVAILABLE.''
    
	RAISERROR(@ErrorMessage, 16, 1)
END
ELSE 
BEGIN
    SET @ErrorMessage = ''THERE IS ENOUGH FREE SPACE ON DATA DRIVE '' + @DriveLetter + '':  TO REFRESH INDEX STRUCTURES.  NEED '' + CAST(@DataSpaceNeeded AS NVARCHAR(50)) + ''MB AND HAVE '' + CAST(@DataSpaceAvailable AS NVARCHAR(50)) + ''MB AVAILABLE.''
    
	RAISERROR(@ErrorMessage, 10, 1)
END' AS FreeDataSpaceCheckSQL,

        '
DECLARE @ErrorMessage NVARCHAR(500),
        @LogSpaceNeeded BIGINT,
        @LogSpaceAvailable BIGINT,
        @DriveLetter CHAR(1)  

SELECT @LogSpaceAvailable = available_MB, 
        @LogSpaceNeeded = FSI.SpaceNeededOnDrive,
        @DriveLetter = FS.DriveLetter
FROM DOI.vwFreeSpaceOnDisk FS
    INNER JOIN DOI.fnFreeSpaceNeededForTableIndexOperations(''' + T.DatabaseName + ''', ''' + T.SchemaName + ''', ''' + T.TableName + ''', ''log'') FSI ON FSI.DriveLetter = FS.DriveLetter
WHERE DBName = ''' + T.DatabaseName + '''
    AND FS.FileType = ''LOG''
    AND EXISTS(	SELECT ''True''
				FROM DOI.Queue Q 
				WHERE Q.ParentSchemaName = FSI.SchemaName
					AND Q.ParentTableName = FSI.TableName)

IF @LogSpaceAvailable <= @LogSpaceNeeded
BEGIN
    SET @ErrorMessage = ''NOT ENOUGH FREE SPACE ON LOG DRIVE '' + @DriveLetter + '':  TO REFRESH INDEX STRUCTURES.  NEED '' + CAST(@LogSpaceNeeded AS NVARCHAR(50)) + ''MB AND ONLY HAVE '' + CAST(@LogSpaceAvailable AS NVARCHAR(50)) + ''MB AVAILABLE.''
    
	RAISERROR(@ErrorMessage, 16, 1)
END
ELSE 
BEGIN
    SET @ErrorMessage = ''THERE IS ENOUGH FREE SPACE ON LOG DRIVE '' + @DriveLetter + '':  TO REFRESH INDEX STRUCTURES.  NEED '' + CAST(@LogSpaceNeeded AS NVARCHAR(50)) + ''MB AND HAVE '' + CAST(@LogSpaceAvailable AS NVARCHAR(50)) + ''MB AVAILABLE.''
    
	RAISERROR(@ErrorMessage, 10, 1)
END
' AS FreeLogSpaceCheckSQL,

        '
DECLARE @ErrorMessage NVARCHAR(500),
        @TempDBSpaceNeeded BIGINT,
        @TempDBSpaceAvailable BIGINT,
        @DriveLetter CHAR(1)  

SELECT @TempDBSpaceAvailable = available_MB, 
        @TempDBSpaceNeeded = FSI.SpaceNeededOnDrive,
        @DriveLetter = FS.DriveLetter
FROM DOI.vwFreeSpaceOnDisk FS
    INNER JOIN DOI.fnFreeSpaceNeededForTableIndexOperations(''' + T.DatabaseName + ''', ''' + T.SchemaName + ''', ''' + T.TableName + ''', ''TempDB'') FSI ON FSI.DriveLetter = FS.DriveLetter
WHERE DBName = ''TempDB''
    AND FS.FileType = ''DATA''
    AND EXISTS(	SELECT ''True''
				FROM DOI.Queue Q 
				WHERE Q.ParentSchemaName = FSI.SchemaName
					AND Q.ParentTableName = FSI.TableName)

IF @TempDBSpaceAvailable <= @TempDBSpaceNeeded
BEGIN
    SET @ErrorMessage = ''NOT ENOUGH FREE SPACE ON TEMPDB DRIVE '' + @DriveLetter + '':  TO REFRESH INDEX STRUCTURES.  NEED '' + CAST(@TempDBSpaceNeeded AS NVARCHAR(50)) + ''MB AND ONLY HAVE '' + CAST(@TempDBSpaceAvailable AS NVARCHAR(50)) + ''MB AVAILABLE.''
    
	RAISERROR(@ErrorMessage, 16, 1)
END
ELSE 
BEGIN
    SET @ErrorMessage = ''THERE IS ENOUGH FREE SPACE ON TEMPDB DRIVE '' + @DriveLetter + '':  TO REFRESH INDEX STRUCTURES.  NEED '' + CAST(@TempDBSpaceNeeded AS NVARCHAR(50)) + ''MB AND HAVE '' + CAST(@TempDBSpaceAvailable AS NVARCHAR(50)) + ''MB AVAILABLE.''
    
	RAISERROR(@ErrorMessage, 10, 1)
END
' AS FreeTempDBSpaceCheckSQL
--select count(*)
FROM DOI.Tables T
	CROSS APPLY(SELECT STUFF((  SELECT PT.PrepTableTriggerSQLFragment
								FROM DOI.vwPartitioning_Tables_PrepTables PT
								WHERE PT.DatabaseName = T.DatabaseName
									AND PT.SchemaName = T.SchemaName
									AND PT.TableName = T.TableName
								FOR XML PATH(''), TYPE).value(N'.[1]', N'nvarchar(max)'), 1, 1, '')) DSTrigger(DSTriggerSQL)

GO