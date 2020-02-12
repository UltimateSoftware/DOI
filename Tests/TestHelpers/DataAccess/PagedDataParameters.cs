using System.Collections.Generic;
using System.Runtime.Serialization;


namespace DDI.Tests.Integration.TestHelpers.DataAccess
{
    [DataContract]
    public class PagedDataParameters : FilterParameters
    {
        public PagedDataParameters(int pageNumber, int pageSize);

        public static PagedDataParameters Default { get; }
        //
        // Summary:
        //     Page number. Starts with 1.
        [DataMember(Name = "page")]
        public int PageNumber { get; }
        //
        // Summary:
        //     Page size.
        [DataMember(Name = "per_page")]
        public int PageSize { get; }
        //
        // Summary:
        //     Comma-separated list of sorting expressions in the form of: "attribute [ASC|DESC]".
        [DataMember(Name = "sort_by")]
        public List<SortParameter> Sortings { get; set; }

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
        //
        // Summary:
        //     Method parses sorting expression. It will ignore duplicate fields taking the
        //     1st expression for a duplicate field.
        //
        // Parameters:
        //   sortByExpression:
        //     Sorting expression as "field1 ASC, field2 ASC"
        public void ParseSortings(string sortByExpression);
    }
}
