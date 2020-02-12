using System;
using System.Dynamic;
using System.Linq;
using System.Runtime.Serialization;
using MongoDB.Bson.Serialization.Attributes;
using Newtonsoft.Json;
using DDI.Tests.Integration.TestHelpers.CommonSetup.Hosting.Formatters;
using DDI.Tests.Integration.TestHelpers.CommonSetup.Hosting;

namespace DDI.Tests.Integration.TestHelpers.CommonSetup.EventStore
{
    /// <summary>
    /// Domain event data. This is used for application and aggregate level of events.
    /// </summary>
    [Serializable]
    [DataContract]
    public class DomainEventData
    {
        public const string ObservedEventSuffix = ".observed";
        public const string SnapshotEventSuffix = ".snapshot-created";

#pragma warning disable 649
        private DateTime effectiveDatetime;

        private string eventName;
#pragma warning restore 649

        /// <summary>
        /// Gets or sets an identifier for the event.
        /// </summary>
        [DataMember(Name = "id")]
        public Guid Id { get; set; }

        /// <summary>
        /// Gets or sets the event name. This value must adhere to the following pattern: "{bounded-context}.{aggregate-name}.{event-name-in-past-tense}".
        /// </summary>
        /// <remarks>Any "observed" event will automatically trigger the "Ignore By Event Store" flag E.g. "payment.pay.observed"</remarks>
        [BsonElement("eventName")]
        [DataMember(Name = "eventName")]
        public string EventName
        {
            get
            {
                return this.eventName;
            }

            set
            {
                this.eventName = value;
                if (value.EndsWith(ObservedEventSuffix))
                {
                    //all "observed" events must be ignored by the Event Store as they represent snapshots
                    this.IgnoreByEventStore();
                }
            }
        }

        /// <summary>
        /// Gets or sets the tenant Id. Should be set for all events, except system events that have no association with particular tenant.
        /// </summary>
        [BsonElement("tenantId")]
        [DataMember(Name = "tenantId")]
        public Guid TenantId { get; set; }

        /// <summary>
        /// Gets or sets the aggregate id. Should be set for all aggregate level events.
        /// </summary>
        [BsonElement("aggId")]
        [DataMember(Name = "aggId")]
        public Guid AggregateId { get; set; }

        /// <summary>
        /// Gets or sets the aggregate name (the full class name). Should be set for all aggregate level events.
        /// </summary>
        [BsonElement("aggName")]
        [DataMember(Name = "aggName")]
        public string AggregateName { get; set; }

        /// <summary>
        /// Gets or sets the details of event. The structure depends on an event.
        /// </summary>
        [JsonConverter(typeof(PascalCasingExpandoObjectConverter))]
        [BsonElement("details")]
        [DataMember(Name = "details")]
        public dynamic Details { get; set; }

        /// <summary>
        /// Gets or sets the UTC timestamp of the event.
        /// The property is writable for such cases when actual event time is slightly different from event data recording time.
        /// The property should not be modified outside of the context creating the event.
        /// </summary>
        [BsonElement("utc")]
        [BsonDateTimeOptions(Kind = DateTimeKind.Utc)]
        [DataMember(Name = "utc")]
        public DateTime UtcTimestamp { get; set; }

        /// <summary>
        /// Gets or sets the UTC timestamp when the event becomes effective.
        /// </summary>
        [BsonElement("edt")]
        [BsonDateTimeOptions(Kind = DateTimeKind.Utc)]
        [DataMember(Name = "edt")]
        public DateTime EffectiveDatetime
        {
            get
            {
                if (this.effectiveDatetime == DateTime.MinValue)
                {
                    this.effectiveDatetime = this.UtcTimestamp;
                }

                return this.effectiveDatetime;
            }

            set
            {
                this.effectiveDatetime = value;
            }
        }

        /// <summary>
        /// Gets or sets the correlation id for the event. Must me set if available within the event context.
        /// </summary>
        [BsonElement("cid")]
        [DataMember(Name = "cid")]
        public Guid CorrelationId { get; set; }

        /// <summary>
        /// Gets or sets the aggregate's version at the time an event occurred. Should be set for all aggregate level events.
        /// </summary>
        [BsonElement("av")]
        [DataMember(Name = "av")]
        public int AggregateVersion { get; set; }

        /// <summary>
        /// Gets or sets the event schema version at the time an event occurred.
        /// </summary>
        /// <remarks>This value is null by default: check before using it.</remarks>
        [BsonElement("sv")]
        [DataMember(Name = "sv")]
        public string SchemaVersion { get; protected set; }

