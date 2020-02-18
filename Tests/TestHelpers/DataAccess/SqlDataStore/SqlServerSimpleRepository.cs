using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;
using System.Data.SqlClient;
using System.Linq;
using System.Linq.Expressions;
using System.Reflection;
using System.Threading;
using System.Threading.Tasks;
using LinqKit;
using Microsoft.Practices.ObjectBuilder2;
using SmartHub.Hosting.DataAccess;
using DDI.Tests.TestHelpers.CommonSetup.EventStore;
using DDI.Tests.TestHelpers.CommonSetup.Extensions;
using DDI.Tests.TestHelpers.CommonSetup.Helpers;
using DDI.Tests.TestHelpers.CommonSetup.Logging;
using DDI.Tests.Integration.IntegrationTests.Models;
using DDI.Tests.TestHelpers.CommonSetup.Hosting.DataAccess;
using DDI.Tests.TestHelpers.CommonSetup.Hosting;
#pragma warning disable 618

namespace DDI.Tests.TestHelpers.DataAccess.SqlDataStore
{
    public abstract class SqlServerSimpleRepository<TSource, TKey> : ISimpleRepository<TSource, TKey>, IDisposable
        where TSource : Entity<TKey>
    {
        protected const int CannotInsertDuplicateKeyWithUniqueIndex = 2601;
        protected const int CannotInsertDuplicateKey = 2627;
        protected const int TransactionDeadlocked = 1205;

        protected DbContext context = null;
        protected readonly IDbContextFactory DbContextFactory;
        protected readonly IAppLogger Logger;

        public abstract IQueryable<TSource> GetAggregateSet(DbContext dbContext);

        protected SqlServerSimpleRepository(IDbContextFactory dbContextFactory, IAppLogger logger)
        {
            this.DbContextFactory = dbContextFactory;
            this.Logger = logger;
        }

        private async Task<bool> Update(DbContext context, TSource item, Action<DbEntityEntry<TSource>> setOriginalValues, CancellationToken cancellationToken, bool changesTracked = false)
        {
            try
            {
                if (!changesTracked)
                {
                    context.Set<TSource>().Attach(item);
                }

                var entry = context.Entry(item);
                setOriginalValues(entry);

                if (!changesTracked)
                {
                    entry.State = EntityState.Modified;
                }

                await context.SaveChangesAsync(cancellationToken);
                return true;
            }
            catch (DbUpdateConcurrencyException ex)
            {
                var entry = ex.Entries.Single();
                var databaseEntry = entry.GetDatabaseValues();
                if (databaseEntry == null)
                {
                    throw new Exception("Trying to update an entity that does not exist");
                }

                throw new DataVersioningException("The entity was modified by another user", ex);
            }
            catch (Exception ex)
            {
                if (ex.InnerException?.InnerException == null)
                {
                    throw;
                }

                var innerException = ex.InnerException.InnerException as SqlException;

                if (innerException != null && innerException.Number == TransactionDeadlocked)
                {
                    throw new DeadlockException("Deadlock exception has been detected. " + ex.Message, ex);
                }

                throw;
            }
        }

        protected async Task<bool> Update(TSource item, Action<DbEntityEntry<TSource>> setOriginalValues, CancellationToken cancellationToken)
        {
            if (this.IsInitializedWithDbContext)
            {
                return await this.Update(this.context, item, setOriginalValues, cancellationToken, true);
            }

            using (var dbContext = this.DbContextFactory.Create())
            {
                return await this.Update(dbContext, item, setOriginalValues, cancellationToken);
            }
        }

        /// <inheritdoc />
        public async Task<bool> BulkUpdate(IEnumerable<TSource> entitiesBatch, CancellationToken cancellationToken = default(CancellationToken), bool changesTracked = true)
        {
            if (this.IsInitializedWithDbContext)
            {
                return await this.Update(this.context, entitiesBatch, cancellationToken, true);
            }

            using (var dbContext = this.DbContextFactory.Create())
            {
                return await this.Update(dbContext, entitiesBatch, cancellationToken);
            }
        }

        private async Task<bool> Update(
            DbContext dbContext,
            IEnumerable<TSource> entitiesBatch,
            CancellationToken cancellationToken,
            bool changesTracked = false)
        {
            try
            {
                foreach (var entity in entitiesBatch)
                {
                    if (!changesTracked)
                    {
                        dbContext.Set<TSource>().Attach(entity);
                    }

                    var entry = dbContext.Entry(entity);
                    entry.OriginalValues["Version"] = entry.Entity.Version - 1;

                    if (!changesTracked)
                    {
                        entry.State = EntityState.Modified;
                    }
                }

                await dbContext.SaveChangesAsync(cancellationToken);
                return true;
            }
            catch (DbUpdateConcurrencyException ex)
            {
                var entry = ex.Entries.Single();
                var databaseEntry = entry.GetDatabaseValues();
                if (databaseEntry == null)
                {
                    throw new Exception("Trying to update an entity that does not exist");
                }

                throw new DataVersioningException("The entity was modified by another user", ex);
            }
            catch (Exception ex)
            {
                if (ex.InnerException?.InnerException == null)
                {
                    throw;
                }

                var innerException = ex.InnerException.InnerException as SqlException;

                if (innerException != null && innerException.Number == TransactionDeadlocked)
                {
                    throw new DeadlockException("Deadlock exception has been detected. " + ex.Message, ex);
                }

                throw;
            }
        }

        public abstract Task<TSource> FindOne(TKey id, CancellationToken cancellationToken = default(CancellationToken));

        /// <inheritdoc />
        public async Task<IEnumerable<TSource>> FindAllByIds(IEnumerable<TKey> ids, CancellationToken cancellationToken = new CancellationToken())
        {
            if (this.context != null)
            {
                return await this.FindAllByIds(this.context, ids, cancellationToken);
            }

            using (var dbContext = this.DbContextFactory.Create())
            {
                return await this.FindAllByIds(dbContext, ids, cancellationToken);
            }
        }

        private async Task<IEnumerable<TSource>> FindAllByIds(DbContext dbContext, IEnumerable<TKey> ids, CancellationToken cancellationToken = new CancellationToken())
        {
            return await this.FindAllByExpression(agg => ids.Contains(agg.Id), cancellationToken);
        }

        public virtual Task<IEnumerable<TSource>> FindAll(CancellationToken cancellationToken = default(CancellationToken))
        {
            return this.FindAllByExpression(_ => true, cancellationToken);
        }

        public virtual async Task<IEnumerable<TSource>> FindAll(PagedDataParameters pageParams, CancellationToken cancellationToken = default(CancellationToken))
        {
            return await this.FindAllByExpression(_ => true, pageParams, cancellationToken);
        }

        public Task<long> Count(CancellationToken cancellationToken = default(CancellationToken))
        {
            return this.CountByExpression(_ => true, cancellationToken);
        }

        public virtual async Task<bool> Create(TSource item, CancellationToken cancellationToken = default(CancellationToken))
        {
            Convention.ThrowIfNull(item, "item");
            await this.Insert(item, cancellationToken);
            return true;
        }

        private Task<bool> Insert(TSource item, CancellationToken cancellationToken)
        {
            return this.Insert(new[] { item }, cancellationToken);
        }

        private async Task<bool> Insert(DbContext context, IEnumerable<TSource> items, CancellationToken cancellationToken)
        {
            var collection = context.Set<TSource>();
            var itemsArray = items as TSource[] ?? items.ToArray();

            collection.AddRange(itemsArray);

            await context.SaveChangesAsync(cancellationToken);

            foreach (var item in itemsArray)
            {
                item.MarkAsPersisted();
            }

            return true;
        }

        private async Task<bool> Insert(IEnumerable<TSource> items, CancellationToken cancellationToken)
        {
            try
            {
                if (this.IsInitializedWithDbContext)
                {
                    return await this.Insert(this.context, items, cancellationToken);
                }

                using (var dbContext = this.DbContextFactory.Create())
                {
                    return await this.Insert(dbContext, items, cancellationToken);
                }
            }
            catch (Exception ex)
            {
                if (ex.InnerException?.InnerException == null)
                {
                    throw;
                }

                var innerException = ex.InnerException.InnerException as SqlException;
                if (innerException != null &&
                    (
                        innerException.Number == CannotInsertDuplicateKey ||
                        innerException.Number == CannotInsertDuplicateKeyWithUniqueIndex))
                {
                    throw new DuplicateKeyException("Duplicated data key conflict has been detected. " + ex.Message, ex);
                }

                if (innerException != null && innerException.Number == TransactionDeadlocked)
                {
                    throw new DeadlockException("Deadlock exception has been detected. " + ex.Message, ex);
                }

                throw;
            }
        }

        public virtual Task<bool> Update(TKey id, TSource item, CancellationToken cancellationToken = default(CancellationToken))
        {
            return this.Update(
                item,
                o =>
                {
                    o.OriginalValues["Version"] = item.Version - 1;
                },
                cancellationToken);
        }

        public virtual Task<bool> Update(TKey id, int expectedVersion, TSource item, CancellationToken cancellationToken = default(CancellationToken))
        {
            return this.Update(
                item,
                o =>
                {
                    o.OriginalValues["Version"] = expectedVersion;
                },
                cancellationToken);
        }

        public virtual Task<bool> Update(Guid tenantId, TKey id, TSource item, CancellationToken cancellationToken = default(CancellationToken))
        {
            return this.Update(id, item, cancellationToken);
        }

        public virtual Task<bool> Update(Guid tenantId, TKey id, int expectedVersion, TSource item, CancellationToken cancellationToken = default(CancellationToken))
        {
            return this.Update(id, expectedVersion, item, cancellationToken);
        }

        public virtual async Task<bool> Delete(TSource item, CancellationToken cancellationToken = default(CancellationToken))
        {
            if (this.IsInitializedWithDbContext)
            {
                return await this.Delete(this.context, item, cancellationToken);
            }

            using (var dbContext = this.DbContextFactory.Create())
            {
                return await this.Delete(dbContext, item, cancellationToken);
            }
        }

        private async Task<bool> Delete(DbContext context, TSource item, CancellationToken cancellationToken = default(CancellationToken))
        {
            try
            {
                if (!this.IsInitializedWithDbContext)
                {
                    context.Set<TSource>().Attach(item);
                }

                context.Entry(item).State = EntityState.Deleted;
                await context.SaveChangesAsync(cancellationToken);
                return true;
            }
            catch (DbUpdateConcurrencyException ex)
            {
                throw new DataVersioningException("The entity was modified by another user", ex);
            }
        }

        public virtual async Task<bool> DeleteInCascade(TSource item, CancellationToken cancellationToken = default(CancellationToken))
        {
            if (this.IsInitializedWithDbContext)
            {
                return await this.DeleteInCascade(this.context, item, true, cancellationToken);
            }

            using (var dbContext = this.DbContextFactory.Create())
            {
                return await this.DeleteInCascade(dbContext, item, true, cancellationToken);
            }
        }

        private async Task<bool> DeleteInCascade(DbContext context, TSource item, bool useOptimisticConcurrency, CancellationToken cancellationToken = default(CancellationToken))
        {
            try
            {
                // i => i.Id == item.Id
                var arg = Expression.Parameter(typeof(TSource), "i");
                var predicate =
                    Expression.Lambda<Func<TSource, bool>>(
                        Expression.Equal(Expression.Property(arg, "Id"), Expression.Constant(item.Id)),
                        arg);

                var dbItem = await this.GetAggregateSet(context)
                    .FirstOrDefaultAsync(predicate, cancellationToken);
                if (dbItem == null)
                {
                    return true;
                }

                if (useOptimisticConcurrency)
                {
                    context.SetOriginalVersion(dbItem, item.Version);
                }

                context.Set<TSource>().Remove(dbItem);
                await context.SaveChangesAsync(cancellationToken);
                return true;
            }
            catch (DbUpdateConcurrencyException ex)
            {
                throw new DataVersioningException("The entity was modified by another user", ex);
            }
        }

        public abstract Task<bool> Contains(TKey id, CancellationToken cancellationToken = default(CancellationToken));

        public async Task<BulkCreateResults> BulkCreate(IEnumerable<TSource> items, CancellationToken cancellationToken = default(CancellationToken))
        {
            Convention.ThrowIfNull(items, "items");

            BulkCreateResults result = new BulkCreateResults()
            {
                Success = true,
                FailedIndices = new List<int>()
            };

            var enumerable = items as IList<TSource> ?? items.ToList();
            try
            {
                await this.Insert(enumerable, cancellationToken);
            }
            catch (DuplicateKeyException ex)
            {
                result.Success = false;
                this.Logger.Error(ex);

                // If one insert fails then they all fail
                Enumerable.Range(0, enumerable.Count()).ForEach(x => result.FailedIndices.Add(x));
            }

            return result;
        }

        private async Task<TSource> FindOneByExpression(DbContext context, Expression<Func<TSource, bool>> expression, CancellationToken cancellationToken)
        {
            return await this.GetAggregateSet(context).FirstOrDefaultAsync(expression, cancellationToken);
        }

        protected virtual async Task<TSource> FindOneByExpression(Expression<Func<TSource, bool>> expression, CancellationToken cancellationToken)
        {
            if (this.IsInitializedWithDbContext)
            {
                return await this.FindOneByExpression(this.context, expression, cancellationToken);
            }

            using (var dbContext = this.DbContextFactory.Create())
            {
                return await this.FindOneByExpression(dbContext, expression, cancellationToken);
            }
        }

        private async Task<IEnumerable<TSource>> FindAllByExpression(DbContext context, Expression<Func<TSource, bool>> expression, CancellationToken cancellationToken)
        {
            var collection = this.GetAggregateSet(context);
            return await collection.Where(expression).ToListAsync(cancellationToken);
        }

        protected virtual async Task<IEnumerable<TSource>> FindAllByExpression(Expression<Func<TSource, bool>> expression, CancellationToken cancellationToken)
        {
            if (this.IsInitializedWithDbContext)
            {
                return await this.FindAllByExpression(this.context, expression, cancellationToken);
            }

            using (var dbContext = this.DbContextFactory.Create())
            {
                return await this.FindAllByExpression(dbContext, expression, cancellationToken);
            }
        }

        private async Task<IEnumerable<TSource>> FindAllByExpression(DbContext context, Expression<Func<TSource, bool>> expression, PagedDataParameters pageParams, CancellationToken cancellationToken)
        {
            var dbSet = this.GetAggregateSet(context);
            var promise = pageParams.HasSortBy()
                ? dbSet.OrderBy(pageParams.Sortings)
                : dbSet.OrderBy(o => o.Id);

            return await promise
                .Where(expression)
                .Skip(pageParams.PageSize * (pageParams.PageNumber - 1))
                .Take(pageParams.PageSize)
                .ToListAsync(cancellationToken);
        }

        protected async Task<IEnumerable<TSource>> FindAllByExpression(DbContext dbContext, PagedDataParameters pageParams, CancellationToken cancellationToken)
        {
            var dbSet = this.GetAggregateSet(dbContext);
            var promise = pageParams.HasSortBy()
                ? dbSet.OrderBy(pageParams.Sortings)
                : dbSet.OrderBy(o => o.Id);

            return await promise
                .Skip(pageParams.PageSize * (pageParams.PageNumber - 1))
                .Take(pageParams.PageSize)
                .ToListAsync(cancellationToken);
        }

        protected virtual async Task<IEnumerable<TSource>> FindAllByExpression(Expression<Func<TSource, bool>> expression, PagedDataParameters pageParams, CancellationToken cancellationToken)
        {
            if (this.IsInitializedWithDbContext)
            {
                return await this.FindAllByExpression(this.context, expression, pageParams, cancellationToken);
            }

            using (var dbContext = this.DbContextFactory.Create())
            {
                return await this.FindAllByExpression(dbContext, expression, pageParams, cancellationToken);
            }
        }

        private async Task<long> CountByExpression(DbContext context, Expression<Func<TSource, bool>> expression, CancellationToken cancellationToken)
        {
            return await context.Set<TSource>().CountAsync(expression, cancellationToken);
        }

        protected async Task<long> CountByExpression(Expression<Func<TSource, bool>> expression, CancellationToken cancellationToken)
        {
            if (this.IsInitializedWithDbContext)
            {
                return await this.CountByExpression(this.context, expression, cancellationToken);
            }

            using (var dbContext = this.DbContextFactory.Create())
            {
                return await this.CountByExpression(dbContext, expression, cancellationToken);
            }
        }

        private async Task<bool> ContainsByExpression(DbContext context, Expression<Func<TSource, bool>> expression, CancellationToken cancellationToken = default(CancellationToken))
        {
            return await context.Set<TSource>().AnyAsync(expression, cancellationToken);
        }

        protected async Task<bool> ContainsByExpression(Expression<Func<TSource, bool>> expression, CancellationToken cancellationToken = default(CancellationToken))
        {
            if (this.IsInitializedWithDbContext)
            {
                return await this.ContainsByExpression(this.context, expression, cancellationToken);
            }

            using (var dbContext = this.DbContextFactory.Create())
            {
                return await this.ContainsByExpression(dbContext, expression, cancellationToken);
            }
        }

        private async Task ApplyToEach(DbContext context, Func<TSource, Task> action, IAggregateSnapshotFilter filters, CancellationToken cancellationToken = default(CancellationToken))
        {
            var filterExpression = this.CreateFilterExpression(filters);

            var collection = this.GetAggregateSet(context);

            var entities = await collection.Where(filterExpression).ToListAsync(cancellationToken);

            entities.ForEach(async e =>
            {
                await action(e);
            });
        }

        /// <summary>
        /// Applies an action to each aggregate returned from the filters in filter params.
        /// </summary>
        /// <param name="action">The action to apply to each aggregate.</param>
        /// <param name="filters">The filters to find aggregates by.</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>A task.</returns>
        public async Task ApplyToEach(Func<TSource, Task> action, IAggregateSnapshotFilter filters, CancellationToken cancellationToken = default(CancellationToken))
        {
            if (this.IsInitializedWithDbContext)
            {
                await this.ApplyToEach(this.context, action, filters, cancellationToken);
            }
            else
            {
                using (var dbContext = this.DbContextFactory.Create())
                {
                    await this.ApplyToEach(dbContext, action, filters, cancellationToken);
                }
            }
        }

        private Expression<Func<TSource, bool>> CreateFilterExpression(IAggregateSnapshotFilter filters)
        {
            var predicate = PredicateBuilder.True<TSource>();
            var snapShotFilters = new List<Expression<Func<TSource, bool>>>();

            if (filters.HasAggregateId())
            {
                object id = null;
                if (typeof(TKey) == typeof(int))
                {
                    id = Convert.ChangeType(filters.AggregateId.ConvertIdFromGuidToInt(), typeof(TKey));
                }

                if (typeof(TKey) == typeof(Guid))
                {
                    id = Convert.ChangeType(filters.AggregateId, typeof(TKey));
                }

                snapShotFilters.Add(this.FilterForProperty(p => p.Id, (TKey)id));
            }

            if (filters.HasStartDate())
            {
                snapShotFilters.Add(t => t.UpdatedUtcDt >= filters.StartUtcDateTime);
            }

            if (filters.HasEndDate())
            {
                snapShotFilters.Add(t => t.UpdatedUtcDt <= filters.EndUtcDateTime);
            }

            snapShotFilters.ForEach(f =>
            {
                predicate = predicate.And(f);
            });

            return predicate.Expand();
        }

        /// <summary>
        /// Method disposes any resources used by the class.
        /// </summary>
        public void Dispose()
        {
            this.Dispose(true);
        }

        private Expression<Func<TSource, bool>> FilterForProperty(
            Expression<Func<TSource, TKey>> property,
            TKey value)
        {
            var memberExpression = property.Body as MemberExpression;
            if (!(memberExpression?.Member is PropertyInfo))
            {
                throw new ArgumentException("Property does not exist on the entity.", nameof(property));
            }

            var left = property.Body;
            var right = Expression.Constant(value, typeof(TKey));

            return Expression.Lambda<Func<TSource, bool>>(
                Expression.Equal(left, right), property.Parameters.Single());
        }

        protected virtual void Dispose(bool disposing)
        {
            if (disposing)
            {
                this.context?.Dispose();
            }
        }

        protected bool IsInitializedWithDbContext => this.context != null;
    }
}
