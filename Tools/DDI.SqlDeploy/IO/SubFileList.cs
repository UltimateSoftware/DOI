// <copyright file="SubFileList.cs" company="Ultimate Software">
// Copyright (c) Ultimate Software. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.
// </copyright>

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using DDI.SqlDeploy.Database;

namespace DDI.SqlDeploy.IO
{
    /// <summary>
    /// class generates dictionary of files
    /// </summary>
    public class SubFileList : Dictionary<int, SubFile>
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="SubFileList"/> class.
        /// Initializes a new instance of the dictionary of DTO file objects
        /// </summary>
        /// <param name="inputFilesDirectory">takes a string which is a path to a directory</param>
        /// <param name="isSetup">Used to denote if file is a setup file</param>
        public SubFileList(string inputFilesDirectory, bool isSetup)
        {
            var files = Directory.GetFiles(inputFilesDirectory, "*.sql", SearchOption.AllDirectories)
                .OrderBy(filename => filename);

            int generatedChangeNumber = 0;

            foreach (string filenameWithFullPath in files)
            {
                SubFile temp = new SubFile(filenameWithFullPath, isSetup);
                if (this.ContainsKey(temp.ChangeNumber))
                {
                    throw new Exception(
                        "File with same prefix integer detected\r\n" +
                        $"File 1: {this[temp.ChangeNumber].FileNameWithPath}\r\n" +
                        $"File 2: {temp.FileNameWithPath}\r\n");
                }

                if (temp.IsChangeNumberSet)
                {
                    generatedChangeNumber = temp.ChangeNumber;
                    this.Add(temp.ChangeNumber, temp);
                }
                else
                {
                    generatedChangeNumber++;
                    this.Add(generatedChangeNumber, temp);
                }
            }
        }

        private string MakeDiffQuery()
        {
            // if 0 or less, return empty string
            if (this.Count < 1)
            {
                return string.Empty;
            }

            // if 1 or greater
            StringBuilder queryStringB = new StringBuilder(string.Empty);

            // setup array to iterate through dictionary list values
            List<SubFile> fileArray = new List<SubFile>(this.Values);

            // setup first line to include column names
            queryStringB.Append("SELECT " + fileArray[0].ChangeNumber + " change_number,\r\n" +
                $"\t'{fileArray[0].Description}' description, \r\n" +
                $"\t{(fileArray[0].IsSetup ? 1 : 0)} is_setup \r\n");
            for (int i = 1; i < this.Count; i++)
            {
                queryStringB.Append("UNION ALL SELECT " + fileArray[i].ChangeNumber + $", " +
                    $"'{fileArray[i].Description}'" +
                    $", {(fileArray[0].IsSetup ? 1 : 0)} \r\n");
            }

            return queryStringB.ToString();
        }

        /// <summary>
        /// Method that will execute a query to perform a diff analysis between local files and files recorded on changelog table
        /// </summary>
        /// <param name="connectionString">connection string to connect to database</param>
        /// <returns>returns list of files to be applied in order</returns>
        public List<SubFile> GetSqlFilesToBeApplied(string connectionString)
        {
            List<string> sqlResultList;

            // producing query hear since this object's to string method generates query representing database files in current directory
            // build query to compare sql files in directory with change log
            var diffQuery = this.MakeDiffQuery();
            if (diffQuery != string.Empty)
            {
                string script = DatabaseScriptExecutor.BuildQueryWithHeaderAndFooter(
                    ".\\Database\\Scripts\\findAppliedScriptsHeader.sql",
                    diffQuery,
                    ".\\Database\\Scripts\\findAppliedScriptsFooter.sql");

                // sql results list contain a list of script ID's that have not yet been applied.
                // Add scripts that have not been applied to result list and return
                 sqlResultList = DatabaseScriptExecutor.ExecuteQueryAndReadResult(connectionString, script);
            }
            else
            {
                sqlResultList = this.Select(c => c.Value.FileName).ToList();
            }

            return sqlResultList.Select(sqlRow => int.Parse(sqlRow)).Select(subFileChangeNumber => (SubFile)this[subFileChangeNumber]).ToList();
        }

        /// <summary>
        /// Get all SQL files.
        /// </summary>
        /// <returns>The list of all files.</returns>
        public List<SubFile> GetAllSqlFiles()
        {
            var list = this.Values.ToList();
            return list;
        }
    }
}
