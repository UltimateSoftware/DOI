﻿// <copyright file="SqlIndexJobBaseTest.cs" company="PlaceholderCompany">
// Copyright (c) PlaceholderCompany. All rights reserved.
// </copyright>

namespace DOI.Tests.Integration
{
    using DOI.TestHelpers;
    using NUnit.Framework;

    public class DOIBaseTest
    {
        public SqlHelper sqlHelper;

        public DOIBaseTest()
        {
            this.sqlHelper = new SqlHelper();
        }

        [OneTimeSetUp]
        public void OneTimeSetUp()
        {
            // set schedule table to Non Business hours so that job can run
            this.sqlHelper.Execute("UPDATE DOI.DOI.BusinessHoursSchedule SET IsBusinessHours = 0");
        }

        [OneTimeTearDown]
        public void OneTimeTeardown()
        {
            // restore schedule table to original settings
            this.sqlHelper.Execute("EXEC DOI.DOI.spRefreshMetadata_User_96_BusinessHoursSchedule");
        }
    }
}