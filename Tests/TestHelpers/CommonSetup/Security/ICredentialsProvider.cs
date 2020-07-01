using System.Threading;
using System.Threading.Tasks;

namespace DOI.Tests.TestHelpers.CommonSetup.Security
{
    public interface ICredentialsProvider : ILoadCredentials
    {
        /// <summary>
        /// Method returns current credentials. It optionally loads credentials if they not already loaded.
        /// </summary>
        /// <param name="loadOnNone">Boolean flag that forces loading data if not existing already. 
        /// NOTE: this process may raise an exception if loading process fails.</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns UltiproCredentials.</returns>
        Task<BasicCredentials> GetCredentials(bool loadOnNone, CancellationToken cancellationToken = default(CancellationToken));

        /// <summary>
        /// Method returns current credentials.
        /// </summary>
        /// <returns>Returns UltiproCredentials.</returns>
        BasicCredentials GetCredentials();
    }
}
