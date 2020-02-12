using System;


namespace DDI.Tests.Integration.TestHelpers.CommonSetup.EventStore
{
    /// <summary>
    /// Attribute allows to define a domain event details.
    /// </summary>
    [AttributeUsage(AttributeTargets.Class, AllowMultiple = true, Inherited = false)] //This attribute MUST NOT use inheritance!!!
    public class EventDetailsAttribute : Attribute
    {
        /// <summary>
        /// Gets or sets the domain event name. This name must follow the convention: "{domain}|{bounded-context}.{aggregate-name}.{what-happened-in-the-past-tense}".
        /// </summary>
        public string EventName { get; set; }

        /// <summary>
        /// Gets or sets the boolean indicator whether the publish requires acknowledgement. 
        /// By default is false.
        /// </summary>
        public bool AckPublish { get; set; }

        /// <summary>
        /// Gets or sets a boolean indicator whether the event has to be encrypted. 
        /// By default is false.
        /// </summary>
        public bool Encrypted { get; set; }

        /// <summary>
        /// Gets or sets a boolean indicator whether the event has to be compressed. 
        /// By default is false.
        /// </summary>
        public bool Compressed { get; set; }

        /// <summary>
        /// Gets or sets the event schema version.
        /// </summary>
        public string SchemaVersion { get; set; }

        public EventDetailsAttribute()
        {
            this.EventName = string.Empty;
            this.SchemaVersion = "0.0";
        }

        public bool IsVersionSet()
        {
            return this.SchemaVersion != "0.0" && !string.IsNullOrWhiteSpace(this.SchemaVersion);
        }
    }
}
