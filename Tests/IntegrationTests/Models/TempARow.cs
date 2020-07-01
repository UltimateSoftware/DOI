using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.Tests.Integration.Models
{
    public class TempARow
    {
        public Guid TempAid { get; set; }

        public DateTime TransactionUtcDt { get; set; }

        public string TextCol { get; set; }

        public TempARow()
        {
            this.TempAid = Guid.NewGuid();
            this.TransactionUtcDt = DateTime.Now;
            this.TextCol = new string('z', 8000);
        }
    }
}
