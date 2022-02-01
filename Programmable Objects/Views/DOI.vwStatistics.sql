
GO

IF OBJECT_ID('[DOI].[vwStatistics]') IS NOT NULL
	DROP VIEW [DOI].[vwStatistics];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE   VIEW [DOI].[vwStatistics]
AS 

/*
    select * from DOI.vwStatistics
*/
SELECT  *,         
        '
UPDATE STATISTICS ' + S.DatabaseName + '.' + S.SchemaName + '.' + S.TableName + '(' + S.StatisticsName + ') 
WITH SAMPLE ' + CAST(S.SampleSizePct_Desired AS VARCHAR(3)) + ' PERCENT
    /*, PERSIST_SAMPLE_PERCENT = ON  this has to wait until 2016 SP2.
    , MAXDOP = 0*/
' + CASE WHEN S.NoRecompute_Desired = 1 THEN ', NORECOMPUTE' ELSE '' END +
', INCREMENTAL = ' + CASE WHEN S.IsIncremental_Desired = 1 THEN 'ON' ELSE 'OFF' END 
AS UpdateStatisticsSQL,
                '
IF NOT EXISTS(SELECT ''True'' FROM ' + S.DatabaseName + '.sys.stats WHERE NAME = ''' + S.StatisticsName + ''')
BEGIN
    CREATE STATISTICS ' + S.StatisticsName + '
    ON ' + S.DatabaseName + '.' + S.SchemaName + '.' + S.TableName + '(' + S.StatisticsColumnList_Desired + ')' + 
        CASE 
            WHEN S.IsFiltered_Desired = 1 
            THEN '
    WHERE ' + S.FilterPredicate_Desired
            ELSE '' 
        END + '
    WITH SAMPLE ' + CAST(S.SampleSizePct_Desired AS VARCHAR(3)) + ' PERCENT
        /*, PERSIST_SAMPLE_PERCENT = ON  this has to wait until 2016 SP2.
        , MAXDOP = 0*/
    ' + CASE WHEN S.NoRecompute_Desired = 1 THEN ', NORECOMPUTE' ELSE '' END +
    ', INCREMENTAL = ' + CASE WHEN S.IsIncremental_Desired = 1 THEN 'ON' ELSE 'OFF' END + '
END' 
AS CreateStatisticsSQL,
        '
DROP STATISTICS ' + S.TableName + '.' + S.StatisticsName 
AS DropStatisticsSQL,
        '
DROP STATISTICS ' + S.TableName + '.' + S.StatisticsName  + '

IF NOT EXISTS(SELECT ''True'' FROM ' + S.DatabaseName + '.sys.stats WHERE NAME = ''' + S.StatisticsName + ''')
BEGIN
    CREATE STATISTICS ' + S.StatisticsName + '
    ON ' + S.DatabaseName + '.' + S.SchemaName + '.' + S.TableName + '(' + S.StatisticsColumnList_Desired + ')' + 
        CASE 
            WHEN S.IsFiltered_Desired = 1 
            THEN '
    WHERE ' + S.FilterPredicate_Desired
            ELSE '' 
        END + '
    WITH SAMPLE ' + CAST(S.SampleSizePct_Desired AS VARCHAR(3)) + ' PERCENT
        /*, PERSIST_SAMPLE_PERCENT = ON  this has to wait until 2016 SP2.
        , MAXDOP = 0*/
    ' + CASE WHEN S.NoRecompute_Desired = 1 THEN ', NORECOMPUTE' ELSE '' END +
    ', INCREMENTAL = ' + CASE WHEN S.IsIncremental_Desired = 1 THEN 'ON' ELSE 'OFF' END + '
END' 
AS DropReCreateStatisticsSQL,
        '  
IF EXISTS ( SELECT ''True''
    FROM SYS.stats st 
        INNER JOIN SYS.TABLES t ON t.object_id = st.object_id 
        INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    WHERE s.name = ''' + S.SchemaName + '''
        AND t.name = ''' + S.TableName + '''
        AND st.name = ''' + S.StatisticsName  + ''')
BEGIN
    EXEC sys.sp_rename 
        @objname = N''' + S.SchemaName + '.' + S.TableName + '.' + S.StatisticsName + ''', 
        @newname = N''ST_' + S.TableName + '_OLD_' + S.StatisticsColumnList_Actual + ''', 
        @objtype = N''STATISTICS''
END' AS RenameStatisticsSQL,  --only the ST_ statistics are being renamed here...the stats belonging to indexes are renamed along with the index.
        '
IF EXISTS ( SELECT ''True''
            FROM ' + S.DatabaseName + '.SYS.stats st 
                INNER JOIN ' + S.DatabaseName + '.SYS.TABLES t ON t.object_id = st.object_id 
                INNER JOIN ' + S.DatabaseName + '.sys.schemas s ON s.schema_id = t.schema_id
            WHERE s.name = ''' + S.SchemaName + '''
                AND t.name = ''' + S.TableName + '''
                AND st.name = ''ST_' + S.TableName + '_OLD_' + S.StatisticsColumnList_Actual + ''')
BEGIN
    SET DEADLOCK_PRIORITY 10
    EXEC ' + S.DatabaseName + '.sys.sp_rename 
        @objname = ''' + S.SchemaName + '.' + S.TableName + '.ST_' + S.TableName + '_OLD_' + S.StatisticsColumnList_Actual + '''
        ,@newname = ''' + S.StatisticsName + '''
        ,@objtype = ''STATISTICS''
END' AS RevertRenameStatisticsSQL,
'
EXEC DOI.spRun_GetApplicationLock
    @DatabaseName = ''' + S.DatabaseName + ''',
    @BatchId = ''00000000-0000-0000-0000-000000000000''
' AS GetApplicationLockSQL,
'
EXEC DOI.spRun_ReleaseApplicationLock
    @DatabaseName = ''' + S.DatabaseName + ''',
    @BatchId = ''00000000-0000-0000-0000-000000000000''
' AS ReleaseApplicationLockSQL,
        '
DECLARE @ErrorMessage NVARCHAR(500),
        @DataSpaceNeeded BIGINT,
        @DataSpaceAvailable BIGINT,
        @DriveLetter CHAR(1)  

SELECT @DataSpaceAvailable = available_MB, 
        @DataSpaceNeeded = FSI.SpaceNeededOnDrive,
        @DriveLetter = FS.DriveLetter
FROM DOI.vwFreeSpaceOnDisk FS
    INNER JOIN DOI.fnFreeSpaceNeededForTableIndexOperations(''' + S.DatabaseName + ''', ''' + S.SchemaName + ''', ''' + S.TableName + ''', ''data'') FSI ON FSI.DriveLetter = FS.DriveLetter
WHERE DBName = ''' + S.DatabaseName + '''
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
    INNER JOIN DOI.fnFreeSpaceNeededForTableIndexOperations(''' + S.DatabaseName + ''', ''' + S.SchemaName + ''', ''' + S.TableName + ''', ''log'') FSI ON FSI.DriveLetter = FS.DriveLetter
WHERE DBName = ''' + S.DatabaseName + '''
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
    INNER JOIN DOI.fnFreeSpaceNeededForTableIndexOperations(''' + S.DatabaseName + ''', ''' + S.SchemaName + ''', ''' + S.TableName + ''', ''TempDB'') FSI ON FSI.DriveLetter = FS.DriveLetter
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

FROM DOI.[Statistics] S





GO
