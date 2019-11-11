using System;
using System.Data.Entity;
using System.Linq;
using System.Threading;
using Reporting.Ingestion.Models;
using TaxHub.Common.DataAccess.SqlDataStore;
using TaxHub.Common.Logging;
using TaxHub.Hosting.DataAccess;

namespace Reporting.TestHelpers.CommonSetup
{
    public class SetupRepository<TSource> : SqlServerGuidRepository<TSource>
        where TSource : AggregateViewBase<TSource>
    {
        public SetupRepository(IDbContextFactory dbContextFactory, IAppLogger logger)
            : base(dbContextFactory, logger)
        {
        }

        public virtual bool CleanUp(Guid id)
        {
            var aggretate = this.FindOne(id)?.Result;

            return aggretate == null || this.Delete(aggretate).Result;
        }

        public override IQueryable<TSource> GetAggregateSet(DbContext dbContext)
        {
            return dbContext.Set<TSource>();
        }
    }
}
