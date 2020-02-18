using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using DDI.Tests.TestHelpers.CommonSetup.Logging;
using DDI.Tests.TestHelpers.CommonSetup.Models;
using DDI.Tests.TestHelpers.DataAccess;
using DDI.Tests.TestHelpers.DataAccess.SqlDataStore;
using SmartHub.Hosting.DataAccess;

namespace DDI.Tests.TestHelpers.CommonSetup
{
    public abstract class SqlServerBaseRepository<TSource, TKey> : SqlServerSimpleRepository<TSource, TKey>
        where TSource : Aggregate<TKey>
    {
        protected SqlServerBaseRepository(IDbContextFactory dbContextFactory, IAppLogger logger)
            : base(dbContextFactory, logger)
        {
        }

        public async Task<long> Count(Guid tenantId, CancellationToken cancellationToken = default(CancellationToken))
        {
            return await this.CountByExpression(o => o.TenantId == tenantId, cancellationToken);
        }

        public virtual async Task<IEnumerable<TSource>> FindAll(Guid tenantId, CancellationToken cancellationToken = default(CancellationToken))
        {
            return await this.FindAllByExpression(o => o.TenantId == tenantId, cancellationToken);
        }

        public virtual async Task<IEnumerable<TSource>> FindAll(Guid tenantId, PagedDataParameters pageParams, CancellationToken cancellationToken = default(CancellationToken))
        {
            return await this.FindAllByExpression(o => o.TenantId == tenantId, pageParams, cancellationToken);
        }
    }
}
