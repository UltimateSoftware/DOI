using System.Security;

namespace DOI.Tests.TestHelpers.CommonSetup.Security
{
    /// <summary>
    /// Class holds credentials basic user credentials.
    /// </summary>
    public class BasicCredentials
    {
        /// <summary>
        /// Gets or sets the user name.
        /// </summary>
        public SecureString UserName { get; set; }

        /// <summary>
        /// Gets or sets the password.
        /// </summary>
        public SecureString Password { get; set; }

        /// <summary>
        /// Default constructor.
        /// </summary>
        public BasicCredentials()
        {
        }

        /// <summary>
        /// Returns boolean indicator whether credentials are empty.
        /// </summary>
        /// <returns>Boolean indicator whether credentials are empty (true) or not (false).</returns>
        public bool IsEmpty()
        {
            if (this.UserName == null || this.Password == null)
            {
                return false;
            }

            return this.UserName.Length == 0 || this.Password.Length == 0;
        }
    }
}
