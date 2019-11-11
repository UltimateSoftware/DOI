// <copyright file="RecreateOptions.cs" company="Ultimate Software">
// Copyright (c) Ultimate Software. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.
// </copyright>

using CommandLine;

namespace DDI.SqlDeploy.CommandLine
{
    /// <summary>
    /// Options to drop and create the DB.
    /// </summary>
    [Verb("recreate", HelpText = "Drop and create the database.")]
    public class RecreateOptions
    {
        /// <summary>
        /// Gets or sets The connection string to the DB that will be recreated.
        /// </summary>
        [Option(
            shortName: 'C',
            longName: "ConnectionString",
            HelpText = "The SQL connection string to deploy to.",
            Required = true)]
        public string ConnectionString { get; set; }

        internal string SqlDatabaseName { get; set; }
    }
}