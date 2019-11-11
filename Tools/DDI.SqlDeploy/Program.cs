// <copyright file="Program.cs" company="Ultimate Software">
// Copyright (c) Ultimate Software. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.
// </copyright>

using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Linq.Expressions;
using System.Text.RegularExpressions;
using CommandLine;
using DDI.SqlDeploy.CommandLine;
using DDI.SqlDeploy.Database;
using DDI.SqlDeploy.IO;

namespace DDI.SqlDeploy
{
    /// <summary>
    /// Main starting point for sqlDeploy program
    /// </summary>
    public class Program
    {
        /// <summary>
        /// Main starting point for sqlDeploy program
        /// </summary>
        /// <param name="args">command line arguments</param>
        public static void Main(string[] args)
        {
            Console.WriteLine("Version tool initiated.");

            // setup parser settings
            var parser = new Parser(config =>
            {
                config.CaseSensitive = false;
                config.HelpWriter = Console.Out;
            });

            // read user arguments from command line
            parser.ParseArguments<RecreateOptions, DeployOptions, SortedExportOptions, RunAdhocScriptOptions>(args)
                .WithParsed<RecreateOptions>(PerformRecreate)
                .WithParsed<DeployOptions>(PerformDeploy)
                .WithParsed<SortedExportOptions>(PerformSortedExport)
                .WithParsed<RunAdhocScriptOptions>(PerformRunAdhocScript)
                .WithNotParsed(errors => // errors is a sequence of type IEnumerable<Error>
                {
                    // if reading arguments failed, exit program
                    Console.WriteLine("Unable to parse command line arguments, exiting program...");
                    Environment.Exit(1);
                });
        }

        private static void PerformRecreate(RecreateOptions options)
        {
            Console.WriteLine("Perform drop and recreate functionality was called");
            options.SqlDatabaseName = ParseDatabaseName(options.ConnectionString);

            // Drop and recreate database
            try
            {
                DatabaseScriptExecutor.ApplyScriptBasedOnTemplate(
                    options.ConnectionString.Replace(options.SqlDatabaseName, "master"),
                    ".\\Database\\Scripts\\DropAndReCreateDatabase.sql",
                    "$(///Database///)",
                    options.SqlDatabaseName);
            }
            catch (Exception e)
            {
                Console.WriteLine($"Error check if database \'{options.SqlDatabaseName}\' exists.\r\n{e}");
                Environment.Exit(1);
            }

            Console.WriteLine("Drop and re-create database");

            // create change log table
            try
            {
                DatabaseScriptExecutor.ApplyScriptBasedOnTemplate(
                    options.ConnectionString,
                    ".\\Database\\Scripts\\EnsureChangeLogExists.sql",
                    "$(///Database///)",
                    options.SqlDatabaseName);
            }
            catch (Exception e)
            {
                Console.WriteLine($"Error check if changelog table exists on database.\r\n" + e);
                Environment.Exit(1);
            }

            Console.WriteLine("recreate changelog table\r\ndone!");
        }

