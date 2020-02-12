using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using Reporting.TestHelpers;
using NUnit.Framework;

namespace Reporting.Ingestion.Integration.Tests.Database
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    [Category("ExcludePreflight")]
    public class BusinessHoursScheduleTableTest
    {
        private readonly SqlHelper sqlHelper = new SqlHelper();
        private readonly List<BusinessHoursScheduleResult> expectedSchedules = new List<BusinessHoursScheduleResult>()
         {
             new BusinessHoursScheduleResult(1, "Sunday",    TimeSpan.Parse("00:00:00.0000000"), false),
             new BusinessHoursScheduleResult(1, "Sunday",    TimeSpan.Parse("17:00:00.0000000"), true),
             new BusinessHoursScheduleResult(2, "Monday",    TimeSpan.Parse("00:00:00.0000000"), true),
             new BusinessHoursScheduleResult(3, "Tuesday",   TimeSpan.Parse("00:00:00.0000000"), true),
             new BusinessHoursScheduleResult(4, "Wednesday", TimeSpan.Parse("00:00:00.0000000"), true),
             new BusinessHoursScheduleResult(5, "Thursday",  TimeSpan.Parse("00:00:00.0000000"), true),
             new BusinessHoursScheduleResult(6, "Friday",    TimeSpan.Parse("00:00:00.0000000"), true),
             new BusinessHoursScheduleResult(7, "Saturday",  TimeSpan.Parse("00:00:00.0000000"), false),
         };

       [SetUp]
        public void Setup()
        {
            this.sqlHelper.Execute($"EXEC Utility.spDDI_RefreshMetadata_SystemSettings");
        }

        [OneTimeTearDown]
        public void OneTimeTearDown()
        {
            this.sqlHelper.Execute($"EXEC Utility.spRefreshMetadata_BusinessHoursSchedule");
        }

        [Test]
        public void ValidateScheduleIsUnchanged()
        {
            List<BusinessHoursScheduleResult> schedules = this.GetScheduleDataFromSql();
            this.AssertScheduleIsAsExpected(schedules);
        }

        private void AssertScheduleIsAsExpected(List<BusinessHoursScheduleResult> actualSchedules)
        {
            Assert.AreEqual(this.expectedSchedules.Count, actualSchedules.Count, $"Failure: Expecting {this.expectedSchedules.Count} records in utility.BusinessHoursSchedule table.");

            this.expectedSchedules.Sort();
            actualSchedules.Sort();

            using (var itr = actualSchedules.GetEnumerator())
            {
                foreach (var expected in this.expectedSchedules)
                {
                    itr.MoveNext();
                    Assert.AreEqual(expected, itr.Current, "Failure: Unexpected row found in utility.BusinessHoursSchedule table.");
                }
            }
        }
        
        private List<BusinessHoursScheduleResult> GetScheduleDataFromSql()
        {
            var rows = this.sqlHelper.ExecuteQuery(
                new SqlCommand(
                    @"   Select 
                                DayOfWeekId, DayOfWeekName, StartUtcMilitaryTime, IsBusinessHours
                                From Utility.BusinessHoursSchedule "));
            var result = new List<BusinessHoursScheduleResult>();
            foreach (var row in rows)
            {
                int id = row[0].Second.ObjectToInteger();
                string name = row[1].Second.ToString();
                TimeSpan time = TimeSpan.Parse(row[2].Second.ToString());
                bool isBusinessHours = Convert.ToBoolean(row[3].Second);
                
                result.Add(new BusinessHoursScheduleResult(id, name, time, isBusinessHours));
            }

            return result;
        }
        
        public class BusinessHoursScheduleResult : IComparable<BusinessHoursScheduleResult>
        {
            private readonly int dayOfWeek;
            private readonly string dayOfWeekName;
            private readonly TimeSpan startUtcMilitaryTime;
            private readonly bool isBusinessHours;

            public BusinessHoursScheduleResult(
                int dayOfWeek,
                string dayOfWeekName,
                TimeSpan startUtcMilitaryTime,
                bool isBusinessHours)
            {
                this.dayOfWeek = dayOfWeek;
                this.dayOfWeekName = dayOfWeekName;
                this.startUtcMilitaryTime = startUtcMilitaryTime;
                this.isBusinessHours = isBusinessHours;
            }
            
            public override bool Equals(object o)
            {
                var other = (BusinessHoursScheduleResult)o;
                return other != null && (this.dayOfWeek == other.dayOfWeek && string.Equals(this.dayOfWeekName, other.dayOfWeekName) && this.startUtcMilitaryTime.Equals(other.startUtcMilitaryTime) && this.isBusinessHours == other.isBusinessHours);
            }

            public override int GetHashCode()
            {
                unchecked
                {
                    var hashCode = this.dayOfWeek;
                    hashCode = (hashCode * 397) ^ (this.dayOfWeekName != null ? this.dayOfWeekName.GetHashCode() : 0);
                    hashCode = (hashCode * 397) ^ this.startUtcMilitaryTime.GetHashCode();
                    hashCode = (hashCode * 397) ^ this.isBusinessHours.GetHashCode();
                    return hashCode;
                }
            }

            public int CompareTo(BusinessHoursScheduleResult obj)
            {
                if (this.dayOfWeek.CompareTo(obj.dayOfWeek) != 0)
                {
                    return this.dayOfWeek.CompareTo(obj.dayOfWeek);
                }

                if (String.Compare(this.dayOfWeekName, obj.dayOfWeekName, StringComparison.Ordinal) != 0)
                {
                    return String.Compare(this.dayOfWeekName, obj.dayOfWeekName, StringComparison.Ordinal);
                }

                if (this.startUtcMilitaryTime.CompareTo(obj.startUtcMilitaryTime) != 0)
                {
                    return this.startUtcMilitaryTime.CompareTo(obj.startUtcMilitaryTime);
                }

                return this.isBusinessHours.CompareTo(obj.isBusinessHours);
            }

            public override string ToString()
            {
                return $"{this.dayOfWeek} {this.dayOfWeekName} {this.startUtcMilitaryTime} {this.isBusinessHours}";
            }
        }
    }
}