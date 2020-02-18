using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using DDI.Tests.TestHelpers.CommonSetup.EventStore;

namespace DDI.Tests.TestHelpers
{
    /// <summary>
    /// Dictionary of ApplyEventFilter and MethodInfo to invoke
    /// </summary>
    /// <seealso cref="Dictionary{ApplyEventFilter, MethodInfo}" />
    public class ApplyEventFilterCollection : Dictionary<ApplyEventFilter, MethodInfo>
    {
        /// <summary>
        /// Finds the method.
        /// </summary>
        /// <param name="eventData">The event data.</param>
        /// <returns>
        /// Method that satisfies the condition of event name and schema version.
        /// </returns>
        public MethodInfo FindMethod(DomainEventData eventData)
        {
            var schemaVersion = new Version(eventData.SchemaVersion);
            var methodInfo = this.Where(
                    h => h.Key.EventName == eventData.EventName
                         && h.Key.MinimumSchemaVersion <= schemaVersion)
                .OrderByDescending(m => m.Key.MinimumSchemaVersion)
                .Take(1)
                .SingleOrDefault();

            return methodInfo.Value;
        }
    }
}
