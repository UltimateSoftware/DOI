namespace DDI.Tests.TestHelpers.DataAccess
{
    /// <summary>
    /// Class to abstract building connection strings
    /// </summary>
    public interface IConnectionStringBuilder
    {
        /// <summary>
        /// Builds a connection string
        /// </summary>
        /// <param name="connectionString">Basis for the internal connection string.</param>
        /// <returns>Connection string</returns>
        string BuildConnectionString(string connectionString);
    }
}
