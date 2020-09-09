using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DOI.Tests.TestHelpers;
using FluentAssertions;
using NUnit.Framework;
using Models = DOI.Tests.Integration.Models;
using Helper = DOI.Tests.TestHelpers.Metadata.StorageContainers.PartitionFunctions;

namespace DOI.Tests.TestHelpers.Metadata.StorageContainers.PartitionFunctions
{
    public class PartitionFunctionHelper : StorageContainerHelper
    {
        public static string SetupPartitionFunctionMetadataSql(string databaseName, string partitionFunctionName, string boundaryInterval, DateTime initialDate, int numOfFutureIntervals_Desired)
        {
            var sql = PartitionFunction_Setup_Metadata.Replace("<databaseName>", databaseName);
            sql = sql.Replace("<partitionFunctionName>", partitionFunctionName);
            sql = sql.Replace("<boundaryInterval>", boundaryInterval);
            sql = sql.Replace("<numOfFutureIntervals>", numOfFutureIntervals_Desired.ToString());
            sql = sql.Replace("<initialDate>", initialDate.ToString());

            return sql;
        }

        public static Models.PartitionFunction PartitionFunction_Expected(string databaseName, string boundaryInterval, DateTime initialDate, int numOfFutureIntervals_Desired)
        {
            DateTime realLastBoundaryDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);

            realLastBoundaryDate = DateTime.Now.AddMonths(numOfFutureIntervals_Desired);

            DateTime d = initialDate;
            string listOfBoundariesSql = initialDate.ToString();
            while (d < realLastBoundaryDate)
            {
                switch (boundaryInterval)
                {
                    case "Monthly":
                        d = d.AddMonths(1);
                        break;
                    case "Yearly":
                        d = d.AddYears(1);
                        break;
                }
    
                listOfBoundariesSql += String.Concat(",", d.ToString());
            }

            string listOfFilegroupsSql = string.Empty;
            switch (boundaryInterval)
            {
                case "Monthly":
                    listOfFilegroupsSql = string.Concat(databaseName + initialDate.Year + initialDate.Month);
                    break;
                case "Yearly":
                    listOfFilegroupsSql = string.Concat(databaseName + initialDate.Year);
                    break;
            }
            while (d < realLastBoundaryDate)
            {
                switch (boundaryInterval)
                {
                    case "Monthly":
                        d = d.AddMonths(1);
                        break;
                    case "Yearly":
                        d = d.AddYears(1);
                        break;
                }

                listOfFilegroupsSql += String.Concat(",", d.ToString());
            }

            return new Models.PartitionFunction()
            {
                DatabaseName = "DOIUnitTests",
                PartitionFunctionName = $"pf{boundaryInterval}Test",
                PartitionFunctionDataType = "DATETIME2",
                BoundaryInterval = boundaryInterval,
                NumOfFutureIntervals_Desired = numOfFutureIntervals_Desired,
                NumOfFutureIntervals_Actual = 0,
                InitialDate = initialDate,
                UsesSlidingWindow = false,
                SlidingWindowSize = null,
                IsDeprecated = false,
                PartitionSchemeName = $"ps{boundaryInterval}Test",
                NumOfCharsInSuffix = boundaryInterval == "Monthly" ? 6 : 4,
                LastBoundaryDate = realLastBoundaryDate,
                NumOfTotalPartitionFunctionIntervals = GetMonthDifference(initialDate, realLastBoundaryDate),
                NumOfTotalPartitionSchemeIntervals = GetMonthDifference(initialDate, realLastBoundaryDate) + 1,
                MinValueOfDataType = "0001-01-01",
                CreatePartitionFunctionSQL = $@"
'IF NOT EXISTS(SELECT * FROM sys.partition_functions WHERE name = 'pf{boundaryInterval}Test')
BEGIN
    CREATE PARTITION FUNCTION pf{boundaryInterval}Test(DATETIME2)
        AS RANGE RIGHT FOR VALUES('{listOfBoundariesSql}')
END'",
                CreatePartitionSchemeSQL = $@"
IF NOT EXISTS(SELECT * FROM sys.partition_schemes WHERE name = 'ps{boundaryInterval}Test')
BEGIN
    CREATE PARTITION SCHEME 'ps{boundaryInterval}Test'
        AS PARTITION 'pf{boundaryInterval}Test'
            TO('{listOfFilegroupsSql}')
END"
            };
        }

