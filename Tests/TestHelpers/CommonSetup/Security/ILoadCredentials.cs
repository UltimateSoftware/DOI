using System.Threading;
using System.Threading.Tasks;

namespace DOI.Tests.TestHelpers.CommonSetup.Security
{
    public interface ILoadCredentials
    {
        /// <summary>
        /// Method loads the credentials from the Key Server to the local cache.
        /// </summary>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns task object.</returns>
        Task LoadCredentials(CancellationToken cancellationToken = default(CancellationToken));

        /// <summary>
        /// Method returns boolean value whether the credentials exists in the local cache.
        /// </summary>
        /// <returns>Returns boolean value.</returns>
        bool HasCredentials();

        /// <summary>
        /// Clears credentials in the local cache, and optionally refreshes them. 
        /// </summary>
        /// <param name="refresh">Parameter indicates if credentials should be refreshed right away.</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns a Task</returns>
        Task Clear(bool refresh, CancellationToken cancellationToken = default(CancellationToken));
    }
}
