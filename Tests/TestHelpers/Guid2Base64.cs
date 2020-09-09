using System;
using System.Collections.Generic;
using NUnit.Framework;

namespace DOI.Tests.TestHelpers
{
    [TestFixture]
    [Category("Unit")]
    public class Guid2Base64
    {
        private List<string> guids;

        [OneTimeSetUp]
        public void SetUp()
        {
            guids = Guids2Convert();
        }

        [Test]
        [Ignore("Only need to run by developer locally")]
        public void ConvertGuid2Base64()
        {
            foreach (var guid2Convert in guids)
            {
                Guid guid2Base64 = Guid.Parse(guid2Convert);
                Console.WriteLine("BinData(3, \"" + Convert.ToBase64String(guid2Base64.ToByteArray()) + "\"),");
            }
        }

        private static List<string> Guids2Convert()
        {
            return new List<string>
            {
                "22FDA004-F705-43A0-98B3-AFAFE2B3EF9E",
                "F4502F00-35C9-4236-9565-BBD6E531BE64"
            };
        }
    }
}