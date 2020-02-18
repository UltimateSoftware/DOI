using System.Data.SqlClient;
using System.Security;
using DDI.Tests.TestHelpers.CommonSetup.Security;
using DDI.Tests.TestHelpers.CommonSetup.Security.Extensions;

namespace DDI.Tests.TestHelpers.DataAccess.SqlDataStore
{
    public class SqlConnectionStringBuilder : IConnectionStringBuilder
    {
        protected readonly ICredentialsProvider CredentialsProvider;

        public SqlConnectionStringBuilder(ICredentialsProvider credentialsProvider)
        {
            this.CredentialsProvider = credentialsProvider;
        }

        public virtual string BuildConnectionString(string connectionString)
        {
            return this.BuildConnectionString(connectionString, ApplicationIntent.ReadWrite);
        }

        public virtual string BuildConnectionString(string connectionString, ApplicationIntent applicationIntent)
        {
            var inner = new System.Data.SqlClient.SqlConnectionStringBuilder(connectionString);

            try
            {
                var credentials = this.GetCredentials();

                inner.UserID = credentials.UserName.ReadAsString();
                inner.Password = credentials.Password.ReadAsString();
                inner.ApplicationIntent = applicationIntent;

                return inner.ToString();
            }
            finally
            {
                inner.Password.Erase();
                inner.UserID.Erase();
            }
        }

        private BasicCredentials GetCredentials()
        {
            if (!this.CredentialsProvider.HasCredentials())
            {
                this.CredentialsProvider.LoadCredentials()
                    .ConfigureAwait(false)
                    .GetAwaiter()
                    .GetResult();
            }

            return this.CredentialsProvider.GetCredentials();
        }
    }
}
