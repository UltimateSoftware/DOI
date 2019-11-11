using System;
using System.Data.SqlClient;
using Mono.Options;
using System.Configuration;

namespace utebcp
{
    class Program
    {
        static void Main(string[] args)
        {
            var destinationTable = string.Empty;
            var sourceQuery = string.Empty;
            var connectionString = string.Empty;
            var userName = string.Empty;
            var password = string.Empty;

            // default values.
            var batchSize = 100000;
            var initialCatalog = "master";
            var returnCount = true;
            var serverName = "(local)";

            var p = new OptionSet()
                .Add("h|?|help", v => ShowUsage())
                .Add("queryout=|query=|sourcequery=", v => sourceQuery = v)
                .Add("destination=|destinationtable=", v => destinationTable = v)
                .Add("database=|d=", v => initialCatalog = v)
                .Add("server=|S=|servername=", v => serverName = v)
                .Add("username=|U=|userid=", v => userName = v)
                .Add("password=|P=|pwd=", v => password = v)
                .Add("includecount", v => returnCount = true)
                .Add("excludecount|ignorecount", v => returnCount = false)
                .Add("connectionstring=|connstr=", v => connectionString = v)
                .Add("batch=|batchsize=", v => batchSize = Convert.ToInt32(v));

            //p.Parse(new string[] { @"-query=select * from dbo.test;", "-destination=dbo.BulkCopyDemoMatchingColumns", "-batch=50"});
            p.Parse(args);

            if (string.IsNullOrEmpty(sourceQuery) || string.IsNullOrEmpty(destinationTable))
            {
                ShowUsage();
            }

            userName = ConfigurationManager.AppSettings["username"] ?? userName;
            password = ConfigurationManager.AppSettings["password"] ?? password;

            var connStringBuilder = new SqlConnectionStringBuilder
            {
                IntegratedSecurity = string.IsNullOrEmpty(userName),
                InitialCatalog = initialCatalog,
                DataSource = serverName,
                UserID = userName,
                Password = password
            };

            if (!string.IsNullOrEmpty(connectionString))
                connStringBuilder.ConnectionString = connectionString;

            using (var sourceConnection = new SqlConnection(connStringBuilder.ConnectionString))
            {
                sourceConnection.Open();
                using (var targetConnection = new SqlConnection(connStringBuilder.ConnectionString))
                {
                    targetConnection.Open();
                    using (var query = sourceConnection.CreateCommand())
                    {
                        query.CommandText = sourceQuery;
                        query.CommandTimeout = 0;
                        var srcReader = query.ExecuteReader();
                        using (var bulkCopy = new SqlBulkCopy(targetConnection,
                            SqlBulkCopyOptions.KeepIdentity, null))
                        {
                            bulkCopy.DestinationTableName = destinationTable;
                            bulkCopy.BatchSize = batchSize;
                            bulkCopy.BulkCopyTimeout = 0;
                            try
                            {
                                bulkCopy.WriteToServer(srcReader);
                            }
                            catch (Exception ex)
                            {
                                Console.WriteLine(ex);
                            }
                        }
                    }

                    if (returnCount)
                        using (var rowCountQuery = targetConnection.CreateCommand())
                        {
                            rowCountQuery.CommandTimeout = 0;
                            // select * from sys.partitions p where p.object_id = object_id ('dbo.PayTaxes_201801_PartitionPrep');
                            rowCountQuery.CommandText =
                                $"select sum(rows) as total_rows from sys.partitions p where p.object_id = object_id ('{destinationTable}') and index_id in (0, 1)";
                            Console.Write(rowCountQuery.ExecuteScalar());
                            Environment.Exit(0);
                        }
                }
            }
        }

        private static void ShowUsage()
        {
            Console.Write(
                @"usage: utebcp -queryout=""select 1 from x"" -destinationtable=""dbo.table"" [-h] [-database=db] [-batch=10000] 
[-excludecount] [-includecount]
[-S=servername] [-U=username] [-P=password]
[-connectionstring=conn string]

queryout and destinationtable parameters are required");
            Environment.Exit(0);
        }
    }
}