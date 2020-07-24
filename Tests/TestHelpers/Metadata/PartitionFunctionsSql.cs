using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Threading.Tasks;
using Models = DOI.Tests.Integration.Models;

namespace DOI.Tests.TestHelpers.Metadata
{
    public static class PartitionFunctionsSql
    {
        public static string PartitionFunction_Setup = @"
INSERT INTO DOI.PartitionFunctions  (PartitionFunctionName	,PartitionFunctionDataType	,BoundaryInterval	,NumOfFutureIntervals	, InitialDate	, UsesSlidingWindow	, SlidingWindowSize	, IsDeprecated)
VALUES		                        ('pfMonthlyTest'		, 'DATETIME2'				, 'Monthly'			, 1					    , '2019-08-01'	, 0					, NULL				, 0)";

        public static string PartitionFunction_TearDown = @"
DELETE DOI.PartitionFunctions 
WHERE PartitionFunctionName = 'pfMonthlyTest'";
    }
}
