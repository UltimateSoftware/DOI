using System;
using System.Net.Http;

namespace DOI.Tests.TestHelpers.CommonSetup.Hosting.Runtime
{
    /// <summary>
    /// Interface implemented by the class that creates new instances of Http Client without authorization header. 
    /// This interface is designed to be used for limited purposes, by security services, primarily. Use IHttpClientFactory preferably.
    /// </summary>
    public interface ISimpleHttpClientFactory
    {
        /// <summary>
        /// Method creates new instances of Http Client.
        /// </summary>
        /// <param name="correlationId">The correlation Id to use for all Http Client requests.</param>
        /// <returns>Returns HttpClient object.</returns>
        HttpClient CreateHttpClient(Guid correlationId);

        /// <summary>
        /// Modify the defaultTimeout value to be used by CreateHttpClient
        /// </summary>
        /// <param name="timeout">TimeSpan in Seconds</param>
        void SetTimeout(TimeSpan timeout);
    }
}
