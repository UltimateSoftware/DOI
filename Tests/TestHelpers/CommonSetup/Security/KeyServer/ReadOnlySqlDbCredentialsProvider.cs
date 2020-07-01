using DOI.Tests.TestHelpers.CommonSetup.Logging;

namespace DOI.Tests.TestHelpers.CommonSetup.Security.KeyServer
{
    /// <summary>
    /// Read Only Credentials Provider for UltiPro Tax Engine and Reporting SQL store
    /// </summary>
    public class ReadOnlySqlDbCredentialsProvider : CredentialsProviderBase, IReadOnlySqlDbCredentialsProvider
    {
        public ReadOnlySqlDbCredentialsProvider(IAppLogger logger, IKeyServerAdapter keyServerAdapter)
            : base(logger, keyServerAdapter)
        {
        }

        protected override string CredentialsResourceName => "sql-readonly-credentials.json";
    }
}
