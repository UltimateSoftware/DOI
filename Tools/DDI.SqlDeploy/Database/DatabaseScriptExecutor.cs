// <copyright file="DatabaseScriptExecutor.cs" company="Ultimate Software">
// Copyright (c) Ultimate Software. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.
// </copyright>

using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using DDI.SqlDeploy.IO;

namespace DDI.SqlDeploy.Database
{
    /// <summary>
    /// database sqlQuery executor
    /// </summary>
    public class DatabaseScriptExecutor
    {
        private const string DefaultConnectionSettings = "SET ANSI_PADDING OFF;\r\n" +
                                                         "SET CONCAT_NULL_YIELDS_NULL ON;\r\n" +
                                                         "SET ARITHABORT ON;\r\n" +
                                                         "SET QUOTED_IDENTIFIER ON;\r\n" +
                                                         "SET ANSI_WARNINGS ON;\r\n" +
                                                         "SET ANSI_NULL_DFLT_ON ON;\r\n" +
                                                         "SET ANSI_NULLS ON;\r\n";

        /// <summary>
        /// returns a sql query string concatenated with a header and footer file
        /// </summary>
        /// <param name="scriptHeaderFile">header file to be concatenated above sqlQuery param</param>
        /// <param name="scriptParam">sql query contents that will be between header and footer</param>
        /// <param name="scriptFooterFile">footer file to be concatenated below sqlQuery param</param>
        /// <returns>string of header sqlQuery and footer concatenated together</returns>
        public static string BuildQueryWithHeaderAndFooter(string scriptHeaderFile, string scriptParam, string scriptFooterFile)
        {
            StringBuilder script = new StringBuilder(string.Empty);
            script.Append(File.ReadAllText(scriptHeaderFile));
            script.Append(scriptParam);
            script.Append(File.ReadAllText(scriptFooterFile));
            return script.ToString();
        }

        /// <summary>
        /// Executes query with no feedback
        /// </summary>
        /// <param name="connectionString">connection string to database</param>
        /// <param name="subFileList">sql files to execute</param>
        /// <param name="runInTransaction">Specifies if a script should be wrapped in a transaction.</param>
        /// <param name="writeToChangeLog">Specifies if a script should be logged to change log.</param>
        /// <param name="commandTimeout">Can be used to modify the command timeout allowed. The default is 300 seconds.</param>
        public static void ExecuteQueries(string connectionString, List<SubFile> subFileList, bool runInTransaction = true, bool writeToChangeLog = true, int commandTimeout = 1800)
        {
            SqlCommand command = null;
            SqlConnection connection = null;
            SqlTransaction transaction = null;

            try
            {
                var originalDB = new SqlConnectionStringBuilder(connectionString).InitialCatalog;
                command = new SqlCommand();
                connection = new SqlConnection(connectionString);
                connection.InfoMessage += (sender, args) => Console.Write(args.Message);
                command.Connection = connection;
                connection.Open();

                // get the real files list
                foreach (SubFile sqlFile in subFileList)
                {
                    // Each script will need to modify default settings explicitly rather than depending on the state of the settings from the previous script
                    command.CommandText = DefaultConnectionSettings;
                    command.ExecuteNonQuery();

                    int batchCounter = 0;

                    try
                    {
                        // split the file into command buffers
                        // ^       : match beginning of line
                        // [ \t]*  : match whitespace 0 or more times. do NOT use \s becaue that includes newlines
                        // go      : match literal word go (note regEx.ignorecase option specified in 2nd parameter of method. 1 time.
                        // [ \t]*  : match whitespace 0 or more times.
                        // (--.*)? : match sql comments, since multiline is specified newline is not included with dot. 0 or 1 times.
                        // \r?     : match carriage return which may appear right before newline, 0 or 1 times.
                        // $       : match end of line.
                        string[] commands = Regex.Split(
                            GetSqlText(sqlFile),
                            @"^[ \t]*go[ \t]*(--.*)?\r?$",
                            RegexOptions.IgnoreCase | RegexOptions.Multiline);

                        int rowCount = 0;
                        int noRowsEffectedCount = 0;
                        int processedBatch = 0;
                        int skippedBatch = 0;

                        if (runInTransaction && !sqlFile.FileName.ToLower().Contains("[skip transaction]"))
                        {
                            Console.WriteLine("Running in a transaction...");
                            transaction = connection.BeginTransaction();
                            command.Transaction = transaction;
                        }
                        else
                        {
                            Console.WriteLine("Not Running in a transaction...");
                        }

                        Console.WriteLine("\nExecuting file: " + sqlFile.FileNameWithPath);
                        Console.WriteLine("Batch count: " + commands.Length);

                        for (; batchCounter < commands.Length; batchCounter++)
                        {
                            if (commands[batchCounter].Equals(string.Empty))
                            {
                                skippedBatch++;
                            }
                            else
                            {
                                command.CommandText = commands[batchCounter];
                                command.Parameters.Clear();
                                command.CommandTimeout = commandTimeout; // measured in seconds
                                int tempRowCount = command.ExecuteNonQuery();
                                if (tempRowCount > -1)
                                {
                                    rowCount += tempRowCount;
                                }
                                else
                                {
                                    noRowsEffectedCount++;
                                }

                                processedBatch++;
                            }
                        }

                        if (runInTransaction && !sqlFile.FileName.ToLower().Contains("[skip transaction]"))
                        {
                            transaction.Commit();
                        }

                        Console.WriteLine("\r\nFile Commited");
                        Console.WriteLine($"Rows affected: {rowCount}");
                        Console.WriteLine(
                            $"Batch with no rows affected: {noRowsEffectedCount} (usually indicates schema change)");
                        Console.WriteLine($"Batches applied: {processedBatch}");
                        Console.WriteLine(
                            $"Batches skipped: {skippedBatch} (Occurs when script contains string \"Go\\nGo\" )");
                    }
                    catch (Exception e)
                    {
                        Console.WriteLine($"Bad Query with batch :{batchCounter + 1} and timeout {commandTimeout}\n{e}\n");
                        if (runInTransaction && !sqlFile.FileName.ToLower().Contains("[skip transaction]"))
                        {
                            Console.WriteLine("Rolling back changes");
                            transaction?.Rollback();
                            Console.WriteLine("File Not Commited");
                        }

                        throw;
                    }

                    // do not write to change log
                    if (!writeToChangeLog)
                    {
                        Console.WriteLine("Skipping write to changelog.");
                        continue;
                    }

                    Console.WriteLine("Updating Change log table");
                    command.CommandText =
                        $"INSERT INTO {originalDB}.dbo.changelog (is_setup, change_number ,complete_dt ,applied_by,description) VALUES ({(sqlFile.IsSetup ? 1 : 0)},{sqlFile.ChangeNumber},SYSDATETIME(),'system','" +
                        sqlFile.Description + "')";
                    command.Parameters.Clear();
                    command.ExecuteNonQuery();
                }

                Console.WriteLine("Applied all scripts, done!");
            }
            finally
            {
                command?.Dispose();
                connection?.Dispose();
                if (runInTransaction)
                {
                    transaction?.Dispose();
                }
            }
        }

