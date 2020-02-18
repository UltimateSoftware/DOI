using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using SmartHub.Hosting.DataAccess;

namespace DDI.Tests.TestHelpers.DataAccess
{
    /// <summary>
    /// The interface implemented by repository providing standard CRUD operations for a generic entity/aggregate.
    /// This is an abstraction layer independent from the DB type.
    /// </summary>
    /// <typeparam name="TSource">The generic entity/aggregate type.</typeparam>
    /// <typeparam name="TDbId">The generic type used as an identifier for the entity/aggregate. Usually a Guid, but can be another type.</typeparam>
    public interface IRepository<TSource, TDbId> : ISimpleRepository<TSource, TDbId>
        where TSource : class
    {
        /// <summary>
        /// Method finds a single aggregate instance based on tenantId and aggregateId.
        /// </summary>
        /// <param name="tenantId">The tenantId.</param>
        /// <param name="id">The aggregateId.</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns an instance or null, if not found.</returns>
        Task<TSource> FindOne(Guid tenantId, TDbId id, CancellationToken cancellationToken = default(CancellationToken));

        /// <summary>
        /// Method finds all aggregate instances for particular tenantId.
        /// </summary>
        /// <param name="tenantId">The tenantId.</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns an IEnumerable containing the aggregates.</returns>
        Task<IEnumerable<TSource>> FindAll(Guid tenantId, CancellationToken cancellationToken = default(CancellationToken));

        /// <summary>
        /// Method finds all aggregate instances for particular tenantId, but returns only part of it based on page parameters (page number, size, sorting order).
        /// </summary>
        /// <param name="tenantId">The tenantId.</param>
        /// <param name="pageParams">The page parameters object.</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns an IEnumerable containing the aggregates.</returns>
        Task<IEnumerable<TSource>> FindAll(Guid tenantId, PagedDataParameters pageParams, CancellationToken cancellationToken = default(CancellationToken));

        /// <summary>
        /// Method returns the total count of aggregates for particular tenantId.
        /// </summary>
        /// <param name="tenantId">The tenantId.</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns a long value.</returns>
        /// <returns>Returns a long value.</returns>
        Task<long> Count(Guid tenantId, CancellationToken cancellationToken = default(CancellationToken));

        /// <summary>
        /// Updates an aggregates in the repository.
        /// </summary>
        /// <param name="tenantId">The tenant id.</param>
        /// <param name="id">The aggregate id.</param>
        /// <param name="item">The aggregate to update to.</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns boolean indicator of success.</returns>
        Task<bool> Update(Guid tenantId, TDbId id, TSource item, CancellationToken cancellationToken = default(CancellationToken));

        /// <summary>
        /// Updates an aggregates in the repository. Method validates versioning and would raise DataVersioningException if version does not match.
        /// </summary>
        /// <param name="tenantId">The tenant id.</param>
        /// <param name="id">The aggregate id.</param>
        /// <param name="expectedVersion">The expected version to update in the repository.</param>
        /// <param name="item">The aggregate to update to.</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns boolean indicator of success.</returns>
        Task<bool> Update(Guid tenantId, TDbId id, int expectedVersion, TSource item, CancellationToken cancellationToken = default(CancellationToken));

        /// <summary>
        /// Method checks if repository contains an aggregate with specified aggregateId and tenantId.
        /// </summary>
        /// <param name="tenantId">The tenant id.</param>
        /// <param name="id">The aggregateId.</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns boolean value indicating a success.</returns>
        Task<bool> Contains(Guid tenantId, TDbId id, CancellationToken cancellationToken = default(CancellationToken));
    }
}
