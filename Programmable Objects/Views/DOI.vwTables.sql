

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