        private static void PerformDeploy(DeployOptions options)
        {
            options.SqlDatabaseName = ParseDatabaseName(options.ConnectionString);
            if (!PerformConfigurationValidation(options))
            {
                Environment.Exit(1);
            }

            if (options.ApplySqlJobsOnly)
            {
                // This is a special case for the secondary cluster nodes
                Console.WriteLine("Only Deploying Jobs.");
                ApplySqlJobs(options, writeToChangeLog: false);
                return;
            }

            ExecuteCreateDatabaseIfNotExists(options);

            PrintSeparatorLine();

            ExecuteCreateChangeLogIfNotExists(options);

            PrintSeparatorLine();

            // -1 - Pre Deploy should always happen first
            var nonTransactionalScripts = FindRunOnceScripts(options.NonTransactionalScriptsDirectory);

            PrintSeparatorLine();

            var nonTransactionalScriptsToApplyList = FilterSqlSetupScriptsBasedOnChangeLog(options, nonTransactionalScripts);
            PrintSeparatorLine();
            ApplyRunOnceScripts("Non-Transactional", options, nonTransactionalScriptsToApplyList, runInTransaction: false);
            PrintSeparatorLine();

            // 0 - Pre Deploy should always happen first
            var preDeployRunAlwaysScripts = FindRerunnableScripts(options.PreDeployScriptsDirectory);
            ApplyRerunnableScripts(options.ConnectionString, preDeployRunAlwaysScripts);
            PrintSeparatorLine();

            // 1 - Setup scripts
            var subFileList = FindRunOnceScripts(options.SetupScriptsDirectory);

            PrintSeparatorLine();

            var setupScriptsToApplyList = FilterSqlSetupScriptsBasedOnChangeLog(options, subFileList);

            PrintSeparatorLine();

            ApplyRunOnceScripts("DDL", options, setupScriptsToApplyList);

            PrintSeparatorLine();

            // 2- Views
            var viewScripts = FindRerunnableScripts(Path.Combine(options.ProgrammableObjectsScriptsDirectory, "Views"));

            ApplyRerunnableScripts(options.ConnectionString, viewScripts);

            PrintSeparatorLine();

            // 3 - Functions
            var functionScripts = FindRerunnableScripts(Path.Combine(options.ProgrammableObjectsScriptsDirectory, "Functions"));

            ApplyRerunnableScripts(options.ConnectionString, functionScripts);

            PrintSeparatorLine();

            //// 4 - Table Valued Functions
            // var tableValuedFunctionScripts = FindRerunnableScripts(Path.Combine(options.ProgrammableObjectsScriptsDirectory, "TableValuedFunctions"));

            // ApplyRerunnableScripts(options.ConnectionString, tableValuedFunctionScripts);

            // PrintSeparatorLine();

            // 5 - Stored procedures
            var storedProcedureScripts = FindRerunnableScripts(Path.Combine(options.ProgrammableObjectsScriptsDirectory, "StoredProcedures"));

            ApplyRerunnableScripts(options.ConnectionString, storedProcedureScripts);

            PrintSeparatorLine();

            // 6 - Triggers
            var triggerScripts = FindRerunnableScripts(Path.Combine(options.ProgrammableObjectsScriptsDirectory, "Triggers"));

            ApplyRerunnableScripts(options.ConnectionString, triggerScripts);

            PrintSeparatorLine();

            // 7- Run always
            var runAlwaysScripts = FindRerunnableScripts(options.RunAlwaysScriptsDirectory);

            ApplyRerunnableScripts(options.ConnectionString, runAlwaysScripts);

            PrintSeparatorLine();

            //// 8 - Test data
            // var testDataScripts = FindTestDataScripts(options);

            // ApplyTestDataScripts(options, testDataScripts);

            // PrintSeparatorLine();

            // 9 - Jobs
            ApplySqlJobs(options, writeToChangeLog: true);
        }

        private static void PerformSortedExport(SortedExportOptions options)
        {
            if (!PerformConfigurationValidation(options))
            {
                Environment.Exit(1);
            }

            PrintSeparatorLine();

            AddExportHeaders(options);

            File.ReadAllLines(options.ScriptsOrderFile)
                .ToList()
                .ForEach(line => Export(line, options));

            PrintSeparatorLine();

            Console.WriteLine($"Output written to file: {Path.Combine(options.OutputDirectory, options.OutputFile)}");
        }

        private static void PerformRunAdhocScript(RunAdhocScriptOptions options)
        {
            Console.WriteLine("Perform run adhoc script was called");
            options.SqlDatabaseName = ParseDatabaseName(options.ConnectionString);

            var script = new List<SubFile> { new SubFile(options.ScriptFilePath, false) };
            PrintSeparatorLine();

            try
            {
                Console.WriteLine($"Executing script: {options.ScriptFilePath}");
                DatabaseScriptExecutor.ExecuteQueries(options.ConnectionString, script, commandTimeout: 43200);
            }
            catch (Exception e)
            {
                Console.WriteLine($"Error running script.\r\n{e}");
                Environment.Exit(1);
            }

            PrintSeparatorLine();
        }

        private static void AddExportHeaders(SortedExportOptions options)
        {
            if (options.SuppressErrorControlHeader)
            {
                return;
            }

            var exportFile = Path.Combine(options.OutputDirectory, options.OutputFile);
            File.AppendAllText(exportFile, $"WHENEVER SQLERROR EXIT FAILURE{Environment.NewLine}");
        }