        public static string PartitionFunction_RefreshMetadata = @"EXEC DOI.spRefreshMetadata_User_1_PartitionFunctions";

        public static int GetMonthDifference(DateTime startDate, DateTime endDate)
        {
            int monthsApart = 12 * (startDate.Year - endDate.Year) + startDate.Month - endDate.Month;
            return Math.Abs(monthsApart);
        }
        public static string PartitionFunction_Setup_Metadata = @"
INSERT INTO DOI.PartitionFunctions  (DatabaseName   , PartitionFunctionName	    ,PartitionFunctionDataType	,BoundaryInterval	    ,NumOfFutureIntervals	, InitialDate	    , UsesSlidingWindow	, SlidingWindowSize	, IsDeprecated  , PartitionSchemeName   , NumOfCharsInSuffix, LastBoundaryDate  , NumOfTotalPartitionFunctionIntervals  , NumOfTotalPartitionSchemeIntervals, MinValueOfDataType)
VALUES		                        ('<databaseName>' , '<partitionFunctionName>'	, 'DATETIME2'				,'<boundaryInterval>'	,<numOfFutureIntervals> , '<initialDate>'	, 0					, NULL				, 0             , NULL                  , NULL              , NULL              , NULL                                  , NULL                              , NULL)";

        public static string PartitionFunction_TearDown_Metadata = @"
DELETE DOI.PartitionFunctions 
WHERE PartitionFunctionName = 'pfMonthlyTest'";

        public static string PartitionFunction_VerifyMetadata = @"
SELECT *
FROM DOI.vwPartitionFunctions";

        public void AssertPartitionFunctionsMetadata(string databaseName, string boundaryInterval, DateTime initialDate, int numOfFutureIntervals_Desired)
        {
            var expected = PartitionFunction_Expected(databaseName, boundaryInterval, initialDate, numOfFutureIntervals_Desired);

            var actual = sqlHelper.ExecuteReader(PartitionFunction_VerifyMetadata);

            while (actual.Read())
            {
                Assert.AreEqual(expected.DatabaseName, actual["DatabaseName"]);
                Assert.AreEqual(expected.PartitionFunctionName, actual["PartitionFunctionName"]);
                Assert.AreEqual(expected.PartitionFunctionDataType, actual["PartitionFunctionDataType"]);
                Assert.AreEqual(expected.InitialDate, actual["InitialDate"]);
                Assert.AreEqual(expected.NumOfFutureIntervals_Desired, actual["NumOfFutureIntervals_Desired"]);
                Assert.AreEqual(expected.NumOfFutureIntervals_Actual, actual["NumOfFutureIntervals_Actual"]);
                Assert.AreEqual(expected.PartitionSchemeName, actual["PartitionSchemeName"]);
                Assert.AreEqual(expected.NumOfCharsInSuffix, actual["NumOfCharsInSuffix"]);
                Assert.AreEqual(expected.LastBoundaryDate, actual["LastBoundaryDate"]);
                Assert.AreEqual(expected.NumOfTotalPartitionFunctionIntervals, actual["NumOfTotalPartitionFunctionIntervals"]);
                Assert.AreEqual(expected.NumOfTotalPartitionSchemeIntervals, actual["NumOfTotalPartitionSchemeIntervals"]);
                Assert.AreEqual(expected.MinValueOfDataType, actual["MinValueOfDataType"]);
                Assert.AreEqual(expected.IsPartitionFunctionMissing, actual["IsPartitionFunctionMissing"]);
                Assert.AreEqual(expected.IsPartitionSchemeMissing, actual["IsPartitionSchemeMissing"]);
                Assert.AreEqual(expected.NextUsedFileGroupName, actual["NextUsedFileGroupName"]);
                Assert.AreEqual(expected.CreatePartitionFunctionSQL, actual["CreatePartitionFunctionSQL"]);
                Assert.AreEqual(expected.CreatePartitionSchemeSQL, actual["CreatePartitionSchemeSQL"]);
                Assert.AreEqual(expected.UsesSlidingWindow, actual["UsesSlidingWindow"]);
                Assert.AreEqual(expected.IsDeprecated, actual["IsDeprecated"]);
                Assert.AreEqual(expected.BoundaryInterval, actual["BoundaryInterval"]);

                if (expected.UsesSlidingWindow == true)
                {
                    Assert.AreEqual(expected.SlidingWindowSize, actual["SlidingWindowSize"]);
                }
            }
        }
    }
}
