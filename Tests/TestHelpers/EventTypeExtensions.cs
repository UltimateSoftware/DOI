using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DDI.Tests.TestHelpers
{
    /// <summary>Define extension methods for event types.</summary>
    public static class EventTypeExtensions
    {
        private const string ObservedEventSuffix = ".observed";
        private const string SnapshotEventSuffix = ".snapshot-created";

        /// <summary>Determines whether [is observed event].</summary>
        /// <param name="eventName">Name of the event.</param>
        /// <returns>
        ///   <c>true</c> if [is observed event] [the specified event name]; otherwise, <c>false</c>.</returns>
        public static bool IsObservedEvent(this string eventName)
        {
            return !string.IsNullOrEmpty(eventName) && eventName.EndsWith(ObservedEventSuffix);
        }

        /// <summary>Determine if specific event is a snapshot event.</summary>
        /// <param name="eventName">Name of the event.</param>
        /// <returns>
        ///   <c>true</c> if [is snapshot event] [the specified event name]; otherwise, <c>false</c>.</returns>
        public static bool IsSnapshotEvent(this string eventName)
        {
            return !string.IsNullOrEmpty(eventName) && eventName.EndsWith(SnapshotEventSuffix);
        }

        /// <summary>Determines whether it is created event.</summary>
        /// <param name="eventName">Name of the event.</param>
        /// <returns>
        ///   <c>true</c> if [is created event] [the specified event name]; otherwise, <c>false</c>.</returns>
        public static bool IsCreatedEvent(this string eventName)
        {
            return eventName.EndsWith(".created")
                   || eventName.EndsWith(".legacy-created")
                   || eventName.IsObservedEvent();
        }

        /// <summary>Determines whether [is observed or snapshot event] [the specified event name].</summary>
        /// <param name="eventName">Name of the event.</param>
        /// <returns>
        ///   <c>true</c> if [is observed or snapshot event] [the specified event name]; otherwise, <c>false</c>.</returns>
        public static bool IsObservedOrSnapshotEvent(this string eventName)
        {
            return eventName.IsObservedEvent() || eventName.IsSnapshotEvent();
        }
    }
}
