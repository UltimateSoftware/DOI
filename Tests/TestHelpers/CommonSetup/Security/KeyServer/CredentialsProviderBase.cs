using System;
using System.Dynamic;
using System.Threading;
using System.Threading.Tasks;

using Microsoft.Practices.Unity.Configuration.ConfigurationHelpers;

using Newtonsoft.Json;
using DDI.Tests.TestHelpers.CommonSetup.Logging;
using DDI.Tests.TestHelpers.CommonSetup.Security.Extensions;

namespace DDI.Tests.TestHelpers.CommonSetup.Security.KeyServer
{
    /// <summary>
    /// This class is responsible for managing application credentials.
    /// </summary>
    public abstract class CredentialsProviderBase : ICredentialsProvider
    {
        /// <summary>
        /// The credentials resource name used to retrieve the credentials file.
        /// </summary>
        protected abstract string CredentialsResourceName { get; }

        protected readonly IAppLogger Logger;

        protected readonly IKeyServerAdapter KeyServerAdapter;

        // ReSharper disable once InconsistentNaming
        protected BasicCredentials credentials;

        /// <summary>
        /// Constructor.
        /// </summary>
        /// <param name="logger">The application logger.</param>
        /// <param name="keyServerAdapter">The Key server adapter.</param>
        protected CredentialsProviderBase(IAppLogger logger, IKeyServerAdapter keyServerAdapter)
        {
            this.Logger = logger;
            this.KeyServerAdapter = keyServerAdapter;
        }

        /// <summary>
        /// Method loads the credentials from the Key Server to the local cache.
        /// </summary>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns task object.</returns>
        public virtual async Task LoadCredentials(CancellationToken cancellationToken = default(CancellationToken))
        {
            Guid corrId = Guid.NewGuid();

            string resource = await this.KeyServerAdapter.GetStringResource(this.CredentialsResourceName, corrId, cancellationToken)
                .ConfigureAwait(false);

            if (string.IsNullOrWhiteSpace(resource))
            {
                throw new Exception("The Credentials " + this.CredentialsResourceName + " cannot be loaded from the Key Server - the returned data is empty.");
            }

            string un = string.Empty;
            string psw = string.Empty;
            try
            {
                var credData = JsonConvert.DeserializeObject<ExpandoObject>(resource);

                un = credData.GetOrNull("username") as string;
                psw = credData.GetOrNull("password") as string;

                if (string.IsNullOrWhiteSpace(un) || string.IsNullOrWhiteSpace(psw))
                {
                    throw new Exception("The Credentials " + this.CredentialsResourceName + " cannot be loaded from the Key Server - the json contains an empty data.");
                }

                this.credentials = new BasicCredentials()
                {
                    UserName = un.ToSecureString(),
                    Password = psw.ToSecureString()
                };
            }
            finally
            {
                //cleanup memory what's possible to remove secure info footprint
                resource.Erase();
                un?.Erase();
                psw?.Erase();
            }

            this.Logger.Information("The Credentials {credentialsResourceName} successfully loaded from the Key Server.", this.CredentialsResourceName);
        }

        /// <summary>
        /// Clears credentials in the local cache, and optionally refreshes them. 
        /// </summary>
        /// <param name="refresh">Parameter indicates if credentials should be refreshed right away.</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns a Task</returns>
        public async Task Clear(bool refresh, CancellationToken cancellationToken = default(CancellationToken))
        {
            this.Logger.Debug("Clearing existing Credentials " + this.CredentialsResourceName + ".");
            if (refresh)
            {
                await this.LoadCredentials(cancellationToken).ConfigureAwait(false);
            }
            else
            {
                this.credentials = null;
            }
        }

        /// <summary>
        /// Method returns current credentials. It optionally loads credentials if they not already loaded.
        /// </summary>
        /// <param name="loadOnNone">Boolean flag that forces loading data if not existing already. 
        /// NOTE: this process may raise an exception if loading process fails.</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns UltiproCredentials.</returns>
        public async Task<BasicCredentials> GetCredentials(bool loadOnNone, CancellationToken cancellationToken = default(CancellationToken))
        {
            if (this.credentials == null)
            {
                if (loadOnNone)
                {
                    await this.LoadCredentials(cancellationToken);
                }
            }

            return this.credentials;
        }

        /// <summary>
        /// Method returns current credentials.
        /// </summary>
        /// <returns>Returns UltiproCredentials.</returns>
        public BasicCredentials GetCredentials()
        {
            return this.credentials;
        }

        /// <summary>
        /// Method returns boolean value whether the credentials exists in the local cache.
        /// </summary>
        /// <returns>Returns boolean value.</returns>
        public bool HasCredentials()
        {
            return this.credentials != null;
        }
    }
}
