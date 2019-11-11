﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reporting.Ingestion.Integration.Tests.Database.DataDrivenIndexEngine.Models
{
    public class ForeignKey
    {
        public string ParentSchemaName { get; set; }

        public string ParentTableName { get; set; }

        public string ParentColumnList { get; set; }

        public string ReferencedSchemaName { get; set; }

        public string ReferencedTableName { get; set; }

        public string ReferencedColumnList { get; set; }

        public string FKName { get; set; }

        public string CreateFKSQL { get; set; }
    }
}
