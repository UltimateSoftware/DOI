using System;
using System.Configuration;
using System.Security;
using DDI.Tests.TestHelpers.CommonSetup.Hosting;
using DDI.Tests.TestHelpers.CommonSetup.Logging;
using DDI.Tests.TestHelpers.CommonSetup.Security;
using DDI.Tests.TestHelpers.CommonSetup.Security.KeyServer;
using DDI.Tests.TestHelpers.DataAccess.SqlDataStore;
using MongoDB.Driver;

namespace DDI.Tests.TestHelpers.DataAccess
{
    /// <summary>
    /// Class provides connection strings to the database and serves as an abstraction layer for this information.
    /// </summary>
    public class DbConnectivityProvider : IDatabaseConnectivityProvider
    {
        private readonly IUteSqlDbCredentialsProvider uteSqlDbCredentialsProvider;
        private readonly IMongoDbCredentialsProvider mongoDbCredentialsProvider;
        private readonly IMongoDbCredentialsProvider mongoDbReportingCredentialsProvider;
        private readonly IReadOnlySqlDbCredentialsProvider readOnlySqlDbCredentialsProvider;
        private readonly IAmendmentsSqlDbCredentialsProvider amendmentsSqlDbCredentialsProvider;
        private readonly IAppLogger logger;

        /// <summary>
        /// Default constructor.
        /// </summary>
        /// <param name="uteSqlDbCredentialsProvider">UltiPro Tax Engine SQL DB credentials provider</param>
        /// <param name="readOnlySqlDbCredentialsProvider">UltiPro Tax Engine Read Only SQL DB credentials provider</param>
        /// <param name="mongoDbCredentialsProvider">MongoDB credentials provider</param>
        /// <param name="logger">The logger.</param>
        /// <param name="mongoDbReportingCredentialsProvider">MongoDB reporting credentials provider</param>
        /// <param name="amendmentsSqlDbCredentialsProvider">Amendments SQL DB credentials provider</param>
        public DbConnectivityProvider(
            IUteSqlDbCredentialsProvider uteSqlDbCredentialsProvider,
            IReadOnlySqlDbCredentialsProvider readOnlySqlDbCredentialsProvider,
            IMongoDbCredentialsProvider mongoDbCredentialsProvider,
            IAppLogger logger,
            IMongoDbCredentialsProvider mongoDbReportingCredentialsProvider,
            IAmendmentsSqlDbCredentialsProvider amendmentsSqlDbCredentialsProvider)
        {
            this.uteSqlDbCredentialsProvider = uteSqlDbCredentialsProvider;
            this.readOnlySqlDbCredentialsProvider = readOnlySqlDbCredentialsProvider;
            this.mongoDbCredentialsProvider = mongoDbCredentialsProvider;
            this.mongoDbReportingCredentialsProvider = mongoDbReportingCredentialsProvider;
            this.amendmentsSqlDbCredentialsProvider = amendmentsSqlDbCredentialsProvider;
            this.logger = logger;
        }

