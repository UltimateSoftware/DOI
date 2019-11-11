using System;
using System.Data.SqlClient;

namespace Reporting.TestHelpers.CommonSetup
{
    public static class SqlDataReaderExtensions
    {
        public static DateTime? GetNullableDateTime(this SqlDataReader reader, string name)
        {
            var col = reader.GetOrdinal(name);
            return reader.IsDBNull(col) ?
                        (DateTime?)null :
                        (DateTime?)reader.GetDateTime(col);
        }

        public static decimal? GetNullableDecimal(this SqlDataReader reader, string name)
        {
            var col = reader.GetOrdinal(name);
            return reader.IsDBNull(col) ? (decimal?)null : reader.GetDecimal(col);
        }

        public static double? GetNullableDouble(this SqlDataReader reader, string name)
        {
            var col = reader.GetOrdinal(name);
            return reader.IsDBNull(col) ? (double?)null : reader.GetDouble(col);
        }
    }
}
