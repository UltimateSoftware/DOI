
GO

IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysMasterFiles]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysMasterFiles];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysMasterFiles]
    @DatabaseName NVARCHAR(128) = NULL,
    @Debug BIT = 0

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysMasterFiles]
        @DatabaseName = 'DOIUnitTests'
*/

DELETE MF
FROM DOI.SysMasterFiles MF
    INNER JOIN DOI.SysDatabases D ON MF.database_id = D.database_id
WHERE D.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END

DELETE MF
FROM DOI.SysMasterFiles MF
    INNER JOIN DOI.SysDatabases D ON MF.database_id = D.database_id
WHERE D.name = 'TempDb'

DECLARE @SQL NVARCHAR(MAX) = ''

SELECT TOP 1 @SQL += '
SELECT TOP 1 *
INTO #SysMasterFiles
FROM sys.master_files
WHERE 1 = 2

INSERT INTO #SysMasterFiles
SELECT *
FROM sys.master_files
WHERE database_id IN (2, ' + CAST(SD.database_id AS VARCHAR(20)) + ')'
--select count(*)
FROM DOI.Databases D
    INNER JOIN DOI.SysDatabases SD ON D.DatabaseName = SD.name
WHERE D.DatabaseName = CASE WHEN @DatabaseName IS NULL THEN D.DatabaseName ELSE @DatabaseName END

SELECT @SQL += '    
INSERT INTO DOI.SysMasterFiles
SELECT [database_id], [file_id], [file_guid], [type], [type_desc], [data_space_id], [name], [physical_name], [state], [state_desc], [size], [max_size], [growth], [is_media_read_only], [is_read_only], [is_sparse], [is_percent_growth], [is_name_reserved], [create_lsn], [drop_lsn], [read_only_lsn], [read_write_lsn], [differential_base_lsn], [differential_base_guid], [differential_base_time], [redo_start_lsn], [redo_start_fork_guid], [redo_target_lsn], [redo_target_fork_guid], [backup_lsn], [credential_id]
FROM #SysMasterFiles

DROP TABLE IF EXISTS #SysMasterFiles' + CHAR(13) + CHAR(10)

IF @Debug = 1
BEGIN
    EXEC DOI.spPrintOutLongSQL
        @SQLInput = @SQL,
        @VariableName = '@SQL'
END
ELSE
BEGIN
    EXEC(@SQL)
END

GO