        /// <summary>
        /// Method returns the requested database connection string.
        /// </summary>
        /// <param name="kind">The database kind.</param>
        /// <returns>Returns database connection string.</returns>
        public virtual string GetDatabaseConnectionString(DatabaseKind kind)
        {
            var connStringName = this.GetConnectionStringName(kind);

            if (this.IsSql(kind))
            {
                if (this.IsAmendmentsSql(kind))
                {
                    Convention.ThrowIfNull(this.amendmentsSqlDbCredentialsProvider, "amendmentsSqlDbCredentialsProvider");
                }

                var sqlConnectionStringBuilder = new SqlConnectionStringBuilder(this.IsAmendmentsSql(kind)
                    ? (ICredentialsProvider)this.amendmentsSqlDbCredentialsProvider
                    : this.uteSqlDbCredentialsProvider);
                var baseConnectionString = this.GetBaseConnectionString(connStringName);
                return sqlConnectionStringBuilder.BuildConnectionString(baseConnectionString);
            }

            if (this.IsReadOnlySql(kind))
            {
                var sqlConnectionStringBuilder = new SqlConnectionStringBuilder(this.readOnlySqlDbCredentialsProvider);
                var baseConnectionString = this.GetBaseConnectionString(connStringName);
                return sqlConnectionStringBuilder.BuildConnectionString(baseConnectionString, System.Data.SqlClient.ApplicationIntent.ReadOnly);
            }

            var mongoConnectionString = this.GetBaseConnectionString(connStringName);
            var mongoUrlBuilder = new MongoUrlBuilder(mongoConnectionString);

            var mongoProvider = kind == DatabaseKind.ReportingEventArchiveMigratorOnly
                ? this.mongoDbReportingCredentialsProvider
                : this.mongoDbCredentialsProvider;

            if (!mongoProvider.HasCredentials())
            {
                mongoProvider.LoadCredentials()
                    .ConfigureAwait(false)
                    .GetAwaiter()
                    .GetResult();
            }

            if (mongoProvider.HasCredentials())
            {
                var creds = mongoProvider.GetCredentials();
                mongoUrlBuilder.Username = creds.UserName.ReadAsString();
                mongoUrlBuilder.Password = creds.Password.ReadAsString();
                return mongoUrlBuilder.ToString();
            }

            return mongoUrlBuilder.ToString();
        }

        protected string GetConnectionStringName(DatabaseKind kind)
        {
            string connStringName;
            switch (kind)
            {
                case DatabaseKind.DbDefault:
                    connStringName = "taxHubAggregatesStore";
                    break;
                case DatabaseKind.MongoDbDefault:
                    connStringName = "eventStoreMongoDb";
                    break;
                case DatabaseKind.EventStore:
                    connStringName = "eventStoreMongoDb";
                    break;
                case DatabaseKind.Audit:
                    connStringName = "taxHubAuditStore";
                    break;
                case DatabaseKind.LogStore:
                    connStringName = "logStoreMongoDB";
                    break;
                case DatabaseKind.HistoricalDataPriorToUte:
                    connStringName = "HistoricalDataPriorToUteSqlDB";
                    break;
                case DatabaseKind.Ptm:
                    connStringName = "ConnectionString";
                    break;
                case DatabaseKind.PtmReadOnly:
                    connStringName = "ConnectionString";
                    break;
                case DatabaseKind.Reporting:
                    connStringName = "reportingConnectionString";
                    break;
                case DatabaseKind.ReportingReadOnly:
                    connStringName = "reportingConnectionString";
                    break;
                case DatabaseKind.ReportingEventArchiveMigratorOnly:
                    connStringName = "reportAggregateEventArchive";
                    break;
                case DatabaseKind.UltiProIntegrationMongo:
                    connStringName = "ultiProIntegrationMongoDb";
                    break;
                case DatabaseKind.DbAmendments:
                    connStringName = "taxHubAmendmentStore";
                    break;
                case DatabaseKind.HistAmendments:
                    connStringName = "taxHubHistAmendmentStore";
                    break;
                default:
                    throw new Exception($"Database kind {kind} is not defined.");
            }

            return connStringName;
        }

        public bool IsSql(DatabaseKind kind)
        {
            return kind == DatabaseKind.Ptm
                   || kind == DatabaseKind.DbDefault
                   || kind == DatabaseKind.DbAmendments
                   || kind == DatabaseKind.HistAmendments
                   || kind == DatabaseKind.Reporting
                   || kind == DatabaseKind.HistoricalDataPriorToUte;
        }

        protected bool IsReadOnlySql(DatabaseKind kind)
        {
            return kind == DatabaseKind.PtmReadOnly || kind == DatabaseKind.ReportingReadOnly;
        }

        protected bool IsAmendmentsSql(DatabaseKind kind)
        {
            return kind == DatabaseKind.DbAmendments || kind == DatabaseKind.HistAmendments;
        }

        protected bool IsMongo(DatabaseKind kind)
        {
            return !this.IsSql(kind);
        }

        protected virtual string GetBaseConnectionString(string connStringName)
        {
            string connString = ConfigurationManager.ConnectionStrings[connStringName].ToString();
            Convention.ThrowIfNullOrWhitespace(connString, $"Database connection string {connStringName} cannot be null.");
            return connString;
        }
    }
}
