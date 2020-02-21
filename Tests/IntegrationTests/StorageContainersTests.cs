using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using DDI.TestHelpers;
using DDI.Tests.Integration.Models;
using FluentAssertions;
using NUnit.Framework;
using SmartHub.Hosting.Extensions;
using PaymentSolutions.TestHelpers.Attributes;
using TestHelper = DDI.Tests.TestHelpers;

namespace Reporting.Ingestion.Integration.Tests.Database.DataDrivenIndexEngine
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    [Category("ExcludePreflight")]
    [Category("DataDrivenIndex")]
    public class StorageContainersTests
    {
        private TestHelper.SqlHelper sqlHelper;
        private const string PartitionFunctionName = "PfSlidingWindowUnitTest";
        private const string PartitionSchemeName = "psSlidingWindowUnitTest";
        private const string PartitionFunctionNameNoSlidingWindow = "PfNoSlidingWindowUnitTest";
        private const string PartitionSchemeNameNoSlidingWindow = "psNoSlidingWindowUnitTest";
        private const string PartitionFunctionNameMonthly = "PfMonthlyUnitTest";
        private const string PartitionSchemeNameMonthly = "psMonthlyUnitTest";
        private const string TableTestFuturePartitionFailsDueToLocking = "TestFuturePartitionFailsDueToLocking";

        private TestHelper.DataDrivenIndexTestHelper dataDrivenIndexTestHelper;
        private List<PartitionFunctionBoundary> expectedPartitionFunctionBoundaries;
        private List<PartitionSchemeFilegroup> expectedPartitionSchemeFilegroups;

        [SetUp]
        public void Setup()
        {
            this.sqlHelper = new TestHelper.SqlHelper();
            this.dataDrivenIndexTestHelper = new TestHelper.DataDrivenIndexTestHelper(sqlHelper);
            this.TearDown();

            this.expectedPartitionFunctionBoundaries = new List<PartitionFunctionBoundary>();
            this.expectedPartitionSchemeFilegroups = new List<PartitionSchemeFilegroup>();
        }

        [TearDown]
        public void TearDown()
        {
            this.sqlHelper.Execute($@"
            IF OBJECT_ID('dbo.{TableTestFuturePartitionFailsDueToLocking}', 'U') IS NOT NULL
            DROP TABLE {TableTestFuturePartitionFailsDueToLocking}");

            this.sqlHelper.Execute($@"
            IF EXISTS(SELECT * FROM sys.partition_schemes ps WHERE ps.name = '{PartitionSchemeName}')
            DROP PARTITION SCHEME {PartitionSchemeName}");

            this.sqlHelper.Execute($@"
            IF EXISTS(SELECT * FROM sys.partition_functions WHERE name = '{PartitionFunctionName}')
            DROP PARTITION FUNCTION {PartitionFunctionName}");

            this.sqlHelper.Execute($@"
            DELETE DDI.PartitionFunctions WHERE PartitionFunctionName = '{PartitionFunctionName}'");

            this.sqlHelper.Execute($@"
            IF EXISTS(SELECT * FROM sys.partition_schemes ps WHERE ps.name = '{PartitionSchemeNameNoSlidingWindow}')
            DROP PARTITION SCHEME {PartitionSchemeNameNoSlidingWindow}");

            this.sqlHelper.Execute($@"
            IF EXISTS(SELECT * FROM sys.partition_functions WHERE name = '{PartitionFunctionNameNoSlidingWindow}')
            DROP PARTITION FUNCTION {PartitionFunctionNameNoSlidingWindow}");

            this.sqlHelper.Execute($@"
            DELETE DDI.PartitionFunctions WHERE PartitionFunctionName = '{PartitionFunctionNameNoSlidingWindow}'");

            this.sqlHelper.Execute($@"
            IF EXISTS(SELECT * FROM sys.partition_schemes ps WHERE ps.name = '{PartitionSchemeNameMonthly}')
            DROP PARTITION SCHEME {PartitionSchemeNameMonthly}");

            this.sqlHelper.Execute($@"
            IF EXISTS(SELECT * FROM sys.partition_functions WHERE name = '{PartitionFunctionNameMonthly}')
            DROP PARTITION FUNCTION {PartitionFunctionNameMonthly}");

            this.sqlHelper.Execute($@"
            DELETE DDI.PartitionFunctions WHERE PartitionFunctionName = '{PartitionFunctionNameMonthly}'");
        }

        [Test]
        [TestCase(0, TestName = "YearlySlidingWindow_BegOfYear")]
        [TestCase(1, TestName = "YearlySlidingWindow_EndOfLastYear")]
        [TestCase(2, TestName = "YearlySlidingWindow_Jan2nd")]
        [Quarantine("ULTI-413328: Flaky test in the CI.")]
        public void PartitionFunctionSlidingWindowDuplicateBoundaryTest(int? numToSubtract)
        {
            //SETUP
            var boundaryYear = 2016;
            var boundaryId = 1;
            var currentYear = DateTime.Now.Year;

            this.expectedPartitionSchemeFilegroups.Add(new PartitionSchemeFilegroup()
            {
                DestinationFilegroupId = 1,
                PartitionSchemeName = PartitionSchemeName,
                DataSpaceType = "FG",
                FilegroupName = "PaymentReporting_Historical"
            });

            do
            {
                this.expectedPartitionFunctionBoundaries.Add(new PartitionFunctionBoundary()
                {
                    Name = PartitionFunctionName,
                    Type = "R",
                    BoundaryValueOnRight = true,
                    BoundaryId = boundaryId,
                    Value = $"{boundaryYear}-01-01".ObjectToDateTime()
                });

                this.expectedPartitionSchemeFilegroups.Add(new PartitionSchemeFilegroup()
                {
                    DestinationFilegroupId = boundaryId + 1,
                    PartitionSchemeName = PartitionSchemeName,
                    DataSpaceType = "FG",
                    FilegroupName = $"PaymentReporting_{boundaryYear}"
                });

                boundaryId++;
                boundaryYear++;
            } while (boundaryYear < currentYear);

            //EXPECTED BOUNDARIES AND FILEGROUPS, TEST CASE SPECIFIC
            switch (numToSubtract)
            {
                case 2:
                    this.expectedPartitionFunctionBoundaries.Add(new PartitionFunctionBoundary()
                    {
                        Name = PartitionFunctionName,
                        Type = "R",
                        BoundaryValueOnRight = true,
                        BoundaryId = 4,
                        Value = $"{DateTime.Now.Year}-01-01".ObjectToDateTime()
                    });
                    this.expectedPartitionFunctionBoundaries.Add(new PartitionFunctionBoundary()
                    {
                        Name = PartitionFunctionName,
                        Type = "R",
                        BoundaryValueOnRight = true,
                        BoundaryId = 5,
                        Value = $"{DateTime.Now.Year}-01-02".ObjectToDateTime()
                    });
                    this.expectedPartitionSchemeFilegroups.Add(new PartitionSchemeFilegroup()
                    {
                        DestinationFilegroupId = 5,
                        PartitionSchemeName = PartitionSchemeName,
                        DataSpaceType = "FG",
                        FilegroupName = $"PaymentReporting_{DateTime.Now.Year}"
                    });
                    this.expectedPartitionSchemeFilegroups.Add(new PartitionSchemeFilegroup()
                    {
                        DestinationFilegroupId = 6,
                        PartitionSchemeName = PartitionSchemeName,
                        DataSpaceType = "FG",
                        FilegroupName = "PaymentReporting_Active"
                    });
                    break;
                default:
                    this.expectedPartitionFunctionBoundaries.Add(new PartitionFunctionBoundary()
                    {
                        Name = PartitionFunctionName,
                        Type = "R",
                        BoundaryValueOnRight = true,
                        BoundaryId = 4,
                        Value = $"{DateTime.Now.Year - 1}-12-31".ObjectToDateTime()
                    });
                    this.expectedPartitionSchemeFilegroups.Add(new PartitionSchemeFilegroup()
                    {
                        DestinationFilegroupId = 5,
                        PartitionSchemeName = PartitionSchemeName,
                        DataSpaceType = "FG",
                        FilegroupName = "PaymentReporting_Active"
                    });
                    break;
            }

            this.sqlHelper.Execute($@"
            DECLARE @DayOfYear INT = (SELECT datename(dy, SYSDATETIME())) - {numToSubtract}

            INSERT INTO DDI.PartitionFunctions ( PartitionFunctionName ,PartitionFunctionDataType ,BoundaryInterval ,NumOfFutureIntervals ,InitialDate ,UsesSlidingWindow ,SlidingWindowSize ,IsDeprecated )
            VALUES ( '{PartitionFunctionName}', 'DATETIME2', 'Yearly', 5, '2016-01-01', 1, @DayOfYear, 0)");

            // Act
            dataDrivenIndexTestHelper.ExecuteSPCreateNewPartitionFunction(PartitionFunctionName);
            dataDrivenIndexTestHelper.ExecuteSPCreateNewPartitionScheme(PartitionFunctionName);

            // Assert
            this.AssertBoundariesAndFileGroups(PartitionFunctionName);
        }

        [Test]
        [TestCase(2, true, TestName = "YearlyAdd_2_FuturePartitions_WithNextUsedFilegroup")]
        [TestCase(2, false, TestName = "YearlyAdd_2_FuturePartitions_NoNextUsedFilegroup")]
        [TestCase(5, true, TestName = "YearlyAdd_5_FuturePartitions_WithNextUsedFilegroup")]
        [TestCase(5, false, TestName = "YearlyAdd_5_FuturePartitions_NoNextUsedFilegroup")]
        [TestCase(10, true, TestName = "YearlyAdd_10_FuturePartitions_WithNextUsedFilegroup")]
        [TestCase(10, false, TestName = "YearlyAdd_10_FuturePartitions_NoNextUsedFilegroup")]
        public void CreateYearlyPartitionsAndAddFutureHappyPathTest(int numOfFutureIntervals, bool nextUsedFilegroupAlreadyExists)
        {
            // Setup initial partition
            var currentBoundaryIdAndYear = this.SetupInitialStateForYearlyPartitionsWith1FuturePartition();
            var boundaryId = currentBoundaryIdAndYear.Item1;
            var boundaryYear = currentBoundaryIdAndYear.Item2;

            // Setup future partitions
            if (nextUsedFilegroupAlreadyExists)
            {
                var setFilegroupToNextUsedSQL = this.sqlHelper.ExecuteScalar<string>($"SELECT TOP 1 SetFilegroupToNextUsedSQL FROM DDI.vwPartitionFunctionPartitions WHERE PartitionFunctionName = '{PartitionFunctionNameNoSlidingWindow}' ORDER BY BoundaryValue ASC");

                //set Filegroup to "NextUsed"
                this.sqlHelper.Execute(setFilegroupToNextUsedSQL);

                //Assert that there are no missing partitions
                Assert.IsNull(this.sqlHelper.ExecuteScalar<string>($"SELECT 'True' FROM DDI.vwPartitionFunctionPartitions WHERE PartitionFunctionName = '{PartitionFunctionNameNoSlidingWindow}' AND IsPartitionMissing = 1"));
            }

            this.sqlHelper.Execute($@"
            DISABLE TRIGGER DDI.trUpdPartitionFunctions ON DDI.PartitionFunctions
            UPDATE DDI.PartitionFunctions SET NumOfFutureIntervals = {numOfFutureIntervals} WHERE PartitionFunctionName = '{
                    PartitionFunctionNameNoSlidingWindow
                }'");

            //add new expected values
            var futureMaxYear = DateTime.Now.Year + numOfFutureIntervals;
            do
            {
                this.expectedPartitionFunctionBoundaries.Add(new PartitionFunctionBoundary()
                {
                    Name = PartitionFunctionNameNoSlidingWindow,
                    Type = "R",
                    BoundaryValueOnRight = true,
                    BoundaryId = boundaryId,
                    Value = $"{boundaryYear}-01-01".ObjectToDateTime()
                });

                this.expectedPartitionSchemeFilegroups.Add(new PartitionSchemeFilegroup()
                {
                    DestinationFilegroupId = boundaryId + 1,
                    PartitionSchemeName = PartitionSchemeNameNoSlidingWindow,
                    DataSpaceType = "FG",
                    FilegroupName = $"PaymentReporting_{boundaryYear}"
                });

                boundaryId++;
                boundaryYear++;
            } while (boundaryYear <= futureMaxYear);

            // Act
            dataDrivenIndexTestHelper.ExecuteSPAddFuturePartitions(PartitionFunctionNameNoSlidingWindow);

            // Assert
            this.AssertBoundariesAndFileGroups(PartitionFunctionNameNoSlidingWindow);
        }

        private Tuple<int, int> SetupInitialStateForYearlyPartitionsWith1FuturePartition()
        {
            // Arrange (Initial state - Only 1 future interval)
            this.sqlHelper.Execute($@"
            INSERT INTO DDI.PartitionFunctions ( PartitionFunctionName ,PartitionFunctionDataType ,BoundaryInterval ,NumOfFutureIntervals ,InitialDate ,UsesSlidingWindow ,SlidingWindowSize ,IsDeprecated )
            VALUES ( '{PartitionFunctionNameNoSlidingWindow}', 'DATETIME2', 'Yearly', 1, '2016-01-01', 0, NULL, 0)");

            var boundaryId = 1;
            var boundaryYear = 2016;
            var initialFutureMaxYear = DateTime.Now.Year + 1;

            this.expectedPartitionSchemeFilegroups.Add(new PartitionSchemeFilegroup()
            {
                DestinationFilegroupId = 1,
                PartitionSchemeName = PartitionSchemeNameNoSlidingWindow,
                DataSpaceType = "FG",
                FilegroupName = "PaymentReporting_Historical"
            });

            do
            {
                this.expectedPartitionFunctionBoundaries.Add(new PartitionFunctionBoundary()
                {
                    Name = PartitionFunctionNameNoSlidingWindow,
                    Type = "R",
                    BoundaryValueOnRight = true,
                    BoundaryId = boundaryId,
                    Value = $"{boundaryYear}-01-01".ObjectToDateTime()
                });

                this.expectedPartitionSchemeFilegroups.Add(new PartitionSchemeFilegroup()
                {
                    DestinationFilegroupId = boundaryId + 1,
                    PartitionSchemeName = PartitionSchemeNameNoSlidingWindow,
                    DataSpaceType = "FG",
                    FilegroupName = $"PaymentReporting_{boundaryYear}"
                });

                boundaryId++;
                boundaryYear++;
            } while (boundaryYear <= initialFutureMaxYear);

            // Act
            dataDrivenIndexTestHelper.ExecuteSPCreateNewPartitionFunction(PartitionFunctionNameNoSlidingWindow);
            dataDrivenIndexTestHelper.ExecuteSPCreateNewPartitionScheme(PartitionFunctionNameNoSlidingWindow);

            // Assert
            this.AssertBoundariesAndFileGroups(PartitionFunctionNameNoSlidingWindow);

            return new Tuple<int, int>(boundaryId, boundaryYear);
        }

        [Test]
        [TestCase(true, TestName = "MonthlyAdd_FuturePartitions_WithNextUsedFilegroup")]
        [TestCase(false, TestName = "MonthlyAdd_FuturePartitions_NoNextUsedFilegroup")]
        public void CreateMonthlyPartitionsAndAddFutureHappyPathTest(bool nextUsedFilegroupAlreadyExists)
        {
            //setup
            this.sqlHelper.Execute($@"
            INSERT INTO DDI.PartitionFunctions ( PartitionFunctionName ,PartitionFunctionDataType ,BoundaryInterval ,NumOfFutureIntervals ,InitialDate ,UsesSlidingWindow ,SlidingWindowSize ,IsDeprecated )
            VALUES ( '{PartitionFunctionNameMonthly}', 'DATETIME2', 'Monthly', 13, '2018-01-01', 0, NULL, 0)");

            this.expectedPartitionFunctionBoundaries = new List<PartitionFunctionBoundary>();

            this.expectedPartitionFunctionBoundaries =
                dataDrivenIndexTestHelper.SetupExpectedPartitionFunctionBoundaries(PartitionFunctionNameMonthly);

            this.expectedPartitionSchemeFilegroups = new List<PartitionSchemeFilegroup>();

            this.expectedPartitionSchemeFilegroups =
                dataDrivenIndexTestHelper.SetupExpectedPartitionSchemeFilegroups(PartitionFunctionNameMonthly);

            dataDrivenIndexTestHelper.ExecuteSPCreateNewPartitionFunction(PartitionFunctionNameMonthly);

            dataDrivenIndexTestHelper.ExecuteSPCreateNewPartitionScheme(PartitionFunctionNameMonthly);

            this.AssertBoundariesAndFileGroups(PartitionFunctionNameMonthly);

            //ADD FUTURE PARTITIONS
            if (nextUsedFilegroupAlreadyExists)
            {
                var setFilegroupToNextUsedSQL = this.sqlHelper.ExecuteScalar<string>($"SELECT TOP 1 SetFilegroupToNextUsedSQL FROM DDI.vwPartitionFunctionPartitions WHERE PartitionFunctionName = '{PartitionFunctionNameMonthly}' ORDER BY BoundaryValue ASC");

                //set Filegroup to "NextUsed"
                this.sqlHelper.Execute(setFilegroupToNextUsedSQL);

                //Assert that there are no missing partitions
                Assert.IsNull(this.sqlHelper.ExecuteScalar<string>($"SELECT 'True' FROM DDI.vwPartitionFunctionPartitions WHERE PartitionFunctionName = '{PartitionFunctionNameMonthly}' AND IsPartitionMissing = 1"));
            }


            this.sqlHelper.Execute($@"
            DISABLE TRIGGER DDI.trUpdPartitionFunctions ON DDI.PartitionFunctions
            UPDATE DDI.PartitionFunctions SET NumOfFutureIntervals = 14 WHERE PartitionFunctionName = '{
                    PartitionFunctionNameMonthly
                }'");


            dataDrivenIndexTestHelper.ExecuteSPAddFuturePartitions(PartitionFunctionNameMonthly);

            //add new expected value
            var maxBoundaryId = this.expectedPartitionFunctionBoundaries.Max(x => x.BoundaryId);
            var maxBoundaryDate = this.expectedPartitionFunctionBoundaries.Max(x => x.Value);

            maxBoundaryId++;
            maxBoundaryDate = maxBoundaryDate.AddMonths(1);

            this.expectedPartitionFunctionBoundaries.Add(new PartitionFunctionBoundary()
            {
                Name = PartitionFunctionNameMonthly,
                Type = "R",
                BoundaryValueOnRight = true,
                BoundaryId = maxBoundaryId,
                Value = maxBoundaryDate
            });


            var maxFilegroupId = this.expectedPartitionSchemeFilegroups.Max(x => x.DestinationFilegroupId);
            var maxFilegroupName = this.expectedPartitionSchemeFilegroups.FindAll(x => x.FilegroupName != "PaymentReporting_Historical").Max(x => x.FilegroupName);

            var maxFilegroupDate = $"{maxFilegroupName.Right(2)}/01/{maxFilegroupName.Right(6).Left(4)}".ObjectToDateTime();
            maxFilegroupId++;
            maxFilegroupDate = maxFilegroupDate.AddMonths(1);
            maxFilegroupName = "PaymentReporting_" + maxFilegroupDate.Year + maxFilegroupDate.Month.ToString("#00");

            this.expectedPartitionSchemeFilegroups.Add(new PartitionSchemeFilegroup()
            {
                DestinationFilegroupId = maxFilegroupId,
                PartitionSchemeName = PartitionSchemeNameMonthly,
                DataSpaceType = "FG",
                FilegroupName = maxFilegroupName
            });

            this.AssertBoundariesAndFileGroups(PartitionFunctionNameMonthly);
        }

        [Test]
        public void WhenAddFuturePartitionFailsDueToLocking_ShouldRollbackPartitionSchemeChanges()
        {
            /*
             * This test mimics a failure which occurred in production.  Something blocked the AddFuturePartitions job and it was not able to complete.  This failure caused several
             * bad things to happen:
             * 1. The function that returns the Prep Tables for partitioning started to return duplicate values. This caused the partitioning process to fail.
             * 2. The function that returns the result set for the PartitionState Metadata refresh also returned duplicate values.  This can also cause the partitioning process to fail.
             * 3. The process left one of the filegroups marked 'NextUsed'.  Although at this point this appears to be a harmless side effect, we added an assertion to make sure
             *      that it no longer happens.
             * 
             */
            // Arrange (Initial state - Only 1 future interval)
            this.SetupInitialStateForYearlyPartitionsWith1FuturePartition();
            // Create table on that partition scheme
            this.sqlHelper.Execute($@"CREATE TABLE [dbo].[{TableTestFuturePartitionFailsDueToLocking}](
                                        [Date] [datetime2] NOT NULL,
                                        [Text] [varchar](50) NOT NULL,
                                         CONSTRAINT [PK_{TableTestFuturePartitionFailsDueToLocking}] PRIMARY KEY CLUSTERED
                                        (
	                                        [Date] ASC
                                        )WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON {PartitionSchemeNameNoSlidingWindow}([Date])
                                        ) ");

            // Add future interval to metadata so that job has something to do
            this.sqlHelper.Execute(" DISABLE TRIGGER DDI.trUpdPartitionFunctions ON DDI.PartitionFunctions"); //disable this trigger or we will not be able to update table.

            this.sqlHelper.Execute(
                $@" UPDATE PF 
                    SET NumOfFutureIntervals = NumOfFutureIntervals + 1 
                    FROM DDI.PartitionFunctions PF 
                    WHERE PF.PartitionFunctionName = '{PartitionFunctionNameNoSlidingWindow}'");

            this.sqlHelper.Execute(" ENABLE TRIGGER DDI.trUpdPartitionFunctions ON DDI.PartitionFunctions"); //re-enable trigger.

            // Insert into the table with open transaction for 5 seconds.  This will serve as the "blocking" operation for this test.
            var task1 = this.sqlHelper.ExecuteAsync(
                $@"BEGIN TRAN
                    INSERT INTO [dbo].[{TableTestFuturePartitionFailsDueToLocking}] VALUES (GETDATE(), 'Test')
                    WAITFOR DELAY '00:00:05';
                   ROLLBACK",
                marsEnabled: false);

            // Now, run Add Future Partitions SP with a 2 second timeout, so that it blocks with above insert and never completes.
            try
            {
                dataDrivenIndexTestHelper.ExecuteSPAddFuturePartitions(PartitionFunctionNameNoSlidingWindow, 2);
            }
            catch (SqlException e)
            {
                //if a timeout occurs, this is what we expect from this test, so ignore error and continue test.
                if (!e.Message.ToLower().Contains("timeout"))
                {
                    Assert.Fail(e.Message);
                }
            }

            // Assert
            // NextUsed FileGroup should not exist, because above operation should have rolled back.
            var nextUsedFilegroupName =
                this.sqlHelper.ExecuteScalar<string>(
                    $"SELECT NextUsedFileGroupName FROM DDI.vwPartitionFunctions WITH (NOLOCK) WHERE PartitionFunctionName = '{PartitionFunctionNameNoSlidingWindow}'");
            Assert.IsNull(nextUsedFilegroupName);

            // Make sure that the process really failed and that no future partitions were created.
            this.AssertBoundariesAndFileGroups(PartitionFunctionNameNoSlidingWindow);
            
            // Make sure that no duplicates occur in the PrepTables function or in the PartitionState refresh because of this rollback.
            dataDrivenIndexTestHelper.GetPrepTableFunctionDuplicates(PartitionFunctionNameNoSlidingWindow).Count.Should().Be(0);
            dataDrivenIndexTestHelper.GetPartitionStateFunctionDuplicates(TableTestFuturePartitionFailsDueToLocking).Count.Should().Be(0);
        }

        [Test]
        [TestCase(false, TestName = "PrepTableDuplicates_NoNextUsedFilegroup")]
        [TestCase(true, TestName = "PrepTableDuplicates_WithNextUsedFilegroup")]
        public void NoPrepTableDuplicates(bool nextUsedFilegroupAlreadyExists)
        {
            // Arrange (Initial state - Only 1 future interval)
            this.SetupInitialStateForYearlyPartitionsWith1FuturePartition();

            if (nextUsedFilegroupAlreadyExists)
            {
                this.sqlHelper.Execute($@"ALTER PARTITION SCHEME {PartitionSchemeNameNoSlidingWindow} NEXT USED [PaymentReporting_2021]");
            }

            // Assert
            dataDrivenIndexTestHelper.GetPrepTableFunctionDuplicates(PartitionFunctionNameNoSlidingWindow).Count.Should().Be(0);
        }

        private void AssertBoundariesAndFileGroups(string partitionFunctionName)
        {
            //get actual values
            var actualPartitionFunctionBoundariesAddFuturePartitions =
                dataDrivenIndexTestHelper.GetExistingPartitionFunctionBoundaries(partitionFunctionName);
            var actualPartitionSchemeFilegroupsAddFuturePartitions =
                dataDrivenIndexTestHelper.GetExistingPartitionSchemeFilegroups(partitionFunctionName);

            Assert.AreEqual(this.expectedPartitionSchemeFilegroups.Count, actualPartitionSchemeFilegroupsAddFuturePartitions.Count, "FileGroup Count");
            Assert.AreEqual(this.expectedPartitionFunctionBoundaries.Count, actualPartitionFunctionBoundariesAddFuturePartitions.Count, "Boundaries Count");

            //assert before adding future partitions
            //ASSERT 1:  MATCH PARTITION FUNCTION BOUNDARIES TO EXPECTED
            foreach (var expectedPartitionFunctionBoundaryAddFuturePartitions in this.expectedPartitionFunctionBoundaries)
            {
                var actualPartitionFunctionBoundaryAddFuturePartitions =
                    actualPartitionFunctionBoundariesAddFuturePartitions.Find(
                        b => b.BoundaryId == expectedPartitionFunctionBoundaryAddFuturePartitions.BoundaryId);

                Assert.NotNull(actualPartitionFunctionBoundaryAddFuturePartitions, "ActualPartitionBoundary lookup.");
                Assert.AreEqual(expectedPartitionFunctionBoundaryAddFuturePartitions.BoundaryValueOnRight, actualPartitionFunctionBoundaryAddFuturePartitions.BoundaryValueOnRight, "BoundaryValueOnRight compare.");
                Assert.AreEqual(expectedPartitionFunctionBoundaryAddFuturePartitions.Name, actualPartitionFunctionBoundaryAddFuturePartitions.Name, "Name compare.");
                Assert.AreEqual(expectedPartitionFunctionBoundaryAddFuturePartitions.Type, actualPartitionFunctionBoundaryAddFuturePartitions.Type, "Type compare.");
                Assert.AreEqual(expectedPartitionFunctionBoundaryAddFuturePartitions.Value, actualPartitionFunctionBoundaryAddFuturePartitions.Value, "Value compare.");
            }

            //ASSERT 2:  MATCH PARTITION SCHEME FILEGROUPS TO EXPECTED
            foreach (var expectedPartitionSchemeFilegroupAddFuturePartitions in this.expectedPartitionSchemeFilegroups)
            {
                var actualPartitionSchemeFilegroupAddFuturePartitions =
                    actualPartitionSchemeFilegroupsAddFuturePartitions.Find(
                        b => b.DestinationFilegroupId == expectedPartitionSchemeFilegroupAddFuturePartitions
                                 .DestinationFilegroupId);

                Assert.NotNull(expectedPartitionSchemeFilegroupAddFuturePartitions, "ActualPartitionBoundary lookup.");
                Assert.AreEqual(expectedPartitionSchemeFilegroupAddFuturePartitions.DataSpaceType, actualPartitionSchemeFilegroupAddFuturePartitions.DataSpaceType, "DataSpaceType compare.");
                Assert.AreEqual(expectedPartitionSchemeFilegroupAddFuturePartitions.PartitionSchemeName, actualPartitionSchemeFilegroupAddFuturePartitions.PartitionSchemeName, "PartitionSchemeName compare.");
                Assert.AreEqual(expectedPartitionSchemeFilegroupAddFuturePartitions.FilegroupName, actualPartitionSchemeFilegroupAddFuturePartitions.FilegroupName, "FilegroupName compare.");
            }

            //ASSERT 3:  NO DUPLICATES IN PREP TABLE FUNCTION
            dataDrivenIndexTestHelper.GetPrepTableFunctionDuplicates(partitionFunctionName).Count.Should().Be(0);
        }
    }
}
