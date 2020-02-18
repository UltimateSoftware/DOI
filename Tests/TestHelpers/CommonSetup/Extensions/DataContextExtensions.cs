using System;
using System.Data;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;

namespace DDI.Tests.TestHelpers.CommonSetup.Extensions
{
    public static class DataContextExtensions
    {
        public static DbEntityEntry<TSource> SetOriginalVersion<TSource>(this DbContext ctx, TSource updatedEntity, int originalVersion)
            where TSource : class
        {
            var entry = ctx.Entry(updatedEntity);
            entry.OriginalValues["Version"] = originalVersion;
            return entry;
        }

        /// <summary>
        /// Sets the isolation level for a given dbcontext.
        /// </summary>
        /// <param name="dbContext">The database context.</param>
        /// <param name="isolationLevel">The isolation level.</param>
        /// <returns>The same DbContext.</returns>
        /// <exception cref="System.ArgumentOutOfRangeException">isolationLevel - null</exception>
        public static DbContext WithIsolationLevel(this DbContext dbContext, IsolationLevel isolationLevel)
        {
            switch (isolationLevel)
            {
                case IsolationLevel.ReadUncommitted:
                    dbContext.Database.ExecuteSqlCommand("SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;"); break;
                case IsolationLevel.Unspecified:
                    break;
                case IsolationLevel.Chaos:
                    break;
                case IsolationLevel.ReadCommitted:
                    dbContext.Database.ExecuteSqlCommand("SET TRANSACTION ISOLATION LEVEL READ COMMITTED;"); break;
                case IsolationLevel.RepeatableRead:
                    dbContext.Database.ExecuteSqlCommand("SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;"); break;
                case IsolationLevel.Serializable:
                    dbContext.Database.ExecuteSqlCommand("SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;"); break;
                case IsolationLevel.Snapshot:
                    dbContext.Database.ExecuteSqlCommand("SET TRANSACTION ISOLATION LEVEL SNAPSHOT;"); break;
                default:
                    throw new ArgumentOutOfRangeException(nameof(isolationLevel), isolationLevel, null);
            }

            return dbContext;
        }
    }
}
