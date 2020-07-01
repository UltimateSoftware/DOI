using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.Integration.Models
{
    public class LogTableRow
    {
        public string SchemaName { get; set; }

        public string TableName { get; set; }

        public string IndexName { get; set; }

        public string SQLStatement { get; set; }

        public string RunStatus { get; set; }

        public string ErrorText { get; set; }

        public Guid BatchId { get; set; }
    }
}