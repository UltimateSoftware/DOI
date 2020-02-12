using System;
using System.Diagnostics;
using System.Runtime.Serialization;
using MongoDB.Bson.Serialization.Attributes;
using DDI.Tests.Integration.TestHelpers.CommonSetup.EventStore;
using DDI.Tests.Integration.TestHelpers.CommonSetup.Hosting;

namespace DDI.Tests.Integration.IntegrationTests.Models
{
    [Serializable]
    [DataContract]
    public abstract class Entity<TKey> : VersionTracker
    {
        // TODO: Added this to enable compliation on VS2017 There may be a better way to fix this.
#pragma warning disable CS0067

        public virtual event AggregateEvent AggregateEvent;
#pragma warning restore CS0067

        /// <summary>
        /// Gets the domain event data.
        /// </summary>
        /// <param name="eventName">Name of the event.</param>
        /// <param name="eventDataDetails">The event data details.</param>
        /// <returns>DomainEventData</returns>
        protected abstract DomainEventData GetDomainEventData(string eventName, object eventDataDetails);

        protected virtual void RaiseEvent(string eventName, object eventDataDetails, string schemaVersion = "1.0")
        {
            Debug.Assert(this.IsValidSchemaVersion(schemaVersion), $"Invalid {nameof(schemaVersion)} parameter format.");

            if (this.AggregateEvent != null)
            {
                //ensure the same sequence as previous event - observed must keep the last sequence
                if (!eventName.EndsWith(DomainEventData.ObservedEventSuffix))
                {
                    this.IncrementEventSequence();
#if DEBUG
                    Convention.Require(this.HasChanges(), "Raising this event Requires the aggregate is marked as changed.");
#endif
                }

                var eventData = this.GetDomainEventData(eventName, eventDataDetails);

                //"observed" event should not be going to event store because it does not represent state change.
                if (eventName.EndsWith(DomainEventData.ObservedEventSuffix))
                {
                    eventData = eventData.IgnoreByEventStore();
                }

                this.AggregateEvent.Invoke(this, new AggregateEventArgs(eventData));
            }
        }

        [DataMember(Name = "id", Order = 0)]
        [BsonElement]
        public virtual TKey Id { get; set; }

        /// <summary>
        /// Gets the clone of the aggregate base including the value of the relevant fields for the 
        /// current aggregate
        /// </summary>
        /// <returns>The aggregate clone.</returns>
        public virtual dynamic ToMessageBody()
        {
            return this;
        }

        /// <summary>
        /// Deletes this instance.
        /// </summary>
        /// <returns>Returns true if and only if this instance can be deleted.</returns>
        public virtual bool Delete()
        {
            return false;
        }
    }
}
