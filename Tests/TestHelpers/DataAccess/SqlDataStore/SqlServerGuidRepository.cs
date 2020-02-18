﻿using System;
using System.Collections.Generic;
using System.Data.Entity.Infrastructure;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using DDI.Tests.TestHelpers.CommonSetup;
using DDI.Tests.TestHelpers.CommonSetup.Logging;
using DDI.Tests.TestHelpers.CommonSetup.Models;
using DDI.Tests.TestHelpers.DataAccess;
using DDI.Tests.TestHelpers.DataAccess.SqlDataStore;

namespace DDI.Tests.TestHelpers.CommonSetup
{
    public abstract class SqlServerGuidRepository<TSource> : SqlServerBaseRepository<TSource, Guid>,
        IRepository<TSource, Guid>
        where TSource : Aggregate<Guid>
    {
        protected SqlServerGuidRepository(IDbContextFactory dbContextFactory, IAppLogger logger)
            : base(dbContextFactory, logger)
        {
        }

        public async Task<bool> Contains(Guid tenantId, Guid id, CancellationToken cancellationToken = default(CancellationToken))
        {
            return await this.ContainsByExpression(o => o.TenantId == tenantId && o.Id == id, cancellationToken);
        }

        public override async Task<bool> Contains(Guid id, CancellationToken cancellationToken = default(CancellationToken))
        {
            return await this.ContainsByExpression(o => o.Id == id, cancellationToken);
        }

        public async Task<TSource> FindOne(Guid tenantId, Guid id, CancellationToken cancellationToken = default(CancellationToken))
        {
            return await this.FindOneByExpression(o => o.TenantId == tenantId && o.Id == id, cancellationToken);
        }

        public override async Task<TSource> FindOne(Guid id, CancellationToken cancellationToken = new CancellationToken())
        {
            return await this.FindOneByExpression(o => o.Id == id, cancellationToken);
        }
    }
}