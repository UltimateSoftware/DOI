namespace Reporting.Ingestion.Integration.Tests.Database.DataDrivenIndexEngine
{
    using global::Reporting.TestHelpers;

    using NUnit.Framework;

    public class SqlIndexJobBaseTest
    {
        protected TestHelpers.SqlHelper sqlHelper;

        public SqlIndexJobBaseTest()
        {
            this.sqlHelper = new SqlHelper();
        }

        [OneTimeSetUp]
        public void OneTimeSetUp()
        {
            // set schedule table to Non Business hours so that job can run
            this.sqlHelper.Execute("UPDATE Utility.BusinessHoursSchedule SET IsBusinessHours = 0");
        }

        [OneTimeTearDown]
        public void OneTimeTeardown()
        {
            //restore schedule table to original settings
            this.sqlHelper.Execute("EXEC Utility.spRefreshMetadata_BusinessHoursSchedule");
        }
    }
}