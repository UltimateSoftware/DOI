using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace DDI.Tests.TestHelpers.CommonSetup.Security.KeyServer
{
    /// <summary>
    /// This class is responsible for retrieving data from the key server.
    /// </summary>
    public interface IKeyServerAdapter
    {
        /// <summary>
        /// Method loads the resources from the Key Server.
        /// </summary>
        /// <param name="resourcesRelativeUrl">The resources' names to load.</param>
        /// <param name="correlationId">Correlation Id to use</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns collection of resources.</returns>
        Task<Dictionary<string, byte[]>> GetResources(IEnumerable<string> resourcesRelativeUrl, Guid correlationId, CancellationToken cancellationToken = default(CancellationToken));

        /// <summary>
        /// Method loads the resource from the Key Server.
        /// </summary>
        /// <param name="resourceRelativeUrl">The resource names to load.</param>
        /// <param name="correlationId">Correlation Id to use</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns resource..</returns>
        Task<byte[]> GetResource(string resourceRelativeUrl, Guid correlationId, CancellationToken cancellationToken = default(CancellationToken));

        /// <summary>
        /// Method loads the resource from the Key Server.
        /// </summary>
        /// <param name="resourceRelativeUrl">The resource names to load.</param>
        /// <param name="correlationId">Correlation Id to use</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns resource..</returns>
        Task<string> GetStringResource(string resourceRelativeUrl, Guid correlationId, CancellationToken cancellationToken = default(CancellationToken));
    }
}
