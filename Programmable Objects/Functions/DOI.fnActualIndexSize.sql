-- <Migration ID="21417c13-2136-59b0-bd3e-11bb918f2dac" TransactionHandling="Custom" />
IF OBJECT_ID('[DOI].[fnActualIndexSize]') IS NOT NULL
	DROP FUNCTION [DOI].[fnActualIndexSize];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   FUNCTION [DOI].[fnActualIndexSize](
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME, 
    @TableName SYSNAME, 
    @IndexName SYSNAME)   

RETURNS DECIMAL(10,2)
WITH NATIVE_COMPILATION, SCHEMABINDING  

/*
    set statistics io on
    set statistics time on

    select *, DOI.fnActualIndexSize(
    5,
    s.name , 
    t.name, 
    i.name)   
    from DOI.sysindexes i
        inner join DOI.systables t on t.object_id = i.object_id
        inner join DOI.sysschemas s on t.schema_id = s.schema_id
        cross apply 
*/

AS   
BEGIN ATOMIC WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'English')  
  
    DECLARE @ActualIndexSize DECIMAL(10,2);
  
    SELECT  --p.object_id,
            --p.index_id,
            --SUM(a.total_pages) AS NumPages,
            --MAX(df.physical_name) AS FilePath, 
		    --MAX(LEFT(vs.volume_mount_point, 1)) AS DriveLetter,
			--CAST(CEILING(((SUM(a.total_pages) * 8) / 1024.00)) AS INT) AS TotalSpaceMB,
            @ActualIndexSize = CAST(((SUM(a.total_pages) * 8) / 1024.00) AS DECIMAL(10,2)) --AS TotalSpaceMBDec,
			--CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS INT) AS UsedSpaceMB, 
			--CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS INT) AS UsedSpaceMBDec, 
			--CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSpaceMB,
			--MAX(SS.SizeCutoffValue ) AS SizeCutoffValue,
            --SUM(p.rows) AS NumRows,
            --MAX(p.data_compression_desc) COLLATE DATABASE_DEFAULT AS data_compression_desc
		FROM DOI.systables t 
            INNER JOIN DOI.sysschemas s ON t.SCHEMA_ID = s.SCHEMA_ID
            INNER JOIN DOI.SysIndexes i ON i.OBJECT_ID = t.object_id
            INNER JOIN DOI.syspartitions p ON p.OBJECT_ID = t.OBJECT_ID
                AND p.index_id = I.index_id
            INNER JOIN DOI.SysAllocationUnits a ON p.hobt_id = a.container_id
            INNER JOIN DOI.SysDatabaseFiles df ON df.data_space_id = a.data_space_id
			CROSS JOIN (SELECT CAST(SettingValue AS INT) AS SizeCutoffValue
						FROM DOI.DOISettings 
						WHERE SettingName = 'LargeTableCutoffValue')SS
            CROSS JOIN (SELECT database_id FROM DOI.SysDatabases WHERE name = @DatabaseName) DB
			INNER JOIN DOI.SysDmOsVolumeStats vs ON vs.database_id = DB.database_id
                AND vs.FILE_ID = df.FILE_ID
		WHERE s.NAME = @SchemaName
            AND t.NAME = @TableName
            AND i.NAME = @IndexName
		GROUP BY p.object_id, p.index_id
                                                             
    RETURN (@ActualIndexSize);  
  
END  
GO
