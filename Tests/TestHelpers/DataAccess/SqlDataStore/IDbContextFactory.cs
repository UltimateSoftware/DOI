using System.Data.Entity;

namespace DDI.Tests.TestHelpers.DataAccess.SqlDataStore
{
    public interface IDbContextFactory
    {
        /// <summary>
        /// Create DbContext
        /// </summary>
        /// <returns>new DbContext instance</returns>
        DbContext Create();
    }
}
