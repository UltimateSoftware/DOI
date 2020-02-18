using System;

namespace DDI.Tests.TestHelpers
{
    /// <summary>
    /// Filter for apply events.
    /// </summary>
    public class ApplyEventFilter
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="ApplyEventFilter" /> class.
        /// </summary>
        /// <param name="eventName">Name of the event.</param>
        /// <param name="schemaVersion">The schema version.</param>
        public ApplyEventFilter(string eventName, string schemaVersion = "0.0")
        {
            this.EventName = eventName;
            this.MinimumSchemaVersion = new Version(schemaVersion);
        }

        /// <summary>
        /// Gets or sets the name of the event.
        /// </summary>
        /// <value>
        /// The name of the event.
        /// </value>
        public string EventName { get; set; }

        /// <summary>
        /// Gets or sets the minimum event schema version.
        /// </summary>
        /// <value>
        /// The maximum event schema version.
        /// </value>
        public Version MinimumSchemaVersion { get; set; }
    }
}
