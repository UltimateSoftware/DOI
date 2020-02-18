using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace DDI.Tests.TestHelpers.DataAccess
{
    public interface IBulkOperations<TSource, TKey>
    {
        /// <summary>
        /// Bulk create entities.
        /// </summary>
        /// <param name="items">The list of entities</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>BulkCreateResults</returns>
        Task<BulkCreateResults> BulkCreate(IEnumerable<TSource> items, CancellationToken cancellationToken = default(CancellationToken));

        /// <summary>
        /// Bulk update entities.
        /// </summary>
        /// <param name="entitiesBatch">The list of entities</param>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <param name="changesTracked">Indicate to track changes if applicable</param>
        /// <returns>bool</returns>
        Task<bool> BulkUpdate(IEnumerable<TSource> entitiesBatch, CancellationToken cancellationToken = default(CancellationToken), bool changesTracked = true);
    }
}