        private static void ApplyRunOnceScripts(string description, DeployOptions deployOptions, List<SubFile> scriptsToApplyList, bool runInTransaction = true)
        {
            // Apply setup scripts
            try
            {
                if (scriptsToApplyList.Count == 0)
                {
                    Console.WriteLine($"{description} Scripts, no changes to deploy");
                }
                else
                {
                    PrintScriptsToBeProcessed(scriptsToApplyList, $"{description} Scripts");
                    DatabaseScriptExecutor.ExecuteQueries(deployOptions.ConnectionString, scriptsToApplyList, runInTransaction);
                }
            }
            catch (Exception e)
            {
                Console.WriteLine($"Run {description} scripts, error generating scripts. Check for correct syntax.\r\n{e}");
                Environment.Exit(1);
            }
        }

        private static void Export(string line, SortedExportOptions options)
        {
            try
            {
                Console.WriteLine(line);
                if (string.IsNullOrWhiteSpace(line) || line.TrimStart().StartsWith("#"))
                {
                    return;
                }

                var scriptFile = Path.Combine(options.BaseDirectory, line);
                if (!File.Exists(scriptFile))
                {
                    return;
                }

                var separator = options.BatchSeparator;

                var newLine = Environment.NewLine;

                string header = string.Empty;
                if (options.AddScriptTypeAsHeader)
                {
                    header = $"{newLine}-- <<{line}>> --{newLine}";
                }

                var content = $"{header}{File.ReadAllText(scriptFile)}{newLine}{separator}{newLine}";

                var exportFile = Path.Combine(options.OutputDirectory, options.OutputFile);
                File.AppendAllText(exportFile, content);
            }
            catch (Exception e)
            {
                Console.WriteLine($"Export {line} script, error processing scripts. Check for correct syntax.\r\n{e}");
                Environment.Exit(1);
            }
        }

        private static bool PerformConfigurationValidation(DeployOptions deployOptions)
        {
            var jobsOnlyValid = deployOptions.ApplySqlJobsOnly &&
                IsValidDirectoryOption(directory => deployOptions.SqlJobsDirectory) &&
                string.IsNullOrWhiteSpace(deployOptions.NonTransactionalScriptsDirectory) &&
                string.IsNullOrWhiteSpace(deployOptions.PreDeployScriptsDirectory) &&
                string.IsNullOrWhiteSpace(deployOptions.RunAlwaysScriptsDirectory) &&
                string.IsNullOrWhiteSpace(deployOptions.SetupScriptsDirectory) &&
                string.IsNullOrWhiteSpace(deployOptions.ProgrammableObjectsScriptsDirectory) &&
                string.IsNullOrWhiteSpace(deployOptions.TestDataDirectory);

            var normalDeployValid = !jobsOnlyValid &&
                IsValidDirectoryOption(directory => deployOptions.NonTransactionalScriptsDirectory) &&
                IsValidDirectoryOption(directory => deployOptions.PreDeployScriptsDirectory) &&
                IsValidDirectoryOption(directory => deployOptions.RunAlwaysScriptsDirectory) &&
                IsValidDirectoryOption(directory => deployOptions.SetupScriptsDirectory) &&
                IsValidDirectoryOption(directory => deployOptions.ProgrammableObjectsScriptsDirectory) &&
                IsValidDirectoryOption(directory => deployOptions.SqlJobsDirectory) &&
                (string.IsNullOrWhiteSpace(deployOptions.TestDataDirectory) ||
                    (!string.IsNullOrWhiteSpace(deployOptions.TestDataDirectory) && IsValidDirectoryOption(directory => deployOptions.TestDataDirectory)));

            return jobsOnlyValid || normalDeployValid;
        }

        private static bool PerformConfigurationValidation(SortedExportOptions options)
        {
            var valid = IsValidDirectoryOption(directory => options.OutputDirectory) &&
                        IsValidNewFileAndDirectoryOption(options.OutputDirectory, () => options.OutputFile) &&
                        FileExists(() => options.ScriptsOrderFile);

            return valid;
        }

        private static bool FileExists(Expression<Func<string>> action)
        {
            var expression = (MemberExpression)action.Body;
            var name = expression.Member.Name;

            var value = action.Compile().Invoke();
            if (File.Exists(value))
            {
                return true;
            }

            Console.Error.WriteLine($"Invalid setting for {name}: '{value}'. File does not exist.");
            return false;
        }

