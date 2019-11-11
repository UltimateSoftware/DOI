using System;
using System.Threading;
using MongoDB.Driver;
using TaxHub.Common.DataAccess;
using TaxHub.Common.DataAccess.MongoDbStore;
using TaxHub.Common.EventStore;
using TaxHub.Common.Logging;

namespace Reporting.Ingestion.Integration.Tests
{
    public class MongoDbReportingEventArchiveRepo : MongoDbRepositoryBase<DomainEventData, Guid>
    {
        public MongoDbReportingEventArchiveRepo(IRepositorySettings settings, IAppLogger logger)
            : base(settings, logger)
        {
        }

        public void DropCollection(string collectionName)
        {
            IMongoDatabase database = this.GetDatabase();
            database.DropCollection(collectionName);
        }

        public long CountRecordsInCollection(string collectionName, CancellationToken cancellationToken = default(CancellationToken))
        {
            IMongoCollection<DomainEventData> items = this.GetDbCollection<DomainEventData>(collectionName);
            return items.CountDocuments(x => x.AggregateId != null);
        }
    }
}
