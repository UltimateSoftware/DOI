// <copyright file="SqlIndexJobBaseTest.cs" company="PlaceholderCompany">
// Copyright (c) PlaceholderCompany. All rights reserved.
// </copyright>

namespace DOI.Tests.Integration
{
    using DOI.Tests.TestHelpers;
    using NUnit.Framework;

    public class DOIBaseTest
    {
        protected const string DatabaseName = "DOIUnitTests";
        protected const string SchemaName = "dbo";
        protected const string TestTableName1 = "TempA";
        protected const string TestTableName2 = "TempB";
        protected const string SpaceErrorTableName = "AAA_SpaceError";

        protected DataDrivenIndexTestHelper dataDrivenIndexTestHelper;
        protected TempARepository tempARepository;

        public SqlHelper sqlHelper;

        public DOIBaseTest()
        {
            this.sqlHelper = new SqlHelper();
        }

        [OneTimeSetUp]
        public void OneTimeSetUp()
        {
            // set schedule table to Non Business hours so that job can run
            OneTimeTeardown();
            this.sqlHelper.Execute("UPDATE DOI.DOI.BusinessHoursSchedule SET IsBusinessHours = 0");
            this.sqlHelper.Execute($"EXEC DOI.DOI.spRefreshMetadata_User_DOISettings_InsertData @DatabaseName = '{DatabaseName}'");
            this.sqlHelper.Execute(string.Format(ResourceLoader.Load("Create Test Database.sql")), 120);
        }

        [OneTimeTearDown]
        public void OneTimeTeardown()
        {
            this.sqlHelper.Execute($"EXEC [Utility].[spDeleteAllMetadataFromDatabase] @DatabaseName = '{DatabaseName}'");
            this.sqlHelper.Execute($"DELETE DOI.DOI.DOISettings WHERE DatabaseName = '{DatabaseName}'");
            // restore schedule table to original settings
            this.sqlHelper.Execute("EXEC DOI.DOI.spRefreshMetadata_User_96_BusinessHoursSchedule");
            this.sqlHelper.Execute($"DROP DATABASE IF EXISTS {DatabaseName}");
        }
    }
}