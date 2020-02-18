using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DDI.Tests.TestHelpers.CommonSetup.EventStore
{
    public interface IAggregateSnapshotFilter
    {
        /// <summary>
        /// Gets or sets the tenantId message filter to apply; this is an optional parameter.
        /// </summary>
        Guid TenantId { get; set; }

        /// <summary>
        /// Gets or sets the aggregateId message filter to apply; this is an optional parameter.
        /// </summary>
        Guid AggregateId { get; set; }

        /// <summary>
        /// Gets or sets the start date and time (in UTC) message filter to apply; this is an optional parameter.
        /// </summary>
        DateTime StartUtcDateTime { get; set; }

        /// <summary>
        /// Gets or sets the end date and time (in UTC) message filter to apply; this is an optional parameter.
        /// </summary>
        DateTime EndUtcDateTime { get; set; }

        /// <summary>
        /// Gets or sets additional filters specific to particular aggregate to apply; these are optional parameters.
        /// </summary>
        IDictionary<string, object> AdditionalFilters { get; set; }

        /// <summary>
        /// Method evaluates an TenantId property and determines whether it's provided or not.
        /// </summary>
        /// <returns>Returns boolean value.</returns>
        bool HasTenantId();

        /// <summary>
        /// Method evaluates an AggregateId property and determines whether it's provided or not.
        /// </summary>
        /// <returns>Returns boolean value.</returns>
        bool HasAggregateId();

        /// <summary>
        /// Method evaluates an StartUtcDateTime property and determines whether it's provided or not.
        /// </summary>
        /// <returns>Returns boolean value.</returns>
        bool HasStartDate();

        /// <summary>
        /// Method evaluates an StartUtcDateTime property and determines whether it's provided or not.
        /// </summary>
        /// <returns>Returns boolean value.</returns>
        bool HasEndDate();

        /// <summary>
        /// Method evaluates an StartUtcDateTime property and determines whether it's provided or not.
        /// </summary>
        /// <returns>Returns boolean value.</returns>
        bool HasStartAndEndDates();
    }
}