        /// <summary>
        /// Gets or sets the UserId of the user executed a transaction causing the event.
        /// </summary>
        [BsonElement("uid")]
        [DataMember(Name = "uid")]
        public Guid UserId { get; set; }

        /// <summary>
        /// Gets or sets the user description of the user executed a transaction causing the event.
        /// </summary>
        [BsonElement("user")]
        [DataMember(Name = "user")]
        public string UserDescription { get; set; }

        /// <summary>
        /// Gets or sets the event order.
        /// </summary>
        [BsonElement("seqNum")]
        [DataMember(Name = "seqNum")]
        public int SequenceNumber { get; set; }

        /// <summary>
        /// Gets or sets the flag indicated the inbound event, that is an event coming from the MQ.
        /// This information does not persist, but used for internal logic, such as being ignored by the event store.
        /// </summary>
        [BsonIgnore]
        [JsonIgnore]
        public bool IsInbound { get; set; }

        /// <summary>
        /// Gets or sets the flag indicated whether the event has been already handled.
        /// This flag does not persist and being ignored by the event store.
        /// Messaging infrastructure does not require any behavior on this property by the subscribers.
        /// Subscribers may set this property and have their internal logic dealing with it.
        /// </summary>
        [BsonIgnore]
        [JsonIgnore]
        public bool IsHandled { get; set; }

        /// <summary>
        /// Default constructor.
        /// </summary>
        public DomainEventData()
            : this(string.Empty)
        {
        }

        /// <summary>
        /// Constructor that accepts event name.
        /// </summary>
        /// <param name="eventName">The event name.</param>
        public DomainEventData(string eventName)
        {
            if (string.IsNullOrWhiteSpace(eventName))
            {
                eventName = "unknown";
            }

            this.EventName = eventName;
            this.Id = Guid.NewGuid();
            this.TenantId = Guid.Empty;
            this.AggregateId = Guid.Empty;
            this.UtcTimestamp = DateTime.UtcNow;
            this.EffectiveDatetime = this.UtcTimestamp;
            this.CorrelationId = Guid.Empty;
            this.UserId = Guid.Empty;
            this.UserDescription = string.Empty;
            this.AggregateName = string.Empty;
            this.SchemaVersion = "0.0.0.0";
        }

        /// <summary>
        /// Constructor that accepts event name and details object.
        /// </summary>
        /// <param name="eventName">The event name.</param>
        /// <param name="eventDetails">The event name.</param>
        /// <returns>Returns instance of <see cref="DomainEventData"/></returns>
        public DomainEventData(string eventName, dynamic eventDetails)
            : this(eventName)
        {
            Convention.ThrowIfNullOrWhitespace(eventName, nameof(eventName));
            Convention.ThrowIfNull(eventDetails, nameof(eventDetails));

            Type type = eventDetails.GetType();
            bool isAnonymousExpandoOrPrimitiveType = (type == typeof(ExpandoObject) || type.Name.Contains("AnonymousType") || type.IsPrimitive || type == typeof(string) || type.IsValueType);
            Convention.RequireBusinessRule(!isAnonymousExpandoOrPrimitiveType, $"Type {eventDetails.GetType().Name} should not be Anonymous, Expando or Primitive type");

            var attr = ((EventDetailsAttribute[])type.GetCustomAttributes(typeof(EventDetailsAttribute), false))
                .FirstOrDefault(a => a.EventName == eventName);
            Convention.ThrowIfNull(attr, $"Type {eventDetails.GetType().Name} does not support the details for '{eventName}' event.");
            Convention.Require(attr.IsVersionSet(), $"SchemaVersion must be set for {nameof(EventDetailsAttribute)}.");

            this.Details = eventDetails;
            this.SchemaVersion = attr.SchemaVersion;
        }

        /// <summary>
        /// Methods creates a string representation of event.
        /// </summary>
        /// <returns>Returns string.</returns>
        public override string ToString()
        {
            return string.Format("Event {2} from Aggregate {0} Id={1};", this.AggregateName, this.AggregateId, this.EventName);
        }

        /// <summary>
        /// Method ensures the event won't be saved into Event Store while being published to the message hub.
        /// </summary>
        /// <remarks>Use this method wisely. It is intended for messages that should either not be stored at event store or being republished from another message queue.</remarks>
        /// <returns>Returns current instance.</returns>
        public DomainEventData IgnoreByEventStore()
        {
            this.IsInbound = true;
            return this;
        }

        private static readonly char[] EventSegmentDivider = { '.' };

        public string GetAggregateScope()
        {
            var parts = this.EventName.Split(EventSegmentDivider);
            if (parts.Length > 2)
            {
                return string.Join(".", parts[0], parts[1], "*");
            }

            return this.EventName;
        }
    }
}
