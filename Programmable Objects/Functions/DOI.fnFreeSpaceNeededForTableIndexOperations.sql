USE [$(DatabaseName2)]
GO

IF OBJECT_ID('[DOI].[fnFreeSpaceNeededForTableIndexOperations]') IS NOT NULL
	DROP FUNCTION [DOI].[fnFreeSpaceNeededForTableIndexOperations];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE     FUNCTION [DOI].[fnFreeSpaceNeededForTableIndexOperations](
    @DatabaseName SYSNAME,
    @SchemaName SYSNAME, 
    @TableName SYSNAME, 
    @FileType VARCHAR(6))
RETURNS TABLE
AS RETURN

/*
    SELECT * FROM DOI.fnFreeSpaceNeededForTableIndexOperations('PaymentReporting', 'dbo', 'PayTaxes', 'data')
    SELECT * FROM DOI.fnFreeSpaceNeededForTableIndexOperations('PaymentReporting', 'dbo', 'PayTaxes', 'log')
    SELECT * FROM DOI.fnFreeSpaceNeededForTableIndexOperations('PaymentReporting', 'dbo', 'PayTaxes', 'TempDB')
*/


(
	SELECT	V.DatabaseName,
			V.SchemaName,
            V.TableName,
            DriveLetter, 
            @FileType AS FileType,
		    --SUM(V.UsedSpaceMB) AS UsedSpaceMB,
            ISNULL(CASE @FileType
                WHEN 'Data'
                THEN SUM(V.IndexSizeMB_Actual) * MAX(SSD.FreeSpaceMultiplier)
                WHEN 'Log'
                THEN SUM(V.IndexSizeMB_Actual) * MAX(SSL.FreeSpaceMultiplier)
                WHEN 'TempDB'
                THEN    CASE 
                            --in DOI we always assume that SORT_IN_TEMPDB = ON.
                            WHEN MAX(V.NeedsSpaceOnTempDBDrive) = 1 --if at least 1 index needs sort space
                            THEN MAX(V.IndexSizeMB_Actual) + ( SELECT CAST(value_in_use AS INT) AS IndexCreateMemoryKB
                                                        FROM sys.configurations 
                                                        WHERE name = 'index create memory (KB)') --then take size of largest index + IndexCreateMemoryKB value
                            ELSE 0
                        END * MAX(SST.FreeSpaceMultiplier)
            END, 0) AS SpaceNeededOnDrive
    FROM DOI.vwIndexes V
        CROSS JOIN (SELECT CAST(SettingValue AS INT) AS FreeSpaceMultiplier 
                    FROM DOI.DOISettings 
                    WHERE SettingName = 'FreeSpaceCheckerTestMultiplierForDataFiles') SSD
        CROSS JOIN (SELECT CAST(SettingValue AS INT) AS FreeSpaceMultiplier 
                    FROM DOI.DOISettings 
                    WHERE SettingName = 'FreeSpaceCheckerTestMultiplierForLogFiles') SSL
        CROSS JOIN (SELECT CAST(SettingValue AS INT) AS FreeSpaceMultiplier 
                    FROM DOI.DOISettings 
                    WHERE SettingName = 'FreeSpaceCheckerTestMultiplierForTempDBFiles') SST
    WHERE V.DatabaseName = @DatabaseName
        AND V.SchemaName = @SchemaName
        AND V.TableName = @TableName
    GROUP BY V.DatabaseName, V.SchemaName, V.TableName, DriveLetter
)
GO
