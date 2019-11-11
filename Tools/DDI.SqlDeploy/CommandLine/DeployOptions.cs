// <copyright file="DeployOptions.cs" company="Ultimate Software">
// Copyright (c) Ultimate Software. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.
// </copyright>

using CommandLine;

namespace DDI.SqlDeploy.CommandLine
{
    [Verb("deploy", HelpText = "Deploy scripts to the database.")]
    internal class DeployOptions
    {
        [Option(
             shortName: 'C',
             longName: "ConnectionString",
             HelpText = "The SQL connection string to deploy to.",
             Required = true)]
        public string ConnectionString { get; set; }

        [Option(
             shortName: 'I',
             longName: "SetupScriptsDirectory",
             HelpText = "The path to the Setup Scripts Directory.")]
        public string SetupScriptsDirectory { get; set; }

        [Option(
            shortName: 'O',
            longName: "ProgrammableObjectsScriptsDirectory",
            HelpText = "The path to the Run Programmable Objects Scripts Directory.")]
        public string ProgrammableObjectsScriptsDirectory { get; set; }

        [Option(
             shortName: 'A',
             longName: "RunAlwaysScriptDirectory",
             HelpText = "The path to the Run Always Scripts Directory.")]
        public string RunAlwaysScriptsDirectory { get; set; }

        [Option(
             shortName: 'D',
             longName: "TestDataDirectory",
             HelpText = "The path to the Test Data Directory.")]
        public string TestDataDirectory { get; set; }

        internal string SqlDatabaseName { get; set; }

        [Option(
             shortName: 'R',
             longName: "PerformDropAndRecreate",
             HelpText = "The path to the Setup Scripts Directory.",
             Default = false)]
        public bool PerfromDropAndRecreate { get; set; }

        [Option(
             shortName: 'P',
             longName: "PreDeployScriptDirectory",
             HelpText = "The path to the Pre-Deploy Scripts Directory.")]
        public string PreDeployScriptsDirectory { get; set; }

        [Option(
            shortName: 'N',
            longName: "NonTransactionalScriptsDirectory",
            HelpText = "The path to the Non-Transactional Scripts Directory.")]
        public string NonTransactionalScriptsDirectory { get; set; }

        [Option(
            shortName: 'J',
            longName: "SqlJobsDirectory",
            HelpText = "The path to the SQL Jobs Scripts Directory.")]
        public string SqlJobsDirectory { get; set; }

        [Option(
            longName: "ApplyJobsOnly",
            HelpText = "Apply SQL Jobs Only")]
        public bool ApplySqlJobsOnly { get; set; }
    }
}