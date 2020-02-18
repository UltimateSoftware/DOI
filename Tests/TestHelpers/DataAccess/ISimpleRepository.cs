using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using DDI.Tests.TestHelpers.CommonSetup.EventStore;
using SmartHub.Hosting.DataAccess;

namespace DDI.Tests.TestHelpers.DataAccess
{
    /// <summary>
    /// The interface implemented by a repository providing standard tenant-based CRUD operations for a generic entity/aggregate.
    /// This is an abstraction layer independent from the DB type.
    /// </summary>
    /// <typeparam name="TSource">The generic entity/aggregate type.</typeparam>
    /// <typeparam name="TDbId">The generic type used as an identifier for the entity/aggregate. Usually a Guid, but can be another type.</typeparam>
    public interface ISimpleRepository<TSource, TDbId> : IBulkOperations<TSource, TDbId>
        where TSource : class
    {
        /// <summary>
        /// Method finds a single aggregate instance based on the aggregateId.
        /// </summary>
        /// <param name="id">The aggregateId.</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns an instance or null, if not found.</returns>
        Task<TSource> FindOne(TDbId id, CancellationToken cancellationToken = default(CancellationToken));

        /// <summary>
        /// Method finds all aggregate instances based on the aggregate ids.
        /// </summary>
        /// <param name="ids">The aggregate ids.</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns an IEnumerable containing the aggregates.</returns>
        Task<IEnumerable<TSource>> FindAllByIds(IEnumerable<TDbId> ids, CancellationToken cancellationToken = default(CancellationToken));

        /// <summary>
        /// Method finds all aggregate instances for all tenants.
        /// </summary>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns an IEnumerable containing the aggregates.</returns>
        Task<IEnumerable<TSource>> FindAll(CancellationToken cancellationToken = default(CancellationToken));

        /// <summary>
        /// Method finds all aggregate instances for all tenants, but returns only part of it based on page parameters (page number, size, sorting order).
        /// </summary>
        /// <param name="pageParams">The page parameters object.</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns an IEnumerable containing the aggregates.</returns>
        Task<IEnumerable<TSource>> FindAll(PagedDataParameters pageParams, CancellationToken cancellationToken = default(CancellationToken));

        /// <summary>
        /// Method returns the total count of aggregates for all tenants.
        /// </summary>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns a long value.</returns>
        Task<long> Count(CancellationToken cancellationToken = default(CancellationToken));

        /// <summary>
        /// Creates new aggregates in the repository.
        /// </summary>
        /// <param name="item">New aggregate to create.</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns boolean indicator of success.</returns>
        Task<bool> Create(TSource item, CancellationToken cancellationToken = default(CancellationToken));

        /// <summary>
        /// Updates an aggregates in the repository.
        /// </summary>
        /// <param name="id">The aggregate id.</param>
        /// <param name="item">The aggregate to update to.</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns boolean indicator of success.</returns>
        Task<bool> Update(TDbId id, TSource item, CancellationToken cancellationToken = default(CancellationToken));

        /// <summary>
        /// Updates an aggregates in the repository. Method validates versioning and will raise DataVersioningException if version does not match.
        /// </summary>
        /// <param name="id">The aggregate id.</param>
        /// <param name="expectedVersion">The expected version to update in the repository.</param>
        /// <param name="item">The aggregate to update to.</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns boolean indicator of success.</returns>
        Task<bool> Update(TDbId id, int expectedVersion, TSource item, CancellationToken cancellationToken = default(CancellationToken));

        /// <summary>
        /// Method deletes a single aggregate instance making Concurrency Checks.
        /// </summary>
        /// <param name="item">The aggregate.</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns boolean value indicating a success.</returns>
        Task<bool> Delete(TSource item, CancellationToken cancellationToken = default(CancellationToken));

        /// <summary>
        /// Method checks if repository contains an aggregate with specified aggregateId.
        /// </summary>
        /// <param name="id">The aggregateId.</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns boolean value indicating a success.</returns>
        Task<bool> Contains(TDbId id, CancellationToken cancellationToken = default(CancellationToken));

        /// <summary>
        /// Applies action to each aggregate found after filtering.
        /// </summary>
        /// <param name="action">Action to apply.</param>
        /// <param name="filters">Filters that can be applied.</param>
        /// <param name="cancellationToken">Cancellation token.</param>
        /// <returns>A Task</returns>
        Task ApplyToEach(Func<TSource, Task> action, IAggregateSnapshotFilter filters, CancellationToken cancellationToken = default(CancellationToken));
    }
}
