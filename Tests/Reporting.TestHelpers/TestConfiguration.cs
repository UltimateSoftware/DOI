using System.Collections.Generic;

namespace Reporting.TestHelpers
{
    public class TestConfiguration : Dictionary<string, Dictionary<string, string>>
    {
        private static readonly string ConnectionString = "connectionString";

        public string GetConfigValue(string section, string key)
        {
            return this[section][key];
        }

        public string GetConnectionString(string key)
        {
            return GetConfigValue(ConnectionString, key);
        }
    }
}
