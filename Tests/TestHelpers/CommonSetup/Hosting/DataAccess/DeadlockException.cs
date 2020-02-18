using System;

namespace DDI.Tests.TestHelpers.CommonSetup.Hosting.DataAccess
{
    /// <summary>
    /// Class represents the duplicated key or unique index error in the application.
    /// </summary>
    [Serializable]
    public class DeadlockException : Exception
    {
        public DeadlockException()
            : this("Deadlock exception has been detected.", null)
        {
        }

        public DeadlockException(string message, Exception innerException)
            : base(message, innerException)
        {
        }
    }
}