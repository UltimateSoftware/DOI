using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using NUnit.Framework;

namespace DOI.Tests.IntegrationTests.MetadataTests.NotInMetadata
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    [Category("ExcludePreflight")]
    [Category("DataDrivenIndex")]
    public class NotInMetadataGeneralTests : DOIBaseTest
    {
        private const string TablesNotInMetadataSql = @"
SELECT COUNT(*) AS Counts
FROM sys.tables ST
    INNER JOIN sys.schemas s ON s.schema_id = ST.schema_id
WHERE s.name NOT IN ('Utility')
    AND ST.name NOT LIKE '%|_OLD' ESCAPE '|'
    AND ST.name NOT LIKE '%|_NewPartitionedTableFromPrep' ESCAPE '|'
	AND ST.name NOT LIKE '%|_PartitionPrep' ESCAPE '|'
    AND ST.name NOT LIKE '%|_DataSynch' ESCAPE '|'
    AND ST.name NOT IN ('DBDefragLog', 'changelog', 'PayeeFromPTM', 'ConnectionContextVariables')
    AND NOT EXISTS (SELECT 'True'
                    FROM Utility.Tables MT
                    WHERE s.name = MT.SchemaName
                        AND ST.name = MT.TableName )
    AND ISNUMERIC(RIGHT(ST.name, 8)) = 0";
        private const string IndexesNotInMetadataSql = @"
SELECT COUNT(*) AS Counts
FROM SYS.INDEXES I
    INNER JOIN SYS.TABLES T ON T.object_id = I.object_id
    INNER JOIN SYS.SCHEMAS S ON S.schema_id = T.schema_id
    INNER JOIN Utility.Tables T2 ON T2.SchemaName = s.name
        AND T2.TableName = t.name
WHERE NOT EXISTS (  SELECT 'T' 
                    FROM Utility.IndexesRowStore IRS
                        WHERE IRS.SchemaName = S.NAME
                            AND IRS.TableName = T.NAME
                            AND IRS.IndexName = I.NAME
                    UNION ALL
                    SELECT 'T' 
                    FROM Utility.IndexesColumnStore ICS
                    WHERE ICS.SchemaName = S.NAME
                        AND ICS.TableName = T.NAME
                        AND ICS.IndexName = I.NAME)
    AND NOT EXISTS( SELECT 'True' 
                    FROM Utility.IndexesNotInMetadata INIM
                        WHERE INIM.SchemaName = s.name
                        AND INIM.TableName = t.name
                        AND INIM.IndexName = i.name
                        AND INIM.Ignore = 1)
    AND S.NAME IN ('dbo', 'DataMart')
    AND I.type_desc<> 'HEAP'
    AND t.name NOT LIKE '%|_OLD' ESCAPE '|'
    AND t.name NOT LIKE '%|_NewPartitionedTableFromPrep' ESCAPE '|'";
        private const string IndexPartitionsNotInMetadataSql = @"
SELECT COUNT(*) AS Counts
FROM(   SELECT IRS.IndexName
        FROM Utility.Tables T
            INNER JOIN Utility.IndexesRowStore IRS ON IRS.SchemaName = T.SchemaName
                AND IRS.TableName = T.TableName
            INNER JOIN Utility.fnDataDrivenIndexes_GetPartitionSQL() P ON P.SchemaName = T.SchemaName
                AND p.ParentTableName = T.TableName
        WHERE T.SchemaName IN ('dbo', 'DataMart')
            AND t.IntendToPartition = 1
            AND T.ReadyToQueue = 1
            AND NOT EXISTS (SELECT 'True'
                            FROM Utility.IndexRowStorePartitions IRSP
                                WHERE IRSP.SchemaName = IRS.SchemaName
                                AND IRSP.TableName = IRS.TableName
                                AND IRSP.IndexName = IRS.IndexName
                                AND IRSP.PartitionNumber = P.PartitionNumber)
        UNION ALL
        SELECT ICS.IndexName
        FROM Utility.Tables T
            INNER JOIN Utility.IndexesColumnStore ICS ON ICS.SchemaName = T.SchemaName
                AND ICS.TableName = T.TableName
            INNER JOIN Utility.fnDataDrivenIndexes_GetPartitionSQL() P ON P.SchemaName = T.SchemaName
                AND p.ParentTableName = T.TableName
        WHERE T.SchemaName IN ('dbo', 'DataMart')
            AND t.IntendToPartition = 1
            AND T.ReadyToQueue = 1
            AND NOT EXISTS (SELECT 'True'
                            FROM Utility.IndexColumnStorePartitions ICSP
                                WHERE ICSP.SchemaName = ICS.SchemaName
                                AND ICSP.TableName = ICS.TableName
                                AND ICSP.IndexName = ICS.IndexName
                                AND ICSP.PartitionNumber = P.PartitionNumber))X";
        private const string ConstraintsNotInMetadataSql = @"
SELECT COUNT(*) AS Counts
FROM (  SELECT d.name AS Counts
        FROM sys.default_constraints D 
	        INNER JOIN sys.schemas s ON s.schema_id = D.schema_id
	        INNER JOIN (SELECT	name , 
						        object_id 
				        FROM sys.tables) t ON t.object_id = D.parent_object_id
	        INNER JOIN sys.columns c ON c.object_id = t.object_id
		        AND d.parent_column_id = c.column_id
        WHERE s.name NOT IN ('Utility')
	        AND t.name NOT LIKE '%|_OLD' ESCAPE '|'
	        AND t.name NOT IN ('DBDefragLog')
	        AND NOT EXISTS (SELECT 'True' 
					        FROM Utility.DefaultConstraints CC 
					        WHERE s.name = cc.SchemaName 
						        AND t.name = cc.TableName 
						        AND d.name = cc.DefaultConstraintName)
	        AND NOT EXISTS(	SELECT 'True' 
					        FROM Utility.DefaultConstraintsNotInMetadata D2 
					        WHERE s.Name = D2.SchemaName 
						        AND t.Name = D2.TableName 
						        AND c.Name = D2.ColumnName )--check definition here as well.
        UNION ALL
        SELECT ch.name AS Counts
        FROM sys.Check_constraints ch 
	        INNER JOIN sys.schemas s ON s.schema_id = ch.schema_id
	        INNER JOIN (SELECT	name, 
						        object_id 
				        FROM sys.tables) t ON t.object_id = ch.parent_object_id
	        LEFT JOIN sys.columns c ON c.object_id = t.object_id
		        AND ch.parent_column_id = c.column_id
        WHERE s.name NOT IN ('Utility')
	        AND t.name NOT LIKE '%|_OLD' ESCAPE '|'
	        AND t.name NOT IN ('DBDefragLog')
	        AND NOT EXISTS (SELECT 'True' 
					        FROM Utility.CheckConstraints CC 
					        WHERE s.name = cc.SchemaName 
						        AND t.name = cc.TableName 
						        AND ch.name = cc.CheckConstraintName)
	        AND NOT EXISTS(	SELECT 'True' 
					        FROM Utility.CheckConstraintsNotInMetadata CH2 
					        WHERE s.Name = CH2.SchemaName
						        AND t.Name = CH2.TableName 
						        AND ch.NAME = CH2.CheckConstraintName))X";
        private const string StatisticsNotInMetadataSql = @"
SELECT COUNT(*) AS Counts
FROM SYS.STATS AS ST 	    
	CROSS APPLY (	SELECT c.name + ',' 
					FROM sys.stats_columns stc 
						INNER JOIN sys.columns c ON stc.object_id = c.object_id
							AND stc.column_id = c.column_id
					WHERE stc.object_id = st.object_id 
						AND stc.stats_id = st.stats_id
                    ORDER BY stc.stats_column_id ASC
					FOR XML PATH('')) StatsColumns(StatsColumnList)
	CROSS APPLY sys.dm_db_stats_properties(st.object_id, st.stats_id) AS sp  
    INNER JOIN sys.tables t ON st.object_id = t.object_id
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN Utility.Tables TM ON TM.SchemaName = S.name  
        AND TM.TableName = t.name
WHERE st.name NOT LIKE 'NCCI|_%' ESCAPE '|'
    AND st.name NOT LIKE 'CCI|_%' ESCAPE '|'
    AND NOT EXISTS( SELECT 'True' 
                    FROM Utility.[Statistics] STM
                    WHERE s.name = STM.SchemaName
                        AND t.name = STM.TableName
                        AND stm.StatisticsName =    CASE 
                                                        WHEN st.name LIKE '|_WA%' ESCAPE '|' 
                                                        THEN 'ST_' + T.NAME + '_' + REPLACE(STUFF(StatsColumns.StatsColumnList, LEN(StatsColumns.StatsColumnList), 1,NULL), ',', '_') 
                                                        ELSE ST.NAME 
                                                    END)";

        [TestCase(TablesNotInMetadataSql, TestName = "TablesShouldAllBeInMetadata")]
        [TestCase(IndexesNotInMetadataSql, TestName = "IndexesShouldAllBeInMetadata")]
        [TestCase(IndexPartitionsNotInMetadataSql, TestName = "IndexPartitionsShouldAllBeInMetadata")]
        [TestCase(ConstraintsNotInMetadataSql, TestName = "ConstraintsShouldAllBeInMetadata")]
        [TestCase(StatisticsNotInMetadataSql, TestName = "StatisticsShouldAllBeInMetadata")]
        [Test]
        public void AllObjectsShouldBeInMetadata(string sql)
        {
            int rowCount = 0;
            rowCount = sqlHelper.ExecuteScalar<int>(sql);
            Assert.AreEqual(0, rowCount);
        }
    }
}