        private static bool IsValidNewFileAndDirectoryOption(string directory, Expression<Func<string>> action)
        {
            var expression = (MemberExpression)action.Body;
            var name = expression.Member.Name;

            var value = action.Compile().Invoke();
            if (!File.Exists(Path.Combine(directory, value)))
            {
                return true;
            }

            Console.Error.WriteLine($"Invalid setting for {name}: '{value}'. File already exists.");
            return false;
        }

        private static bool IsValidDirectoryOption(Expression<Func<object, string>> action)
        {
            var expression = (MemberExpression)action.Body;
            var name = expression.Member.Name;

            var value = action.Compile().Invoke(null);
            if (Directory.Exists(value))
            {
                return true;
            }

            Console.Error.WriteLine($"Invalid setting for {name}: '{value}'");
            return false;
        }

        private static void ApplySqlJobs(DeployOptions options, bool writeToChangeLog)
        {
            var sqlJobsScripts = FindRerunnableScripts(options.SqlJobsDirectory);

            // switch from app database to master for jobs.
            var sqlConnectionStringBuilder = new SqlConnectionStringBuilder(options.ConnectionString);

            if (!writeToChangeLog)
            {
                Console.WriteLine("Switch to database master due to writeToChangeLog=false");
                sqlConnectionStringBuilder.InitialCatalog = "master";
            }

            // Need to extend the command timeout for the case where the secondary servers have to wait for the primary to be ready and the Availability Group to be ready
            ApplyRerunnableScripts(sqlConnectionStringBuilder.ConnectionString, sqlJobsScripts, writeToChangeLog: writeToChangeLog, commandTimeout: 1800);

            PrintSeparatorLine();
        }

        private static void ApplyTestDataScripts(DeployOptions options, List<SubFile> testDataScripts)
        {
            // Apply test data scripts
            try
            {
                if (testDataScripts == null || testDataScripts.Count == 0)
                {
                    Console.WriteLine("Test data scripts, no scripts to deploy");
                }
                else
                {
                    PrintScriptsToBeProcessed(testDataScripts, "Test data scripts");
                    DatabaseScriptExecutor.ExecuteQueries(options.ConnectionString, testDataScripts);
                }
            }
            catch (Exception e)
            {
                Console.WriteLine("Test data scripts, error generating scripts. Check for correct syntax.\r\n" + e);
                Environment.Exit(1);
            }
        }

        private static void ApplyRerunnableScripts(string connectionString, SubFileList rerunnableScripts, bool writeToChangeLog = true, int commandTimeout = 1800)
        {
            // Apply run always scripts
            try
            {
                if (rerunnableScripts.Count == 0)
                {
                    Console.WriteLine("Run rerunnable scripts, no scripts to deploy");
                }
                else
                {
                    var runAlwaysScriptsList = rerunnableScripts.Values.ToList();
                    runAlwaysScriptsList.Sort(Comparison);

                    PrintScriptsToBeProcessed(runAlwaysScriptsList, "Run always scripts");
                    DatabaseScriptExecutor.ExecuteQueries(connectionString, runAlwaysScriptsList, writeToChangeLog: writeToChangeLog, commandTimeout: commandTimeout);
                }
            }
            catch (Exception e)
            {
                Console.WriteLine($"Run always scripts, error generating scripts. Check for correct syntax.\r\n{e}");
                Environment.Exit(1);
            }
        }

        private static int Comparison(SubFile subFile, SubFile file)
        {
            return subFile.ChangeNumber.CompareTo(file.ChangeNumber);
        }

        private static List<SubFile> FilterSqlSetupScriptsBasedOnChangeLog(DeployOptions options, SubFileList subFileList)
        {
            // connect to database get list of scripts that have already been applied and make a list of all scripts that need to be
            Console.WriteLine(
                "check database get list of scripts that have already been applied and make a list of all scripts that need to be applied");
            List<SubFile> setupScriptsToApplyList = null;
            try
            {
                setupScriptsToApplyList = subFileList.GetSqlFilesToBeApplied(options.ConnectionString);
            }
            catch (Exception e)
            {
                Console.WriteLine($"Error getting scripts that need to be applied.\r\n{e}");
                Environment.Exit(1);
            }

            return setupScriptsToApplyList;
        }

