using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using DOI.Tests.TestHelpers;
using NUnit.Framework;

namespace DOI.Tests.IntegrationTests.MetadataTests.SystemMetadata
{
    [TestFixture]
    [Category("Integration")]
    [Category("ReportingIntegration")]
    [Category("ExcludePreflight")]
    public class BusinessHoursScheduleTableTest : DOIBaseTest
    {
        private readonly List<BusinessHoursScheduleResult> expectedSchedules = new List<BusinessHoursScheduleResult>()
         {
             new BusinessHoursScheduleResult(1, "Sunday",    TimeSpan.Parse("00:00:00.0000000"), false, true),
             new BusinessHoursScheduleResult(1, "Sunday",    TimeSpan.Parse("17:00:00.0000000"), true, true),
             new BusinessHoursScheduleResult(2, "Monday",    TimeSpan.Parse("00:00:00.0000000"), true, true),
             new BusinessHoursScheduleResult(3, "Tuesday",   TimeSpan.Parse("00:00:00.0000000"), true, true),
             new BusinessHoursScheduleResult(4, "Wednesday", TimeSpan.Parse("00:00:00.0000000"), true, true),
             new BusinessHoursScheduleResult(5, "Thursday",  TimeSpan.Parse("00:00:00.0000000"), true, true),
             new BusinessHoursScheduleResult(6, "Friday",    TimeSpan.Parse("00:00:00.0000000"), true, true),
             new BusinessHoursScheduleResult(7, "Saturday",  TimeSpan.Parse("00:00:00.0000000"), false, true),
         };

       [SetUp]
        public void Setup()
        {
            this.sqlHelper.Execute($"EXEC DOI.DOI.spRefreshMetadata_User_3_DOISettings @DatabaseName = '{DatabaseName}'");
            this.sqlHelper.Execute($"EXEC DOI.DOI.spRefreshMetadata_User_96_BusinessHoursSchedule @DatabaseName = '{DatabaseName}'");
        }

        [OneTimeTearDown]
        public void OneTimeTearDown()
        {
            this.sqlHelper.Execute($"EXEC DOI.DOI.spRefreshMetadata_User_96_BusinessHoursSchedule @DatabaseName = '{DatabaseName}'");
        }

        [Test]
        public void ValidateScheduleIsUnchanged()
        {
            List<BusinessHoursScheduleResult> schedules = this.GetScheduleDataFromSql();
            this.AssertScheduleIsAsExpected(schedules);
        }

        private void AssertScheduleIsAsExpected(List<BusinessHoursScheduleResult> actualSchedules)
        {
            Assert.AreEqual(this.expectedSchedules.Count, actualSchedules.Count, $"Failure: Expecting {this.expectedSchedules.Count} records in DOI.BusinessHoursSchedule table.");

            this.expectedSchedules.Sort();
            actualSchedules.Sort();

            using (var itr = actualSchedules.GetEnumerator())
            {
                foreach (var expected in this.expectedSchedules)
                {
                    itr.MoveNext();
                    Assert.AreEqual(expected, itr.Current, "Failure: Unexpected row found in DOI.BusinessHoursSchedule table.");
                }
            }
        }
        
        private List<BusinessHoursScheduleResult> GetScheduleDataFromSql()
        {
            var rows = this.sqlHelper.ExecuteQuery(
                new SqlCommand(
                    @"   Select 
                                DayOfWeekId, DayOfWeekName, StartUtcMilitaryTime, IsBusinessHours, IsEnabled
                                From DOI.DOI.BusinessHoursSchedule "));
            var result = new List<BusinessHoursScheduleResult>();
            foreach (var row in rows)
            {
                int id = row[0].Second.ObjectToInteger();
                string name = row[1].Second.ToString();
                TimeSpan time = TimeSpan.Parse(row[2].Second.ToString());
                bool isBusinessHours = Convert.ToBoolean(row[3].Second);
                bool isEnabled = Convert.ToBoolean(row[4].Second);
                
                result.Add(new BusinessHoursScheduleResult(id, name, time, isBusinessHours, isEnabled));
            }

            return result;
        }
        
        public class BusinessHoursScheduleResult : IComparable<BusinessHoursScheduleResult>
        {
            private readonly int dayOfWeek;
            private readonly string dayOfWeekName;
            private readonly TimeSpan startUtcMilitaryTime;
            private readonly bool isBusinessHours;
            private readonly bool isEnabled;

            public BusinessHoursScheduleResult(
                int dayOfWeek,
                string dayOfWeekName,
                TimeSpan startUtcMilitaryTime,
                bool isBusinessHours,
                bool isEnabled)
            {
                this.dayOfWeek = dayOfWeek;
                this.dayOfWeekName = dayOfWeekName;
                this.startUtcMilitaryTime = startUtcMilitaryTime;
                this.isBusinessHours = isBusinessHours;
                this.isEnabled = isEnabled;
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