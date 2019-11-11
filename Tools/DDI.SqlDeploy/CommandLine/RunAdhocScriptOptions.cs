// <copyright file="RunAdhocScriptOptions.cs" company="Ultimate Software">
// Copyright (c) Ultimate Software. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.
// </copyright>

using CommandLine;

namespace DDI.SqlDeploy.CommandLine
{
    /// <summary>
    /// Options to drop and create the DB.
    /// </summary>
    [Verb("runadhocscript", HelpText = "Runs a single script.")]
    public class RunAdhocScriptOptions
    {
        /// <summary>
        /// Gets or sets The connection string to the DB that will be connected to.
        /// </summary>
        [Option(
            shortName: 'C',
            longName: "ConnectionString",
            HelpText = "The SQL connection string to deploy to.",
            Required = true)]
        public string ConnectionString { get; set; }

        /// <summary>
        /// Gets or sets The path to the SQL script to execute.
        /// </summary>
        [Option(
            shortName: 'P',
            longName: "FilePath",
            HelpText = "The path of the file to execute.",
            Required = true)]
        public string ScriptFilePath { get; set; }

        internal string SqlDatabaseName { get; set; }
    }
}