using System.Security;

namespace DDI.Tests.TestHelpers.CommonSetup.Security.Extensions
{
    public static class StringSecurityExtensions
    {
        /// <summary>
        /// Method creates new SecureString object from string value.
        /// </summary>
        /// <param name="secret">The secret string.</param>
        /// <returns>New SecureString object.</returns>
        public static unsafe SecureString ToSecureString(this string secret)
        {
            fixed (char* ptr = secret)
            {
                SecureString ss = new SecureString(ptr, secret.Length);
                ss.MakeReadOnly();
                return ss;
            }
        }

        /// <summary>
        /// Method erases string by replacing all chars with 0-byte data to prevent sensitive data being left in the memory.
        /// </summary>
        /// <remarks>The length of the string won't be affected by this operation.</remarks>
        /// <param name="secret">The secret to erase.</param>
        public static unsafe void Erase(this string secret)
        {
            if (secret != string.Empty)
            {
                fixed (char* ptr = secret)
                {
                    for (int i = 0; i < secret.Length; i++)
                    {
                        ptr[i] = '\0';
                    }
                }
            }
        }
    }
}
