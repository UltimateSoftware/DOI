using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Threading;
using DOI.Tests.TestHelpers;
using DOI.Tests.TestHelpers.Metadata;
using DOI.Tests.TestHelpers.Metadata.SystemMetadata;
using DOI.Tests.TestHelpers.ExchangeTable;
using Microsoft.Practices.Unity.Utility;
using Newtonsoft.Json.Linq;
using NUnit.Framework;
using SqlHelper = DOI.Tests.TestHelpers.SqlHelper;

namespace DOI.Tests.IntegrationTests.RunTests.ExchangeTablePartitioning
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    [Category("ExcludePreflight")]
    [Category("DataDrivenIndex")]
    [Parallelizable(ParallelScope.Fixtures)]
    public class TablePartitioningTest : DOIBaseTest
    {
        private ExchangeTablePartitioningHelpers exchangeTablePartitioningHelper = new ExchangeTablePartitioningHelpers();

        [SetUp]
        public void SetUp()
        {
            exchangeTablePartitioningHelper.StartSqlServerAgentIfIsNotRunning();
            exchangeTablePartitioningHelper.EnsureThatBcpUtilityIsInPlace();
            TearDown();
        }

        [TearDown]
        public void TearDown()
        {
            sqlHelper.Execute(SetupSqlStatements_Partitioned.DropTableAndDeleteMetadata);
            sqlHelper.Execute(SetupSqlStatements.RestoreJobStep);
        }

        [Test]
        //need to add revert rename tests and also test if the log rows are preserved on rollback on a rename.
        public void HappyPath_PartitionTableThenRevertAndThenReRevert()
        {
            //Setup
            exchangeTablePartitioningHelper.SetUpPartitioningTable();

            //Action
            exchangeTablePartitioningHelper.RunPartitionJobAndWaitForItToFinish();

            //Validation
            exchangeTablePartitioningHelper.ValidateStateAfterPartitioning();

            /*************************************************  REVERT PARTITIONING ****************************************************/
            exchangeTablePartitioningHelper.RevertPartitioningToUnpartitionedTable();

            //Validation
            exchangeTablePartitioningHelper.ValidateStateAfterRevertToUnpartitionedTable();

            /*************************************************  RE-REVERT PARTITIONING ****************************************************/
            exchangeTablePartitioningHelper.ReRevertPartitioningToPartitionedTable();

            //Validation
            exchangeTablePartitioningHelper.ValidateStateAfterReRevertToPartitionedTable();
        }
    }
}