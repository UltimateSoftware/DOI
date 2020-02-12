using System.Runtime.Serialization;

namespace DDI.Tests.Integration.TestHelpers.DataAccess
{
    [DataContract]
    public class FilterParameters
    {
        public FilterParameters();

        //
        // Summary:
        //     Gets or sets the list of filters.
        [DataMember(Name = "filters")]
        public FilterCollection Filters { get; set; }

        public bool HasFilters();
    }
}
