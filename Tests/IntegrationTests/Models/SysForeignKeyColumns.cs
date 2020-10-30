using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class SysForeignKeyColumns
    {
        public int database_id { get; set; }
        public int constraint_object_id { get; set; }
        public int constraint_column_id { get; set; }
        public int parent_object_id { get; set; }
        public int parent_column_id { get; set; }
        public int referenced_object_id { get; set; }
        public int referenced_column_id { get; set; }
    }
}
