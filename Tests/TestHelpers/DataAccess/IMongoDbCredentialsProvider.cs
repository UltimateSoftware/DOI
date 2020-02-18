using DDI.Tests.TestHelpers.CommonSetup.Security;

namespace DDI.Tests.TestHelpers.DataAccess
{
    public interface IMongoDbCredentialsProvider : ICredentialsProvider
    {
        /// <summary>
        /// Gets a boolean indicator whether credentials for MongoDB should be taken from Key Server instead of configured connection strings.
        /// </summary>
        bool Enabled { get; }
    }
}
