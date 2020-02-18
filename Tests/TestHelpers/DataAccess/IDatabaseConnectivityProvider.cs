using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DDI.Tests.TestHelpers.DataAccess
{
    /// <summary>
    /// Interface implemented by the class providing connection strings to the database and serves as an abstraction layer for this information.
    /// </summary>
    public interface IDatabaseConnectivityProvider
    {
        string GetDatabaseConnectionString(DatabaseKind kind);

        /// <summary>
        /// Determine if the database is a SQL database.
        /// </summary>
        /// <param name="kind">Enumeration for the database kind that is defined by the application use purpose</param>
        /// <returns>True if the database is a SQL database.</returns>
        bool IsSql(DatabaseKind kind);
    }

    /// <summary>
    /// Enumeration for the database kind that is defined by the application use purpose: storing aggregates, events data, log data, etc.
    /// </summary>
    public enum DatabaseKind
    {
        DbDefault = 0,
        EventStore = 1,
        Audit = 2,
        LogStore = 3,
        Ptm = 4,
        MongoDbDefault = 6,
        Reporting = 7,
        PtmReadOnly = 8,
        ReportingEventArchiveMigratorOnly = 9,
        UltiProIntegrationMongo = 10,
        ReportingReadOnly = 11,
        HistoricalDataPriorToUte = 12,
        DbAmendments = 13,
        HistAmendments = 14
    }
}
