using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DDI.Tests.TestHelpers
{
    /// <summary>
    /// ApplyEventFilterAttribute
    /// </summary>
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method, AllowMultiple = true)]
    public class ApplyEventFilterAttribute : Attribute
    {
        /// <summary>
        /// ApplyEventFilterAttribute
        /// </summary>
        /// <param name="eventName">eventName</param>
        /// <param name="minVersion">The minimum version.</param>
        public ApplyEventFilterAttribute(string eventName, string minVersion = "0.0")
        {
            this.EventName = eventName;
            this.MinimumSchemaVersion = minVersion;
        }

        /// <summary>
        /// EventName
        /// </summary>
        public string EventName { get; set; }

        /// <summary>
        /// Gets or sets the minimum schema version.
        /// </summary>
        /// <value>
        /// The minimum schema version.
        /// </value>
        public string MinimumSchemaVersion { get; set; }
    }
}
