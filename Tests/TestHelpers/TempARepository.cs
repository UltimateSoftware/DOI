using System.Collections.Generic;
using System.Text;
using DOI.Tests.Integration.Models;
using DOI.Tests.TestHelpers.Metadata.SystemMetadata;

namespace DOI.Tests.TestHelpers
{
    public class TempARepository : SystemMetadataHelper
    {
        public TempARepository(SqlHelper sqlHelper)
        {
            this.sqlHelper = sqlHelper;
        }

        public void InsertRows(List<TempARow> rows)
        {
            var sqlBuilder = new StringBuilder($"INSERT dbo.TempA(TempAId, TransactionUtcDt) VALUES ");

            for (var i = 0; i < rows.Count; i++)
            {
                var row = rows[i];
                sqlBuilder.Append((i == 0 ? string.Empty : ", ") + $"('{row.TempAid.ToString()}','{row.TransactionUtcDt.ToString("yyyy-MM-dd HH:mm:ss")}')\n");
            }

            this.sqlHelper.Execute(sqlBuilder.ToString(), 30, true, DatabaseName);
        }
    }
}
