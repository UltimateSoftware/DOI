using System;
using System.Data.Entity;
using System.Linq;
using DDI.Tests.Integration.IntegrationTests.Models;
using DDI.Tests.TestHelpers.CommonSetup.Logging;
using DDI.Tests.TestHelpers.DataAccess.SqlDataStore;
using DDI.Tests.TestHelpers.CommonSetup.Hosting.DataAccess;

namespace DDI.Tests.TestHelpers.CommonSetup
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
