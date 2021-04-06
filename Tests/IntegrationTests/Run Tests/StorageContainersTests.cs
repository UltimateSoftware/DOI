﻿using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using DOI.Tests.Integration.Models;
using DOI.Tests.TestHelpers;
using DOI.Tests.TestHelpers.Metadata;
using DOI.Tests.TestHelpers.Metadata.StorageContainers;
using DOI.Tests.TestHelpers.Metadata.SystemMetadata;
using FluentAssertions;
using NUnit.Framework;
using SmartHub.Hosting.Extensions;
using FgTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitioning_FileGroupsHelper;
using DbfTestHelper = DOI.Tests.TestHelpers.Metadata.vwPartitioning_DBFilesHelper;


/*
using Reporting.Ingestion.Integration.Tests.Database.DataDrivenIndexEngine.Models;
using SmartHub.Hosting.Extensions;
using PaymentSolutions.TestHelpers.Attributes;
using TestHelper = Reporting.TestHelpers;

    do we have tests for:
    AddFileSQL
    PartitionFunctionSplitSQL
    SetFilegroupToNextUsedSQL
*/

namespace DOI.Tests.IntegrationTests.RunTests
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    [Category("ExcludePreflight")]
    [Category("DataDrivenIndex")]
    public class StorageContainersTests : StorageContainerHelper
    {
        private const string PartitionFunctionName = "PfSlidingWindowUnitTest";
        private const string PartitionSchemeName = "psSlidingWindowUnitTest";
        private const string PartitionFunctionNameNoSlidingWindow = "PfNoSlidingWindowUnitTest";
        private const string PartitionSchemeNameNoSlidingWindow = "psNoSlidingWindowUnitTest";
        private const string PartitionFunctionNameMonthly = "PfMonthlyUnitTest";
        private const string PartitionSchemeNameMonthly = "psMonthlyUnitTest";
        private const string TableTestFuturePartitionFailsDueToLocking = "TestFuturePartitionFailsDueToLocking";

        [SetUp]
        public void Setup()
        {
            this.sqlHelper = new SqlHelper();
            this.dataDrivenIndexTestHelper = new DataDrivenIndexTestHelper(this.sqlHelper);
            this.TearDown();

            this.expectedPartitionFunctionBoundaries = new List<PartitionFunctionBoundary>();
            this.expectedPartitionSchemeFilegroups = new List<PartitionSchemeFilegroup>();

            // disable the following job or it will wipe out the metadata we insert in this test.
            this.sqlHelper.Execute(@"EXEC msdb.dbo.sp_update_job @job_name='DOI - Refresh Metadata',@enabled = 0");
        }

        [TearDown]
        public void TearDown()
        {
            this.sqlHelper = new SqlHelper();

            FgTestHelper fgTestHelper = new FgTestHelper();
            DbfTestHelper dbfTestHelper = new DbfTestHelper();

            this.sqlHelper.Execute($@"
            IF OBJECT_ID('dbo.{TableTestFuturePartitionFailsDueToLocking}', 'U') IS NOT NULL
            DROP TABLE {TableTestFuturePartitionFailsDueToLocking}", 30, true, DatabaseName);

            this.sqlHelper.Execute($@"
            IF EXISTS(SELECT * FROM sys.partition_schemes ps WHERE ps.name = '{PartitionSchemeName}')
            DROP PARTITION SCHEME {PartitionSchemeName}", 30, true, DatabaseName);

            this.sqlHelper.Execute($@"
            IF EXISTS(SELECT * FROM sys.partition_functions WHERE name = '{PartitionFunctionName}')
            DROP PARTITION FUNCTION {PartitionFunctionName}", 30, true, DatabaseName);

            this.sqlHelper.Execute($@"
            DELETE DOI.DOI.PartitionFunctions WHERE PartitionFunctionName = '{PartitionFunctionName}'");

            this.sqlHelper.Execute($@"
            IF EXISTS(SELECT * FROM sys.partition_schemes ps WHERE ps.name = '{PartitionSchemeNameNoSlidingWindow}')
            DROP PARTITION SCHEME {PartitionSchemeNameNoSlidingWindow}", 30, true, DatabaseName);

            this.sqlHelper.Execute($@"
            IF EXISTS(SELECT * FROM sys.partition_functions WHERE name = '{PartitionFunctionNameNoSlidingWindow}')
            DROP PARTITION FUNCTION {PartitionFunctionNameNoSlidingWindow}", 30, true, DatabaseName);

            this.sqlHelper.Execute($@"
            DELETE DOI.DOI.PartitionFunctions WHERE PartitionFunctionName = '{PartitionFunctionNameNoSlidingWindow}'");

            var dropFilegroupSql = fgTestHelper.GetFilegroupSql(SystemMetadataHelper.PartitionSchemeNameYearly, "Drop");
            var dropFilesSql = dbfTestHelper.GetDBFilesSql(SystemMetadataHelper.PartitionSchemeNameYearly, "Drop");

            this.sqlHelper.Execute(SystemMetadataHelper.DropPartitionSchemeMonthlySql, 30, true, DatabaseName);
            this.sqlHelper.Execute(SystemMetadataHelper.DropPartitionSchemeYearlySql, 30, true, DatabaseName);
            this.sqlHelper.Execute(SystemMetadataHelper.DropPartitionFunctionMonthlySql, 30, true, DatabaseName);
            this.sqlHelper.Execute(SystemMetadataHelper.DropPartitionFunctionYearlySql, 30, true, DatabaseName);
            this.sqlHelper.Execute(SystemMetadataHelper.MetadataDeleteSql);

            if (dropFilesSql != null)
            {
                sqlHelper.Execute(dropFilesSql, 30, true, DatabaseName);
            }

            if (dropFilegroupSql != null)
            {
                sqlHelper.Execute(dropFilegroupSql, 30, true, DatabaseName);
            }

            // re-enable job
            this.sqlHelper.Execute(@"EXEC msdb.dbo.sp_update_job @job_name='DOI - Refresh Metadata',@enabled = 1");
        }

        [Test]
        [TestCase(0, TestName = "YearlySlidingWindow_BegOfYear")]
        [TestCase(1, TestName = "YearlySlidingWindow_EndOfLastYear")]
        [TestCase(2, TestName = "YearlySlidingWindow_Jan2nd")]
        //[Quarantine("ULTI-413328: Flaky test in the CI.")]
        public void PartitionFunctionSlidingWindowDuplicateBoundaryTest(int? numToSubtract)
        {
            // SETUP
            var boundaryYear = 2016;
            var boundaryId = 1;
            var currentYear = DateTime.Now.Year;

            this.expectedPartitionSchemeFilegroups.Add(new PartitionSchemeFilegroup()
            {
                DatabaseName = DatabaseName,
                DestinationFilegroupId = 1,
                PartitionSchemeName = PartitionSchemeName,
                DataSpaceType = "FG",
                FilegroupName = $"{DatabaseName}_Historical"
            });

            do
            {
                this.expectedPartitionFunctionBoundaries.Add(new PartitionFunctionBoundary()
                {
                    DatabaseName = DatabaseName,
                    Name = PartitionFunctionName,
                    Type = "R",
                    BoundaryValueOnRight = true,
                    BoundaryId = boundaryId,
                    Value = $"{boundaryYear}-01-01".ObjectToDateTime()
                });

                this.expectedPartitionSchemeFilegroups.Add(new PartitionSchemeFilegroup()
                {
                    DatabaseName = DatabaseName,
                    DestinationFilegroupId = boundaryId + 1,
                    PartitionSchemeName = PartitionSchemeName,
                    DataSpaceType = "FG",
                    FilegroupName = $"{DatabaseName}_{boundaryYear}"
                });

                boundaryId++;
                boundaryYear++;
            }
            while (boundaryYear < currentYear);

            // EXPECTED BOUNDARIES AND FILEGROUPS, TEST CASE SPECIFIC
            switch (numToSubtract)
            {
                case 2:
                    this.expectedPartitionFunctionBoundaries.Add(new PartitionFunctionBoundary()
                    {
                        DatabaseName = DatabaseName,
                        Name = PartitionFunctionName,
                        Type = "R",
                        BoundaryValueOnRight = true,
                        BoundaryId = 4,
                        Value = $"{DateTime.Now.Year}-01-01".ObjectToDateTime()
                    });
                    this.expectedPartitionFunctionBoundaries.Add(new PartitionFunctionBoundary()
                    {
                        DatabaseName = DatabaseName,
                        Name = PartitionFunctionName,
                        Type = "R",
                        BoundaryValueOnRight = true,
                        BoundaryId = 5,
                        Value = $"{DateTime.Now.Year}-01-02".ObjectToDateTime()
                    });
                    this.expectedPartitionSchemeFilegroups.Add(new PartitionSchemeFilegroup()
                    {
                        DatabaseName = DatabaseName,
                        DestinationFilegroupId = 5,
                        PartitionSchemeName = PartitionSchemeName,
                        DataSpaceType = "FG",
                        FilegroupName = $"{DatabaseName}_{DateTime.Now.Year}"
                    });
                    this.expectedPartitionSchemeFilegroups.Add(new PartitionSchemeFilegroup()
                    {
                        DestinationFilegroupId = 6,
                        PartitionSchemeName = PartitionSchemeName,
                        DataSpaceType = "FG",
                        FilegroupName = $"{DatabaseName}_Active"
                    });
                    break;
                default:
                    this.expectedPartitionFunctionBoundaries.Add(new PartitionFunctionBoundary()
                    {
                        DatabaseName = DatabaseName,
                        Name = PartitionFunctionName,
                        Type = "R",
                        BoundaryValueOnRight = true,
                        BoundaryId = 4,
                        Value = $"{DateTime.Now.Year - 1}-12-31".ObjectToDateTime()
                    });
                    this.expectedPartitionSchemeFilegroups.Add(new PartitionSchemeFilegroup()
                    {
                        DatabaseName = DatabaseName,
                        DestinationFilegroupId = 5,
                        PartitionSchemeName = PartitionSchemeName,
                        DataSpaceType = "FG",
                        FilegroupName = $"{DatabaseName}_Active"
                    });
                    break;
            }

            this.sqlHelper.Execute($@"
            DECLARE @DayOfYear INT = (SELECT datename(dy, SYSDATETIME())) - {numToSubtract}

            INSERT INTO DOI.DOI.PartitionFunctions ( DatabaseName, PartitionFunctionName ,PartitionFunctionDataType ,BoundaryInterval ,NumOfFutureIntervals ,InitialDate ,UsesSlidingWindow ,SlidingWindowSize ,IsDeprecated )
            VALUES ( '{DatabaseName}', '{PartitionFunctionName}', 'DATETIME2', 'Yearly', 5, '2016-01-01', 1, @DayOfYear, 0)");

            // Act
            this.dataDrivenIndexTestHelper.ExecuteSPCreateNewPartitionFunction(PartitionFunctionName);
            this.dataDrivenIndexTestHelper.ExecuteSPCreateNewPartitionScheme(PartitionFunctionName);

            // Assert
            AssertBoundariesAndFileGroups(PartitionFunctionName);
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
                var setFilegroupToNextUsedSQL = this.sqlHelper.ExecuteScalar<string>($"SELECT TOP 1 SetFilegroupToNextUsedSQL FROM DOI.DOI.vwPartitionFunctionPartitions WHERE PartitionFunctionName = '{SystemMetadataHelper.PartitionFunctionNameYearly}' ORDER BY BoundaryValue ASC");

                // set Filegroup to "NextUsed"
                this.sqlHelper.Execute(setFilegroupToNextUsedSQL);

                // Assert that there are no missing partitions
                Assert.IsNull(this.sqlHelper.ExecuteScalar<string>($"SELECT 'True' FROM DOI.DOI.vwPartitionFunctionPartitions WHERE PartitionFunctionName = '{SystemMetadataHelper.PartitionFunctionNameYearly}' AND IsPartitionMissing = 1"));
            }

            this.sqlHelper.Execute($@"
            --DISABLE TRIGGER DOI.trUpdPartitionFunctions ON DOI.PartitionFunctions
            UPDATE DOI.DOI.PartitionFunctions SET NumOfFutureIntervals = {numOfFutureIntervals} WHERE PartitionFunctionName = '{SystemMetadataHelper.PartitionFunctionNameYearly}'");

            sqlHelper.Execute(SystemMetadataHelper.RefreshMetadata_PartitionFunctionsSql);

            // add new expected values
            var futureMaxYear = DateTime.Now.Year + numOfFutureIntervals;
            do
            {
                this.expectedPartitionFunctionBoundaries.Add(new PartitionFunctionBoundary()
                {
                    Name = SystemMetadataHelper.PartitionFunctionNameYearly,
                    Type = "R",
                    BoundaryValueOnRight = true,
                    BoundaryId = boundaryId,
                    Value = $"{boundaryYear}-01-01".ObjectToDateTime()
                });

                this.expectedPartitionSchemeFilegroups.Add(new PartitionSchemeFilegroup()
                {
                    DestinationFilegroupId = boundaryId + 1,
                    PartitionSchemeName = SystemMetadataHelper.PartitionSchemeNameYearly,
                    DataSpaceType = "FG",
                    FilegroupName = $"{DatabaseName}_{boundaryYear}"
                });

                boundaryId++;
                boundaryYear++;
            }
            while (boundaryYear <= futureMaxYear);

            // Act
            this.dataDrivenIndexTestHelper.ExecuteSPAddFuturePartitions(SystemMetadataHelper.PartitionFunctionNameYearly);

            // Assert
            this.AssertBoundariesAndFileGroups(SystemMetadataHelper.PartitionFunctionNameYearly);
        }

        [Test]
        [TestCase(true, TestName = "MonthlyAdd_FuturePartitions_WithNextUsedFilegroup")]
        [TestCase(false, TestName = "MonthlyAdd_FuturePartitions_NoNextUsedFilegroup")]
        public void CreateMonthlyPartitionsAndAddFutureHappyPathTest(bool nextUsedFilegroupAlreadyExists)
        {
            // setup
            this.sqlHelper.Execute($@"
            INSERT INTO DOI.DOI.PartitionFunctions ( DatabaseName, PartitionFunctionName ,PartitionFunctionDataType ,BoundaryInterval ,NumOfFutureIntervals ,InitialDate ,UsesSlidingWindow ,SlidingWindowSize ,IsDeprecated )
            VALUES ( '{DatabaseName}', '{PartitionFunctionNameMonthly}', 'DATETIME2', 'Monthly', 13, '2018-01-01', 0, NULL, 0)");

            this.sqlHelper.Execute($@"EXEC DOI.DOI.spRefreshMetadata_User_PartitionFunctions_UpdateData");

            this.expectedPartitionFunctionBoundaries = new List<PartitionFunctionBoundary>();

            this.expectedPartitionFunctionBoundaries = this.dataDrivenIndexTestHelper.SetupExpectedPartitionFunctionBoundaries(PartitionFunctionNameMonthly);

            this.expectedPartitionSchemeFilegroups = new List<PartitionSchemeFilegroup>();

            this.expectedPartitionSchemeFilegroups = dataDrivenIndexTestHelper.SetupExpectedPartitionSchemeFilegroups(PartitionFunctionNameMonthly);

            IndexesHelper.CreatePartitioningContainerObjects(PartitionFunctionNameMonthly);

            //this.dataDrivenIndexTestHelper.ExecuteSPCreateNewPartitionFunction(PartitionFunctionNameMonthly);

            //this.dataDrivenIndexTestHelper.ExecuteSPCreateNewPartitionScheme(PartitionFunctionNameMonthly);

            this.AssertBoundariesAndFileGroups(PartitionFunctionNameMonthly);


            // ADD FUTURE PARTITIONS
            if (nextUsedFilegroupAlreadyExists)
            {
                var setFilegroupToNextUsedSQL = this.sqlHelper.ExecuteScalar<string>($@"SELECT TOP 1 SetFilegroupToNextUsedSQL 
                                                                                        FROM DOI.DOI.vwPartitionFunctionPartitions 
                                                                                        WHERE DatabaseName = '{DatabaseName}'
                                                                                            AND PartitionFunctionName = '{PartitionFunctionNameMonthly}' 
                                                                                        ORDER BY BoundaryValue ASC");

                //set Filegroup to "NextUsed"
                this.sqlHelper.Execute(setFilegroupToNextUsedSQL);

                //Assert that there are no missing partitions
                Assert.IsNull(this.sqlHelper.ExecuteScalar<string>($@"  SELECT 'True' 
                                                                        FROM DOI.DOI.vwPartitionFunctionPartitions 
                                                                        WHERE DatabaseName = '{DatabaseName}'
                                                                            AND PartitionFunctionName = '{PartitionFunctionNameMonthly}' 
                                                                            AND IsPartitionMissing = 1"));
            }

            this.sqlHelper.Execute($@"
            --DISABLE TRIGGER DOI.DOI.trUpdPartitionFunctions ON DOI.DOI.PartitionFunctions

            UPDATE DOI.DOI.PartitionFunctions 
            SET NumOfFutureIntervals = 14 
            WHERE DatabaseName = '{DatabaseName}'
                AND PartitionFunctionName = '{PartitionFunctionNameMonthly}'");

            this.sqlHelper.Execute(@"EXEC DOI.DOI.spRefreshMetadata_User_PartitionFunctions_UpdateData");
            this.sqlHelper.Execute(@"EXEC DOI.DOI.spRefreshMetadata_System_SysPartitionFunctions");

            dataDrivenIndexTestHelper.ExecuteSPAddFuturePartitions(PartitionFunctionNameMonthly);
            this.sqlHelper.Execute(@"EXEC DOI.DOI.spRefreshMetadata_System_PartitionFunctions");

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
            var maxFilegroupName = this.expectedPartitionSchemeFilegroups.FindAll(x => x.FilegroupName != $"{DatabaseName}_Historical").Max(x => x.FilegroupName);

            var maxFilegroupDate = $"{maxFilegroupName.Right(2)}/01/{maxFilegroupName.Right(6).Left(4)}".ObjectToDateTime();
            maxFilegroupId++;
            maxFilegroupDate = maxFilegroupDate.AddMonths(1);
            maxFilegroupName = $"{DatabaseName}_" + maxFilegroupDate.Year + maxFilegroupDate.Month.ToString("#00");

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
            this.sqlHelper.Execute(" DISABLE TRIGGER DOI.DOI.trUpdPartitionFunctions ON DOI.DOI.PartitionFunctions"); //disable this trigger or we will not be able to update table.

            this.sqlHelper.Execute(
                $@" UPDATE PF 
                    SET NumOfFutureIntervals = NumOfFutureIntervals + 1 
                    FROM DOI.DOI.PartitionFunctions PF 
                    WHERE DatabaseName = '{DatabaseName}'
                        AND PF.PartitionFunctionName = '{PartitionFunctionNameNoSlidingWindow}'");

            this.sqlHelper.Execute(" ENABLE TRIGGER DOI.DOI.trUpdPartitionFunctions ON DOI.DOI.PartitionFunctions"); //re-enable trigger.

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
                this.dataDrivenIndexTestHelper.ExecuteSPAddFuturePartitions(PartitionFunctionNameNoSlidingWindow, 2);
            }
            catch (SqlException e)
            {
                // if a timeout occurs, this is what we expect from this test, so ignore error and continue test.
                if (!e.Message.ToLower().Contains("timeout"))
                {
                    Assert.Fail(e.Message);
                }
            }

            // Assert
            // NextUsed FileGroup should not exist, because above operation should have rolled back.
            var nextUsedFilegroupName =
                this.sqlHelper.ExecuteScalar<string>(
                    $"SELECT NextUsedFileGroupName FROM DOI.DOI.vwPartitionFunctions WITH (NOLOCK) WHERE PartitionFunctionName = '{PartitionFunctionNameNoSlidingWindow}'");
            Assert.IsNull(nextUsedFilegroupName);

            // Make sure that the process really failed and that no future partitions were created.
            this.AssertBoundariesAndFileGroups(PartitionFunctionNameNoSlidingWindow);

            // Make sure that no duplicates occur in the PrepTables function or in the PartitionState refresh because of this rollback.
            this.dataDrivenIndexTestHelper.GetPrepTableFunctionDuplicates(PartitionFunctionNameNoSlidingWindow).Count.Should().Be(0);
            this.dataDrivenIndexTestHelper.GetPartitionStateFunctionDuplicates(TableTestFuturePartitionFailsDueToLocking).Count.Should().Be(0);
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
                this.sqlHelper.Execute($@"ALTER PARTITION SCHEME {PartitionSchemeNameNoSlidingWindow} NEXT USED [{DatabaseName}_2021]");
            }

            // Assert
            this.dataDrivenIndexTestHelper.GetPrepTableFunctionDuplicates(PartitionFunctionNameNoSlidingWindow).Count.Should().Be(0);
        }
    }
}
