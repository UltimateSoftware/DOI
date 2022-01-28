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

namespace DOI.Tests.IntegrationTests.RunTests.ExchangeTableNonPartitioning
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    [Category("ExcludePreflight")]
    [Category("DataDrivenIndex")]
    [Parallelizable(ParallelScope.Fixtures)]
    public class ExchangeTableNonPartitioningTest : DOIBaseTest
    {
        private ExchangeTableNonPartitioningHelpers exchangeTableNonPartitioningHelper = new ExchangeTableNonPartitioningHelpers();

        [SetUp]
        public void SetUp()
        {
            exchangeTableNonPartitioningHelper.StartSqlServerAgentIfIsNotRunning();
            exchangeTableNonPartitioningHelper.EnsureThatBcpUtilityIsInPlace();
            TearDown();
        }



        [TearDown]
        public void TearDown()
        {
            sqlHelper.Execute(SetupSqlStatements_NonPartitioned.tearDownSql);
            //sqlHelper.Execute(SetupSqlStatements_NonPartitioned.RestoreJobStep);  don't know what this is for?
        }

        [Test]
        //need to add test if the log rows are preserved on rollback on a rename.
        public void HappyPath_ExchangeTableNonPartitioningThenRevertAndThenReRevert()
        {
            //Setup
            exchangeTableNonPartitioningHelper.SetUpNonPartitioningTable();

            //Action
            exchangeTableNonPartitioningHelper.RunPartitionJobAndWaitForItToFinish();

            //Validation
            exchangeTableNonPartitioningHelper.ValidateStateAfterExchangeTableNonPartitioned();

            /*************************************************  REVERT PARTITIONING ****************************************************/
            exchangeTableNonPartitioningHelper.RevertTableExchangeUnpartitionedToPriorTable();

            //Validation
            exchangeTableNonPartitioningHelper.ValidateStateAfterRevertTableExchangeUnpartitionedToPriorTable();


            /*************************************************  RE-REVERT PARTITIONING ****************************************************/
            exchangeTableNonPartitioningHelper.ReRevertTableExchangeUnpartitionedToNewTable();

            //Validation
            exchangeTableNonPartitioningHelper.ValidateStateAfterReRevertTableExchangeUnpartitionedToNewTable();
        }
    }
}