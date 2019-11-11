﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reporting.Ingestion.Integration.Tests.Database.DataDrivenIndexEngine.Models
{
    public class PartitionFunctionBoundary
    {
        public string Name { get; set; }
        public string Type { get; set; }
        public bool BoundaryValueOnRight { get; set; }
        public int BoundaryId { get; set; }
        public DateTime Value { get; set; }
    }
}
