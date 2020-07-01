using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DOI.Tests.TestHelpers.CommonSetup.Logging;

namespace DOI.Tests.TestHelpers.CommonSetup.Security.KeyServer
{
    /// <summary>
    /// Credentials Provider for UltiPro Tax Enfine SQL store
    /// </summary>
    public class UteSqlDbCredentialsProvider : CredentialsProviderBase, IUteSqlDbCredentialsProvider
    {
        public UteSqlDbCredentialsProvider(IAppLogger logger, IKeyServerAdapter keyServerAdapter)
            : base(logger, keyServerAdapter)
        {
        }

        protected override string CredentialsResourceName => "sql-user-credentials.json";
    }
}
