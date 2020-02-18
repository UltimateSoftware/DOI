using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Reflection;
using DDI.TestHelpers;
using DDI.Tests.TestHelpers;
using DDI.Tests.TestHelpers.CommonSetup.Hosting;
using DDI.Tests.TestHelpers.CommonSetup.Models;
using DDI.Tests.TestHelpers.CommonSetup.EventStore;

namespace DDI.Tests.Integration.IntegrationTests.Models
{
    /// <summary>
    /// AggregateViewBase
    /// </summary>
    /// <typeparam name="TView">bla</typeparam>
    public abstract class AggregateViewBase<TView> : Aggregate<Guid>
        where TView : AggregateViewBase<TView>
    {
        private static readonly ApplyEventFilterCollection Handlers;

        static AggregateViewBase()
        {
            Handlers = new ApplyEventFilterCollection();
            typeof(TView).GetMethods(BindingFlags.NonPublic | BindingFlags.Instance)
                .Where(m => m.GetCustomAttributes<ApplyEventFilterAttribute>().Any())
                .ToList()
                .ForEach(m =>
                {
                    m.GetCustomAttributes<ApplyEventFilterAttribute>()
                        .ToList()
                        .ForEach(a =>
                        {
                            Handlers.Add(new ApplyEventFilter(a.EventName, a.MinimumSchemaVersion), m);
                        });
                });
        }

        /// <summary>
        /// Specify if the aggregate needs to be Inserted or Updated in the database.  
        /// If true, the Insert needs to be done; otherwise, we need to Update.
        /// </summary>
        [NotMapped]
        public bool IsNewRecord { get; set; }

        private bool deleteEvent;

        /// <summary>
        /// Gets or sets a value indicating whether [delete event].
        /// </summary>
        /// <value>
        ///   <c>true</c> if [delete event]; otherwise, <c>false</c>.
        /// </value>
        [NotMapped]
        public bool DeleteEvent
        {
            get
            {
                return this.deleteEvent;
            }

            set
            {
                this.deleteEvent = value;
                if (this.deleteEvent && this.initialVersion != -1)
                {
                    this.Version = this.initialVersion;
                }
            }
        }

        /// <summary>
        /// Applied Event Sequence Number
        /// </summary>
        public int AppliedEventSequenceNumber { get; set; }

        /// <summary>
        /// Applied Event Date Time
        /// </summary>
        public DateTime AppliedEventDateTime { get; set; }

        /// <summary>
        /// Gets or sets the details.
        /// </summary>
        /// <value>
        /// The details.
        /// </value>
        protected IDictionary<string, object> Details { get; set; }

        private AppliedEventSequenceType GetSequenceType(DomainEventData eventData)
        {
            if ((eventData.EventName.IsObservedEvent() && this.AppliedEventSequenceNumber <= eventData.SequenceNumber) || this.AppliedEventSequenceNumber + 1 == eventData.SequenceNumber)
            {
                return AppliedEventSequenceType.ReadyToProccess;
            }

            if (this.AppliedEventSequenceNumber + 1 < eventData.SequenceNumber)
            {
                return AppliedEventSequenceType.StoreToStaging;
            }

            return AppliedEventSequenceType.Ignore;
        }

        /// <summary>
        /// Applies the fall-back event.
        /// </summary>
        /// <returns>Returns true if event successfully applied.</returns>
        protected virtual bool ApplyFallbackEvent()
        {
            this.MarkAsChanged();
            return true;
        }

        /// <summary>
        /// ApplyEvent
        /// </summary>
        /// <param name="eventData">eventData</param>
        /// <returns>Returns true if event successfully applied.</returns>
        /// <exception cref="Exception">Exception</exception>
        public virtual bool ApplyEvent(DomainEventData eventData)
        {
            Convention.ThrowIfNull(eventData, nameof(eventData));

            if (this.GetSequenceType(eventData) == AppliedEventSequenceType.Ignore)
            {
                return true;
            }

            var method = Handlers.FindMethod(eventData);
            bool eventAppliedSuccessfully = false;

            if (method != null)
            {
                var eventDataDetails = ((IDictionary<string, object>)eventData.Details);
                eventAppliedSuccessfully = (bool)method.Invoke(this, new object[] { eventData, eventDataDetails });
            }
            else if (!eventData.EventName.IsSnapshotEvent())
            {
                eventAppliedSuccessfully = this.ApplyFallbackEvent();
            }

            if (eventAppliedSuccessfully)
            {
                this.AppliedEventSequenceNumber = eventData.SequenceNumber;
                this.AppliedEventDateTime = eventData.UtcTimestamp;
            }

            return eventAppliedSuccessfully;
        }

        public bool IsEventHandled(DomainEventData eventData)
        {
            return Handlers.FindMethod(eventData) != null;
        }

        /// <summary>
        /// Gets the value.
        /// </summary>
        /// <typeparam name="TType">The type of the type.</typeparam>
        /// <param name="objectValue">The object value.</param>
        /// <returns>Converted value</returns>
        protected TType GetValue<TType>(object objectValue)
            where TType : struct
        {
            return (TType)Convert.ChangeType(objectValue, typeof(TType));
        }

        /// <summary>
        /// Gets the value when the output type is nullable.
        /// </summary>
        /// <typeparam name="TType">The type of the type (must not be a nullable type).</typeparam>
        /// <param name="objectValue">The object value (could be null).</param>
        /// <returns>Converted value of nullable type</returns>
        protected TType? GetNullableValue<TType>(object objectValue)
            where TType : struct
        {
            if (objectValue == null)
            {
                return null;
            }

            return this.GetValue<TType>(objectValue);
        }

        /// <summary>
        /// Gets the value.
        /// </summary>
        /// <param name="objectValue">The object value.</param>
        /// <returns>Guid value</returns>
        protected Guid GetValue(object objectValue)
        {
            return objectValue.ToGuid();
        }

        /// <summary>
        /// Gets the value or default.
        /// </summary>
        /// <param name="objectValue">The object value.</param>
        /// <param name="defaultValue">The default value.</param>
        /// <returns>
        /// string value if possible to get value; otherwise, defaultValue.
        /// </returns>
        protected string GetValueOrDefault(object objectValue, string defaultValue)
        {
            string value = objectValue as string;
            if (string.IsNullOrWhiteSpace(value))
            {
                value = defaultValue;
            }

            return value;
        }

        /// <summary>
        /// Gets the value or default.
        /// </summary>
        /// <param name="objectValue">The object value.</param>
        /// <param name="defaultValue">The default value.</param>
        /// <returns>objectValue or defaultValue</returns>
        protected short GetValueOrDefault(object objectValue, short defaultValue)
        {
            if (objectValue == null)
            {
                return defaultValue;
            }

            short value;

            if (short.TryParse(objectValue.ToString(), out value))
            {
                return value;
            }

            return defaultValue;
        }

        /// <summary>
        /// Raises the event.
        /// </summary>
        /// <param name="eventName">Name of the event.</param>
        /// <param name="eventDataDetails">The event data details.</param>
        /// <param name="schemaVersion">The schema version.</param>
        protected override void RaiseEvent(string eventName, object eventDataDetails, string schemaVersion = "1.0")
        {
            throw new NotImplementedException();
        }

        protected override DomainEventData GetDomainEventData(string eventName, object eventDataDetails)
        {
            throw new NotImplementedException();
        }

        public string ToMaskNumber(string numberToMask)
        {
            if (string.IsNullOrWhiteSpace(numberToMask) || numberToMask.Length < 4)
            {
                return string.Empty;
            }

            return numberToMask.Substring(numberToMask.Length - 4).PadLeft(9, '*');
        }
    }
}
