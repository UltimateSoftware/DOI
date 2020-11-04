using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class ForeignKeys
    {
        public string DatabaseName { get; set; }
        public string ParentSchemaName { get; set; }
        public string ParentTableName { get; set; }
        public string FKName { get; set; }
        public string ParentColumnList_Desired { get; set; }
        public string ReferencedSchemaName { get; set; }
        public string ReferencedTableName { get; set; }
        public string ReferencedColumnList_Desired { get; set; }
        public string CreateFKSQL { get; set; }
        public string ParentColumnList_Actual { get; set; }
        public string ReferencedColumnList_Actual { get; set; }
        public string DeploymentTime { get; set; }
    }
}
