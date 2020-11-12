using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.IntegrationTests.Models
{
    public class Statistics
    {
        public string DatabaseName { get; set; }
        public string SchemaName { get; set; }
        public string TableName { get; set; }
        public string StatisticsName { get; set; }
        public bool IsStatisticsMissingFromSQLServer { get; set; }
        public string StatisticsColumnList_Desired { get; set; }
        public string StatisticsColumnList_Actual { get; set; }
        public int SampleSizePct_Desired { get; set; }
        public int SampleSizePct_Actual { get; set; }
        public bool IsFiltered_Desired { get; set; }
        public bool IsFiltered_Actual { get; set; }
        public string FilterPredicate_Desired { get; set; }
        public string FilterPredicate_Actual { get; set; }
        public bool IsIncremental_Desired { get; set; }
        public bool IsIncremental_Actual { get; set; }
        public bool NoRecompute_Desired { get; set; }
        public bool NoRecompute_Actual { get; set; }
        public bool LowerSampleSizeToDesired { get; set; }
        public bool ReadyToQueue { get; set; }
        public bool DoesSampleSizeNeedUpdate { get; set; }
        public bool IsStatisticsMissing { get; set; }
        public bool HasFilterChanged { get; set; }
        public bool HasIncrementalChanged { get; set; }
        public bool HasNoRecomputeChanged { get; set; }
        public int NumRowsInTableUnfiltered { get; set; }
        public int NumRowsInTableFiltered { get; set; }
        public int NumRowsSampled { get; set; }
        public DateTime StatisticsLastUpdated { get; set; }
        public int HistogramSteps { get; set; }
        public int StatisticsModCounter { get; set; }
        public double PersistedSamplePct { get; set; }
        public string StatisticsUpdateType { get; set; }
        public string ListOfChanges { get; set; }
        public bool IsOnlineOperation { get; set; }
    }
}