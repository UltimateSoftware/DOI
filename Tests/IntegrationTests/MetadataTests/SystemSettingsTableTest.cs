using System;
using System.Collections.Generic;
using DDI.Tests.TestHelpers;
using Microsoft.Practices.Unity.Utility;
using  NUnit.Framework;

namespace Reporting.Ingestion.Integration.Tests.Database
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    [Category("ExcludePreflight")]
    public class SystemSettingsTableTest
    {
        private List<Pair<string, string>> expectedSettingList;

        [SetUp]
        public void Setup()
        {
            expectedSettingList = new List<Pair<string, string>>()
                {
                    new Pair<string, string>("CollectionDetailsNetOutCutoffDate", "2018-06-30"),
                    new Pair<string, string>("DBFileGrowthMB", "10"),
                    new Pair<string, string>("DBFileInitialSizeMB", "100"),
                    new Pair<string, string>("DefaultStatsSampleSizePct", "20"),
                    new Pair<string, string>("FreeSpaceCheckerTestMultiplierForDataFiles", "1"),
                    new Pair<string, string>("FreeSpaceCheckerTestMultiplierForLogFiles", "1"),
                    new Pair<string, string>("LargeTableCutoffValue", "1000"),
                    new Pair<string, string>("FreeSpaceCheckerTestMultiplierForTempDBFiles", "1"),
                    new Pair<string, string>("MinNumPagesForIndexDefrag", "500"),
                    new Pair<string, string>("ReindexingMilitaryTimeToStopJob", "10:00:00.0000000"),
                    new Pair<string, string>("UTEBCP Filepath", @"c:\tmp\user-management\utebcp\")
                };
            var sqlHelper = new SqlHelper();
            sqlHelper.Execute($"EXEC DDI.spRefreshMetadata_User_3_DDISettings");
        }

        [Test]
        public void ValidateSystemSettings()
        {
            var reader = new SqlHelper().ExecuteReader(" SELECT SettingName, SettingValue FROM SystemSettings ORDER BY SettingName ");
            var actualSettingList = new List<Pair<string, string>>();

            while (reader.Read())
            {
                actualSettingList.Add(new Pair<string, string>(Convert.ToString(reader["SettingName"]), Convert.ToString(reader["SettingValue"])));
            }

            Assert.IsNotEmpty(actualSettingList, "The PaymentReporting.DDI.DDISettings table must have settings.");
            Assert.True(actualSettingList.Count == expectedSettingList.Count, $"The PaymentReporting.DDI.DDISettings table must have {expectedSettingList.Count} settings.");

            foreach (Pair<string, string> expectedSetting in expectedSettingList)
            {
                Pair<string, string> actualSetting = actualSettingList.Find(x => x.First == expectedSetting.First);
                Assert.IsNotNull(actualSetting, $"Missing setting [{expectedSetting.First}] in table DDI.DDISettings");
                Assert.AreEqual(expectedSetting.Second, actualSetting.Second, $"Incorrect setting: {expectedSetting.First}.");
                actualSettingList.Remove(actualSetting); // to be more efficient
            }
        }
    }
}