        private static string GetSqlText(SubFile sqlFile)
        {
            var result = File.ReadAllText(sqlFile.FileNameWithPath);
            new List<KeyValuePair<string, string>>
            {
                new KeyValuePair<string, string>("%ScriptDir%", Path.GetDirectoryName(sqlFile.FileNameWithPath))
            }.ForEach(x =>
            {
                result = Regex.Replace(
                    result,
                    Regex.Escape(x.Key),
                    x.Value.Replace("$", "$$"),
                    RegexOptions.IgnoreCase);
            });

            return result;
        }

        /// <summary>
        /// Execute query and returns 1st column of query results in a string list
        /// </summary>
        /// <param name="connectionString">connection to database</param>
        /// <param name="sqlQuery">sql query to execute</param>
        /// <returns>list of strings containing only 1st column of query results in string list</returns>
        public static List<string> ExecuteQueryAndReadResult(string connectionString, string sqlQuery)
        {
            List<string> resultList = new List<string>();

            // setup sql pre-requsites
            using (var connection = new SqlConnection(connectionString))
            {
                using (var cmd = new SqlCommand { CommandText = sqlQuery, CommandType = CommandType.Text, Connection = connection })
                {
                    connection.Open();

                    // Data is accessible through the DataReader object here.
                    var reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        resultList.Add(reader[0].ToString());
                    }
                }
            }

            return resultList;
        }

        /// <summary>
        /// Applies sql query to database based on template file
        /// </summary>
        /// <param name="connectionString">connection string to connect to database</param>
        /// <param name="templateFile">template file to modify before executing sql query</param>
        /// <param name="replacePairs">old text, new text pairs. Old text is a variable in template file, new text value is what will replace the variable</param>
        public static void ApplyScriptBasedOnTemplate(string connectionString, string templateFile, params string[] replacePairs)
        {
            // all replacement items should come in pairs, old text and new text
            if (replacePairs.Length % 2 != 0)
            {
                throw new Exception(string.Empty);
            }

            string script = File.ReadAllText(templateFile);

            for (int i = 0; i < replacePairs.Length; i += 2)
            {
                script = script.Replace(replacePairs[i], replacePairs[i + 1]);
            }

            ExecuteQueryAndReadResult(connectionString, script);
        }
    }
}
