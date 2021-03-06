using System;
using System.Collections.Generic;
using Castle.Core;
using DOI.Tests.TestHelpers;
using  NUnit.Framework;

namespace DOI.Tests.IntegrationTests.MetadataTests.SystemMetadata
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    [Category("ExcludePreflight")]
    public class SystemSettingsTableTest : DOIBaseTest
    {
        private List<Pair<string, string>> expectedSettingList;

        [SetUp]
        public void Setup()
        {
            this.expectedSettingList = new List<Pair<string, string>>()
                {
                    new Pair<string, string>("DBFileGrowthMB", "10"),
                    new Pair<string, string>("DBFileInitialSizeMB", "100"),
                    new Pair<string, string>("DefaultStatsSampleSizePct", "20"),
                    new Pair<string, string>("FreeSpaceCheckerTestMultiplierForDataFiles", "1"),
                    new Pair<string, string>("FreeSpaceCheckerTestMultiplierForLogFiles", "1"),
                    new Pair<string, string>("LargeTableCutoffValue", "1000"),
                    new Pair<string, string>("FreeSpaceCheckerTestMultiplierForTempDBFiles", "1"),
                    new Pair<string, string>("MinNumPagesForIndexDefrag", "500"),
                    new Pair<string, string>("ReindexingMilitaryTimeToStopJob", "10:00:00.0000000"),
                    new Pair<string, string>("UTEBCP Filepath", @"c:\tmp\user-management\utebcp\"),
                    new Pair<string, string>("FreeSpaceCheckerPercentBuffer", @"10")
                };
            var sqlHelper = new SqlHelper();
            sqlHelper.Execute($"EXEC DOI.spRefreshMetadata_Setup_DOISettings @DatabaseName = '{DatabaseName}'");
        }

        [Test]
        public void ValidateSystemSettings()
        {
            var reader = new SqlHelper().ExecuteReader($" SELECT SettingName, SettingValue FROM DOI.DOISettings WHERE DatabaseName = '{DatabaseName}' ORDER BY SettingName ");
            var actualSettingList = new List<Pair<string, string>>();

            while (reader.Read())
            {
                actualSettingList.Add(new Pair<string, string>(Convert.ToString(reader["SettingName"]), Convert.ToString(reader["SettingValue"])));
            }

            Assert.IsNotEmpty(actualSettingList, "The DOI.DOISettings table must have settings.");
            Assert.True(actualSettingList.Count == this.expectedSettingList.Count, $"The DOI.DOISettings table must have {this.expectedSettingList.Count} settings.");

            foreach (Pair<string, string> expectedSetting in this.expectedSettingList)
            {
                Pair<string, string> actualSetting = actualSettingList.Find(x => x.First == expectedSetting.First);
                Assert.IsNotNull(actualSetting, $"Missing setting [{expectedSetting.First}] in table DOI.DOISettings");
                Assert.AreEqual(expectedSetting.Second, actualSetting.Second, $"Incorrect setting: {expectedSetting.First}.");
                actualSettingList.Remove(actualSetting); // to be more efficient
            }
        }
    }
}
