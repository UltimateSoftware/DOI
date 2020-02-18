using System;
using System.Net.Http;
using SmartHub.Hosting.Extensions;

namespace DDI.Tests.TestHelpers.CommonSetup.Hosting.Runtime
{
    using System.Net;

    /// <summary>
    /// Class creates new instances of Http Client without authorization header.
    /// This class is designed to be used for limited purposes, by security services, primarily. Use IHttpClientFactory preferably.
    /// </summary>
    public class HttpClientFactoryBase : ISimpleHttpClientFactory
    {
        // ReSharper disable once InconsistentNaming
        protected TimeSpan defaultTimeout;

        public HttpClientFactoryBase()
        {
            this.defaultTimeout = TimeSpan.FromSeconds(10);
            ServicePointManager.SecurityProtocol |= SecurityProtocolType.Tls12;
        }

        public void SetTimeout(TimeSpan timeout)
        {
            this.defaultTimeout = timeout;
        }

        /// <summary>
        /// Method creates new instances of Http Client.
        /// </summary>
        /// <param name="correlationId">The correlation Id to use for all Http Client requests.</param>
        /// <returns>Returns HtttpClient object.</returns>
        public HttpClient CreateHttpClient(Guid correlationId)
        {
            if (correlationId == Guid.Empty)
            {
                correlationId = Guid.NewGuid();
            }

            var handler = new HttpClientHandler { UseProxy = false };
            HttpClient client = new HttpClient(handler);
            CreateCommonHeaders(correlationId, client);
            client.Timeout = this.defaultTimeout;

            return client;
        }

        protected static void CreateCommonHeaders(Guid correlationId, HttpClient client)
        {
            client.EnsureCorrelationId(correlationId);

            // Add a user agent string so we know that requests from this client originated from our system.
            client.DefaultRequestHeaders.Add("User-Agent", "taxmgmt.client");
        }
    }
}
