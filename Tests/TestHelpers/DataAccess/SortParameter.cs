using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DDI.Tests.Integration.TestHelpers.DataAccess
{
    public class SortParameter
    {
        public SortParameter();
        public SortParameter(string sortByExpression);

        //
        // Summary:
        //     Gets or sets a property to sort by.
        public string SortBy { get; set; }
        //
        // Summary:
        //     Gets or sets sorting direction.
        public SortDirection SortDirection { get; set; }

        public bool HasSortBy();
        //
        // Summary:
        //     Method maps sorting field to another name alternatively used for sorting. Both
        //     names are case-sensitive.
        //
        // Parameters:
        //   mapFromFieldName:
        //     The field name to map (from).
        //
        //   mapToFieldName:
        //     The field name to map to.
        public void MapSortingField(string mapFromFieldName, string mapToFieldName);
        public void Parse(string sortByExpression);
        public string ToExpression();
    }
}