        private static void ExecuteCreateChangeLogIfNotExists(DeployOptions options)
        {
            // connect to database check if changelog exist, if not create it
            Console.WriteLine("connect to database check if changelog exist, if not create it");
            try
            {
                DatabaseScriptExecutor.ApplyScriptBasedOnTemplate(
                    options.ConnectionString,
                    ".\\Database\\Scripts\\EnsureChangeLogExists.sql",
                    "$(///Database///)",
                    options.SqlDatabaseName);
            }
            catch (Exception e)
            {
                Console.WriteLine($"Error check if changelog table exists on database.\r\n{e}");
                Environment.Exit(1);
            }
        }

        private static void ExecuteCreateDatabaseIfNotExists(DeployOptions options)
        {
            // Connect to database check if database exist, if not create it
            Console.WriteLine("Connect to database check if database exist, if not create it");
            try
            {
                DatabaseScriptExecutor.ApplyScriptBasedOnTemplate(
                    options.ConnectionString.Replace(options.SqlDatabaseName, "master"),
                    ".\\Database\\Scripts\\EnsureDatabaseExists.sql",
                    "$(///Database///)",
                    options.SqlDatabaseName);
            }
            catch (Exception e)
            {
                Console.WriteLine($"Error check if database \'{options.SqlDatabaseName}\' exists.\r\n{e}");
                Environment.Exit(1);
            }
        }

        private static List<SubFile> FindTestDataScripts(DeployOptions options)
        {
            // map out directories and files sql run always scripts input files directory
            List<SubFile> testDataScripts = null;
            Console.WriteLine("Search for sql files to deploy");
            if (!string.IsNullOrWhiteSpace(options.TestDataDirectory))
            {
                try
                {
                    testDataScripts = new SubFileList(options.TestDataDirectory, true).GetSqlFilesToBeApplied(options.ConnectionString);
                }
                catch (Exception e)
                {
                    Console.WriteLine(
                        $"Error collecting sql files. Perhaps the folder structure is not setup correctly in staging area.\r\n{e}");
                    Environment.Exit(1);
                }
            }

            return testDataScripts;
        }

        private static SubFileList FindRunOnceScripts(string folderToScan)
        {
            var scripts = FindScripts(folderToScan, true);
            return scripts;
        }

        private static SubFileList FindRerunnableScripts(string inputDirectory)
        {
            var scripts = FindScripts(inputDirectory, false);
            return scripts;
        }

        private static SubFileList FindScripts(string inputDirectory, bool isSetup)
        {
            SubFileList rerunnableScripts = null;
            Console.WriteLine("Search for sql files to deploy");
            try
            {
                rerunnableScripts = new SubFileList(inputDirectory, isSetup);
            }
            catch (Exception e)
            {
                Console.WriteLine(
                    $"Error collecting sql files. Perhaps the folder structure is not setup correctly in staging area.\r\n{e}");
                Environment.Exit(1);
            }

            return rerunnableScripts;
        }

        private static List<SubFile> FindAllScripts(string inputDirectory, bool isSetup)
        {
            return FindScripts(inputDirectory, isSetup).GetAllSqlFiles();
        }

        private static void PrintSeparatorLine()
        {
            Console.Write("\n\n---------------\n\n");
        }

        private static void PrintScriptsToBeProcessed(IReadOnlyList<SubFile> scriptsToListInConsole, string scriptTypes)
        {
            Console.WriteLine($"{scriptTypes}, found following scripts to apply in this order");
            for (int i = 0; i < scriptsToListInConsole.Count; i++)
            {
                Console.WriteLine(i + 1 + ": chg(" + scriptsToListInConsole[i].ChangeNumber + ")  -  " + scriptsToListInConsole[i].FileName);
            }
        }

        /// <summary>
        /// Parses the database name from <paramref name="connectionString"/>.
        /// </summary>
        /// <param name="connectionString">The connection string to read the database name from.</param>
        /// <returns>The name of the database used in the connection string.</returns>
        private static string ParseDatabaseName(string connectionString)
        {
            Regex databaseFinder = new Regex(@"(database|Initial Catalog)=([a-z]|[0-9]|[-]|[_])+;", RegexOptions.IgnoreCase);
            string parsedDatabaseString = databaseFinder.Match(connectionString).Groups[0].Value.Replace(";", string.Empty);
            return parsedDatabaseString.Split('=')[1];
        }
    }
}