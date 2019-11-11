using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reporting.Ingestion.Integration.Tests.Database.DataDrivenIndexEngine.Models
{
    public class Index
    {
        public string SchemaName { get; set; }

        public string TableName { get; set; }

        public string IndexName { get; set; }
    }
}
