using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Reporting.Ingestion.Integration.Tests.Database.DataDrivenIndexEngine.Models;
using TestHelper = Reporting.TestHelpers;

namespace Reporting.Ingestion.Integration.Tests.Database.DataDrivenIndexEngine
{
    public class TempARepository
    {
        private TestHelper.SqlHelper sqlHelper;

        public TempARepository(TestHelper.SqlHelper sqlHelper)
        {
            this.sqlHelper = sqlHelper;
        }

        public void InsertRows(List<TempARow> rows)
        {
            var sqlBuilder = new StringBuilder($"INSERT dbo.TempA(TempAId, TransactionUtcDt) VALUES ");

            for (var i = 0; i < rows.Count; i++)
            {
                var row = rows[i];
                sqlBuilder.Append((i == 0 ? "" : ", ") + $"('{row.TempAid.ToString()}','{row.TransactionUtcDt.ToString("yyyy-MM-dd HH:mm:ss")}')\n");
            }

            this.sqlHelper.Execute(sqlBuilder.ToString());
        }
    }
}
