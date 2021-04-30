// <copyright file="SqlIndexJobBaseTest.cs" company="PlaceholderCompany">
// Copyright (c) PlaceholderCompany. All rights reserved.
// </copyright>

namespace DOI.Tests.IntegrationTests
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

        public DataDrivenIndexTestHelper dataDrivenIndexTestHelper;
        protected TempARepository tempARepository;

        public SqlHelper sqlHelper;

        public DOIBaseTest()
        {
            this.sqlHelper = new SqlHelper();
            this.dataDrivenIndexTestHelper = new DataDrivenIndexTestHelper(sqlHelper);
        }

        [OneTimeSetUp]
        public void OneTimeSetUp()
        {
            // set schedule table to Non Business hours so that job can run
            OneTimeTeardown();
            this.sqlHelper.Execute("UPDATE DOI.DOI.BusinessHoursSchedule SET IsBusinessHours = 0");
            this.sqlHelper.Execute($"EXEC DOI.DOI.spRefreshMetadata_Setup_DOISettings @DatabaseName = '{DatabaseName}'");
            this.sqlHelper.Execute(string.Format(ResourceLoader.Load("Create Test Database.sql")), 120);
        }

        [OneTimeTearDown]
        public void OneTimeTeardown()
        {
            this.sqlHelper.Execute($"EXEC [Utility].[spDeleteAllMetadataFromDatabase] @DatabaseName = '{DatabaseName}', @OneTimeTearDown = 1");
            // restore schedule table to original settings
            this.sqlHelper.Execute($"EXEC DOI.DOI.spRefreshMetadata_Setup_BusinessHoursSchedule @DatabaseName = '{DatabaseName}'");
            this.sqlHelper.Execute($@"USE master;

            DECLARE @kill varchar(8000); SET @kill = '';
            SELECT @kill = @kill + 'kill ' + CONVERT(varchar(5), spid) + ';'
            FROM master..sysprocesses
            WHERE dbid = db_id('{DatabaseName}')

            EXEC(@kill); DROP DATABASE IF EXISTS {DatabaseName}");
        }
    }
}