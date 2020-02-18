using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using DDI.Tests.TestHelpers.CommonSetup.Hosting;
using DDI.Tests.TestHelpers.CommonSetup.Hosting.Runtime;
using DDI.Tests.TestHelpers.CommonSetup.Logging;

namespace DDI.Tests.TestHelpers.CommonSetup.Security.KeyServer
{
    /// <summary>
    /// This class is responsible for retrieving data from the key server.
    /// </summary>
    public class KeyServerAdapter : IKeyServerAdapter
    {
        private readonly IAppLogger logger;

        private readonly ISimpleHttpClientFactory clientFactory;

        /// <summary>
        /// Constructor.
        /// </summary>
        /// <param name="logger">The application logger.</param>
        /// <param name="clientFactory">The HTTP Client factory.</param>
        public KeyServerAdapter(IAppLogger logger, ISimpleHttpClientFactory clientFactory)
        {
            this.logger = logger.FromSource<KeyServerAdapter>();
            this.clientFactory = clientFactory;
        }

        public Uri GetApplicationKeyServerUrl()
        {
            string url = Environment.GetEnvironmentVariable("KEYSERVER_URL");
            if (!string.IsNullOrWhiteSpace(url))
            {
                Uri uri = null;
                if (Uri.TryCreate(url, UriKind.Absolute, out uri))
                {
                    return uri;
                }
            }

            this.logger.Fatal("Environment variable KEYSERVER_URL is not set.");
            throw new ApplicationException("Environment variable KEYSERVER_URL is not set.");
        }

        /// <summary>
        /// Method loads the resources from the Key Server.
        /// </summary>
        /// <param name="resourcesRelativeUrl">The resources' names to load.</param>
        /// <param name="correlationId">Correlation Id to use</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns collection of resources.</returns>
        public async Task<Dictionary<string, byte[]>> GetResources(IEnumerable<string> resourcesRelativeUrl, Guid correlationId, CancellationToken cancellationToken = default(CancellationToken))
        {
            Dictionary<string, byte[]> result = new Dictionary<string, byte[]>();
            using (HttpClient client = this.clientFactory.CreateHttpClient(correlationId))
            {
                //TODO: add authentication for the request
                client.BaseAddress = this.GetApplicationKeyServerUrl();
                foreach (var url in resourcesRelativeUrl)
                {
                    if (!string.IsNullOrWhiteSpace(url))
                    {
                        using (HttpResponseMessage res = await client.GetAsync(url, HttpCompletionOption.ResponseContentRead, cancellationToken: cancellationToken))
                        {
                            Convention.Require(res.StatusCode == HttpStatusCode.OK, "Failed to retrieve a resource {0} from the key server.", url);

                            this.logger.WithCorrelation(correlationId).Information("Resource file {resourceName} is retrieved from key server", url);
                            byte[] fileBytes = await res.Content.ReadAsByteArrayAsync();
                            result.Add(url, fileBytes);
                        }
                    }
                }
            }

            return result;
        }

        /// <summary>
        /// Method loads the resource from the Key Server.
        /// </summary>
        /// <param name="resourceRelativeUrl">The resource names to load.</param>
        /// <param name="correlationId">Correlation Id to use</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns resource..</returns>
        public async Task<byte[]> GetResource(string resourceRelativeUrl, Guid correlationId, CancellationToken cancellationToken = default(CancellationToken))
        {
            Dictionary<string, byte[]> temp = await this.GetResources(new[] { resourceRelativeUrl }, correlationId, cancellationToken);

            if (temp != null && temp.ContainsKey(resourceRelativeUrl))
            {
                return temp[resourceRelativeUrl];
            }

            return null;
        }

        /// <summary>
        /// Method loads the resource from the Key Server.
        /// </summary>
        /// <param name="resourceRelativeUrl">The resource names to load.</param>
        /// <param name="correlationId">Correlation Id to use</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Returns resource..</returns>
        public async Task<string> GetStringResource(string resourceRelativeUrl, Guid correlationId, CancellationToken cancellationToken = default(CancellationToken))
        {
            Convention.ThrowIfNullOrWhitespace(resourceRelativeUrl, "resourceRelativeUrl");

            using (HttpClient client = this.clientFactory.CreateHttpClient(correlationId))
            {
                //TODO: add authentication for the request
                client.BaseAddress = this.GetApplicationKeyServerUrl();
                using (HttpResponseMessage res = await client.GetAsync(resourceRelativeUrl, HttpCompletionOption.ResponseContentRead, cancellationToken: cancellationToken).ConfigureAwait(false))
                {
                    Convention.Require(res.StatusCode == HttpStatusCode.OK, "Failed to retrieve a resource {0} from the key server.", resourceRelativeUrl);

                    this.logger.WithCorrelation(correlationId).Information("Resource file {resourceName} is retrieved from key server", resourceRelativeUrl);
                    return await res.Content.ReadAsStringAsync().ConfigureAwait(false);
                }
            }
        }
    }
}
