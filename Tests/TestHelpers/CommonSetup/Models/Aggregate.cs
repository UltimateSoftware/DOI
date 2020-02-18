using System;
using System.Runtime.Serialization;
using DDI.Tests.Integration.IntegrationTests.Models;
using DDI.Tests.TestHelpers.CommonSetup.EventStore;

namespace DDI.Tests.TestHelpers.CommonSetup.Models
{
    using MongoDB.Bson.Serialization.Attributes;

    [Serializable]
    [DataContract]
    public abstract class Aggregate : Aggregate<Guid>
    {
        protected override DomainEventData GetDomainEventData(string eventName, object eventDataDetails)
        {
            var eventData = new DomainEventData(eventName, eventDataDetails)
            {
                TenantId = this.TenantId,
                AggregateId = this.Id,
                AggregateName = this.GetType().FullName,
                SequenceNumber = this.EventSequenceNumber,
                AggregateVersion = this.Version,
            };

            return eventData;
        }
    }

    [DataContract(Name = "aggregate", Namespace = "")]
    [Serializable]
    public abstract class Aggregate<TKey> : Entity<TKey>
    {
        [DataMember(Name = "tenantId", Order = 1)]
        [BsonElement("tenantId")]
        public virtual Guid TenantId { get; set; }
    }
}
