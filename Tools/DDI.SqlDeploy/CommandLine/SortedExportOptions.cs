// <copyright file="SortedExportOptions.cs" company="Ultimate Software">
// Copyright (c) Ultimate Software. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.
// </copyright>

using System;
using CommandLine;

namespace DDI.SqlDeploy.CommandLine
{
    /// <summary>
    /// Options to export verb
    /// </summary>
    [Verb("sortedexport", HelpText = "Merge and export sorted scripts to a single file.")]
    public class SortedExportOptions
    {
        /// <summary>
        /// Gets or sets The bacth separator.
        /// </summary>
        [Option(
            shortName: 'S',
            longName: "BatchSeparator",
            HelpText = "SQL Batch separator to use when merging files. Defaults to /",
            Default = "/")]
        public string BatchSeparator { get; set; }

        /// <summary>
        /// Gets or sets The export output directory.
        /// </summary>
        [Option(
            shortName: 'X',
            longName: "OutputDirectory",
            HelpText = "Path of save the exported files.",
            Required = true)]
        public string OutputDirectory { get; set; }

        /// <summary>
        /// Gets or sets The export output filename.
        /// </summary>
        [Option(
            shortName: 'F',
            longName: "OutputFile",
            HelpText = "Path of save the exported files.")]
        public string OutputFile { get; set; } = $"{DateTime.UtcNow.Ticks}_{Guid.NewGuid():N}.sql";

        /// <summary>
        /// Gets or sets Driver file with scripts listed in processing order.
        /// </summary>
        [Option(
            shortName: 'R',
            longName: "ScriptsOrderFile",
            HelpText = "Driver file with scripts listed in processing order.",
            Required = true)]
        public string ScriptsOrderFile { get; set; }

        /// <summary>
        /// Gets or sets Sorted script files base directory.
        /// </summary>
        [Option(
            shortName: 'B',
            longName: "BaseDirectory",
            HelpText = "Sorted script files base directory.",
            Required = true)]
        public string BaseDirectory { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether Add the script type as a comment in the final export file for each type section.
        /// </summary>
        [Option(
            shortName: 'H',
            longName: "AddScriptTypeAsHeader",
            HelpText = "Add the script type as a comment header in the final export file for each type section.")]
        public bool AddScriptTypeAsHeader { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether Exclude 'WHENEVER SQLERROR EXIT FAILURE' from the header.
        /// </summary>
        [Option(
            shortName: 'E',
            longName: "SuppressErrrCtrlHdr",
            HelpText = "Do not include 'WHENEVER SQLERROR EXIT FAILURE' in the header.",
            Default = false,
            Required = false)]
        public bool SuppressErrorControlHeader { get; set; }
    }
}