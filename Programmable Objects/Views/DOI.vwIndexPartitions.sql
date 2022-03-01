-- <Migration ID="33c471ac-2e70-44a8-b75c-23fd51fb8ab8" />
GO
-- WARNING: this script could not be parsed using the Microsoft.TrasactSql.ScriptDOM parser and could not be made rerunnable. You may be able to make this change manually by editing the script by surrounding it in the following sql and applying it or marking it as applied!

IF OBJECT_ID('[DOI].[vwIndexPartitions]') IS NOT NULL
	DROP VIEW [DOI].[vwIndexPartitions];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   VIEW [DOI].[vwIndexPartitions]
AS

/*
	SELECT * 
    FROM DOI.vwIndexPartitions 
    ORDER BY SchemaName, TableName, IndexName, PartitionNumber
*/
SELECT  CASE
            WHEN x.PartitionUpdateType IN ('AlterRebuild-PartitionLevel-Online', 'AlterReorganize-PartitionLevel')
            THEN 1
            WHEN x.PartitionUpdateType = 'AlterRebuild-PartitionLevel-Offline'
            THEN 0
        END AS IsOnlineOperation,
        *
FROM (
        SELECT	DatabaseName,
		        SchemaName,
		        TableName,
		        IndexName, 
		        PartitionNumber, 
		        TotalIndexPartitionSizeInMB, 
		        DataFileName, 
		        DriveLetter,
		        NumRows, 
		        TotalPages,
		        Fragmentation,
		        CASE
			        WHEN Fragmentation > 30
				        OR OptionDataCompression <> OptionDataCompression --certain options or frag over 30%.
			        THEN 'AlterRebuild-PartitionLevel-Online' --can be done on a partition level
			        WHEN (OptionDataCompression = OptionDataCompression)--NO OPTIONS CHANGES, 5-30% frag, needs LOB compaction
				        AND Fragmentation BETWEEN 5 AND 30
			        THEN 'AlterReorganize-PartitionLevel' --this always happens online, can be done on a partition level
			        ELSE 'None'
		        END AS PartitionUpdateType,
		        PartitionType,
		        OptionDataCompression,
		        '
        TRUNCATE TABLE ' + SchemaName + '.' + TableName + 'WITH (PARTITIONS (' + CAST(PartitionNumber AS VARCHAR(5)) + '))' AS TruncateStatement,
        'USE ' + DatabaseName + ';
        ALTER INDEX ' + IndexName + ' ON ' + SchemaName + '.' + TableName + CHAR(13) + CHAR(10) + 
        '	REBUILD PARTITION = ' + CAST(PartitionNumber AS VARCHAR(5)) + CHAR(13) + CHAR(10) + 
        '		WITH (	
				        SORT_IN_TEMPDB = ON,
				        ONLINE = ON(WAIT_AT_LOW_PRIORITY (MAX_DURATION = 0 MINUTES, ABORT_AFTER_WAIT = NONE)),
				        MAXDOP = 0,
				        DATA_COMPRESSION = ' + OptionDataCompression COLLATE DATABASE_DEFAULT + ')' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) 
        AS AlterRebuildStatement
				        ,'
        ALTER INDEX ' + IndexName + ' ON ' + SchemaName + '.' + TableName + CHAR(13) + CHAR(10) + 
        '	REORGANIZE PARTITION = ' + CAST(PartitionNumber AS VARCHAR(5)) + CHAR(13) + CHAR(10) + 
        '		WITH (	LOB_COMPACTION = ON)' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) AS AlterReorganizeStatement,
        '
        EXEC DOI.spRun_GetApplicationLock
            @DatabaseName = ''' + DatabaseName + ''',
            @BatchId = ''00000000-0000-0000-0000-000000000000''
        ' AS GetApplicationLockSQL,
        '
        EXEC DOI.spRun_ReleaseApplicationLock
            @DatabaseName = ''' + DatabaseName + ''',
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
            INNER JOIN DOI.fnFreeSpaceNeededForTableIndexOperations(''' + DatabaseName + ''', ''' + SchemaName + ''', ''' + TableName + ''', ''data'') FSI ON FSI.DriveLetter = FS.DriveLetter
        WHERE DBName = ''' + DatabaseName + '''
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
            INNER JOIN DOI.fnFreeSpaceNeededForTableIndexOperations(''' + DatabaseName + ''', ''' + SchemaName + ''', ''' + TableName + ''', ''log'') FSI ON FSI.DriveLetter = FS.DriveLetter
        WHERE DBName = ''' + DatabaseName + '''
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
            INNER JOIN DOI.fnFreeSpaceNeededForTableIndexOperations(''' + DatabaseName + ''', ''' + SchemaName + ''', ''' +TableName + ''', ''TempDB'') FSI ON FSI.DriveLetter = FS.DriveLetter
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
        FROM DOI.IndexPartitionsRowStore 
        UNION ALL
        SELECT	DatabaseName,
		        SchemaName,
		        TableName,
		        IndexName, 
		        PartitionNumber, 
		        TotalIndexPartitionSizeInMB, 
		        DataFileName, 
		        DriveLetter,
		        NumRows, 
		        TotalPages,
		        Fragmentation,
		        CASE
			        WHEN Fragmentation > 30
				        OR OptionDataCompression <> OptionDataCompression --certain options or frag over 30%.
			        THEN 'AlterRebuild-PartitionLevel-Offline' --can be done on a partition level
			        WHEN (OptionDataCompression = OptionDataCompression)--NO OPTIONS CHANGES, 5-30% frag, needs LOB compaction
				        AND Fragmentation BETWEEN 5 AND 30
			        THEN 'AlterReorganize-PartitionLevel' --this always happens online, can be done on a partition level
			        ELSE 'None'
		        END AS PartitionUpdateType,
		        PartitionType,
		        OptionDataCompression,
		        '
        TRUNCATE TABLE ' + SchemaName + '.' + TableName + 'WITH (PARTITIONS (' + CAST(PartitionNumber AS VARCHAR(5)) + '))' AS TruncateStatement,
        'USE ' + DatabaseName + ';
        ALTER INDEX ' + IndexName + ' ON ' + SchemaName + '.' + TableName + CHAR(13) + CHAR(10) + 
        '	REBUILD PARTITION = ' + CAST(PartitionNumber AS VARCHAR(5)) + CHAR(13) + CHAR(10) + 
        '		WITH (	
				        ONLINE = OFF,
				        MAXDOP = 0,
				        DATA_COMPRESSION = ' + OptionDataCompression COLLATE DATABASE_DEFAULT + ')' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) 
        AS AlterRebuildStatement
				        ,'
        ALTER INDEX ' + IndexName + ' ON ' + SchemaName + '.' + TableName + CHAR(13) + CHAR(10) + 
        '	REORGANIZE PARTITION = ' + CAST(PartitionNumber AS VARCHAR(5)) + CHAR(13) + CHAR(10) + 
        '		WITH (	LOB_COMPACTION = ON)' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) AS AlterReorganizeStatement,
        '
        EXEC DOI.spRun_GetApplicationLock
            @DatabaseName = ''' + DatabaseName + ''',
            @BatchId = ''00000000-0000-0000-0000-000000000000''
        ' AS GetApplicationLockSQL,
        '
        EXEC DOI.spRun_ReleaseApplicationLock
            @DatabaseName = ''' + DatabaseName + ''',
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
            INNER JOIN DOI.fnFreeSpaceNeededForTableIndexOperations(''' + DatabaseName + ''', ''' + SchemaName + ''', ''' + TableName + ''', ''data'') FSI ON FSI.DriveLetter = FS.DriveLetter
        WHERE DBName = ''' + DatabaseName + '''
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
            INNER JOIN DOI.fnFreeSpaceNeededForTableIndexOperations(''' + DatabaseName + ''', ''' + SchemaName + ''', ''' + TableName + ''', ''log'') FSI ON FSI.DriveLetter = FS.DriveLetter
        WHERE DBName = ''' + DatabaseName + '''
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
            INNER JOIN DOI.fnFreeSpaceNeededForTableIndexOperations(''' + DatabaseName + ''', ''' + SchemaName + ''', ''' + TableName + ''', ''TempDB'') FSI ON FSI.DriveLetter = FS.DriveLetter
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
        FROM DOI.IndexPartitionsColumnStore )x

GO