// <copyright file="SubFile.cs" company="Ultimate Software">
// Copyright (c) Ultimate Software. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.
// </copyright>

using System.IO;
using System.Text.RegularExpressions;

namespace DDI.SqlDeploy.IO
{
    /// <summary>
    /// Object represents a file with various properties based on full path to file with file name
    /// </summary>
    public class SubFile
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="SubFile"/> class.
        /// Initializes a new instance of file DTO object that contains properties based on full path to a file
        /// </summary>
        /// <param name="filenameWithFullPathParameter">full path to file</param>
        /// <param name="isSetup">Used to denote if file should be treated as a setup file</param>
        public SubFile(string filenameWithFullPathParameter, bool isSetup = true)
        {
            this.IsSetup = isSetup;
            this.FileNameWithPath = filenameWithFullPathParameter;
            this.FileName = Path.GetFileName(filenameWithFullPathParameter);
            this.FileNameWithoutExtension = Path.GetFileNameWithoutExtension(filenameWithFullPathParameter)?.Replace('-', ' ').Replace('_', ' ').Trim();

            // build regex to get id number and description
            Regex regexFileName = new Regex(@"^(\d+)");
            string changeNumberString = this.FileNameWithoutExtension != null && regexFileName.IsMatch(this.FileNameWithoutExtension) ? regexFileName.Match(this.FileNameWithoutExtension).Groups[0].Value : "-1";

            // id number should be first number encountered
            this.ChangeNumber = int.Parse(changeNumberString);
            if (this.ChangeNumber == -1)
            {
                this.IsChangeNumberSet = false;
                this.Description = this.FileNameWithoutExtension;
            }
            else
            {
                // if filename without extension is not null or blank, set description based on filename, exclude changeNumber
                this.Description = !string.IsNullOrWhiteSpace(this.FileNameWithoutExtension) ? this.FileNameWithoutExtension.Substring(changeNumberString.Length).Trim() : string.Empty;
            }
        }

        /// <summary>
        /// Gets a value indicating whether Used to denote if a file should be treated as a setup script.
        /// </summary>
        public bool IsSetup { get; private set; }

        /// <summary>
        /// Gets a value indicating whether first integer value in prefix of the file
        /// </summary>
        public int ChangeNumber { get; }

        /// <summary>
        /// Gets a value indicating whether flag to indicate whether or not change number was set
        /// </summary>
        public bool IsChangeNumberSet { get; private set; } = true;

        /// <summary>
        /// Gets a value indicating whether contains full path to file
        /// </summary>
        public string FileNameWithPath { get; private set; }

        /// <summary>
        /// Gets a value indicating whether contains filename
        /// </summary>
        public string FileName { get; private set; }

        /// <summary>
        /// Gets a value indicating whether contains filename excluding extension
        /// </summary>
        public string FileNameWithoutExtension { get; private set; }

        /// <summary>
        /// Gets a value indicating whether Same thing as Filename without extension
        /// </summary>
        public string Description { get; }
    }
}
