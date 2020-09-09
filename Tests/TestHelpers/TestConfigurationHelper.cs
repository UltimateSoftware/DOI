using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using Castle.Core.Internal;
using YamlDotNet.Core;
using YamlDotNet.Core.Events;
using YamlDotNet.Serialization;
using YamlDotNet.Serialization.NamingConventions;

namespace DOI.Tests.TestHelpers
{
    public sealed class TestConfigurationHelper
    {
        private static string configFileData;
        private static readonly ConcurrentDictionary<string, dynamic> ConfigSections = new ConcurrentDictionary<string, dynamic>();

        public static readonly string ConfigFilePath = ResolveConfigFilePath();

        public static string ConfigFileData
        {
            get
            {
                if (configFileData == null)
                {
                    using (var reader = File.OpenText(ConfigFilePath))
                    {
                        configFileData = reader.ReadToEnd();
                    }
                }

                return configFileData;
            }
        }

        private static ConcurrentDictionary<string, dynamic> Config
        {
            get
            {
                if (ConfigSections.IsEmpty)
                {
                    ParseConfigFile();
                }

                return ConfigSections;
            }
        }

        private static string GetConnectionString(string connectionName)
        {
            var connStringSetting = ConfigurationManager.ConnectionStrings[connectionName];
            if (connStringSetting == null)
            {
                throw new ArgumentException($"ConnectionString \"{connectionName}\" missing from app config");
            }

            string connString = connStringSetting.ToString();
            if (connString.Trim().IsNullOrEmpty())
            {
                throw new ArgumentException($"ConnectionString \"{connectionName}\" value must not be null or empty in app config");
            }

            return connString;
        }

        public static string GetMqConnectionString()
        {
            return GetConnectionString("mqConnectionString");
        }

        public static string GetUteConnectionString()
        {
            return GetConnectionString("ConnectionString");
        }

        public static string GetMongoDbConnectionString()
        {
            return GetConnectionString("eventStoreMongoDb");
        }

        public static string GetReportingConnectionString()
        {
            return GetConnectionString("reportingConnectionString");
        }

        public static string GetAmendmentsConnectionString()
        {
            return GetConnectionString("taxHubAmendmentStore");
        }

        public static string GetAmendmentsHistoricalConnectionString()
        {
            return GetConnectionString("taxHubHistAmendmentStore");
        }

        public static string GetReportingMongoDbConnectionString()
        {
            return GetConnectionString("reportAggregateEventArchive");
        }

        public static string GetMongoUltiProIntegrationDbConnectionString()
        {
            return GetConnectionString("ultiProIntegrationMongoDb");
        }

        private static void ParseConfigFile()
        {
            var input = new StringReader(ConfigFileData);

            var deserializer = new Deserializer(namingConvention: new CamelCaseNamingConvention());

            var reader = new EventReader(new Parser(input));

            // Consume the stream start event
            reader.Expect<StreamStart>();

            while (reader.Accept<DocumentStart>())
            {
                var doc = deserializer.Deserialize<dynamic>(reader);
                var section = ((Dictionary<object, object>)doc).First();
                var sectionName = section.Key.ToString();
                var sectionData = section.Value;

                // try to add the data for that section
                ConfigSections.AddOrUpdate(sectionName, sectionData, (s, o) => sectionData);
            }
        }

        private static string ResolveConfigFilePath()
        {
            string assemblyLocation = typeof(TestConfigurationHelper).Assembly.Location;
            return Path.Combine(assemblyLocation != null ? (FindPath(new DirectoryInfo(assemblyLocation), "Tests")?.FullName ?? string.Empty) : string.Empty, "config.yml");
        }

        private static DirectoryInfo FindPath(DirectoryInfo path, string pathName)
        {
            if (path == null)
            {
                return null;
            }

            if (path.Name.Equals(pathName, StringComparison.OrdinalIgnoreCase))
            {
                return path;
            }

            return FindPath(path.Parent, pathName);
        }

        public static string GetReportingGatewayUri()
        {
            return Environment.GetEnvironmentVariable("reporting_gateway_uri", EnvironmentVariableTarget.Process) ?? Environment.GetEnvironmentVariable("reporting_gateway_uri") ?? ConfigurationManager.ConnectionStrings["reportingGatewayUri"].ToString();
        }

        public static string GetConfigValue(params string[] keys)
        {
            return keys.Aggregate<string, dynamic>(Config, (node, key) => node[key]) as string;
        }
    }
}
