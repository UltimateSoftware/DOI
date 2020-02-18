using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DDI.Tests.TestHelpers.DataAccess
{
    public class BulkCreateResults
    {
        public bool Success;
        public IList<int> FailedIndices;
    }
}
