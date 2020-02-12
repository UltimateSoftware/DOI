using System;
using System.ComponentModel.DataAnnotations.Schema;
using System.Runtime.Serialization;
using System.Text.RegularExpressions;
using DDI.Tests.Integration.TestHelpers.CommonSetup;
using MongoDB.Bson.Serialization.Attributes;
using Newtonsoft.Json;
using SmartHub.Hosting.Formatters;

namespace DDI.Tests.Integration.IntegrationTests.Models
{
    /// <summary>
    /// Class provides basic properties such as aggregate version, created and updated date and time for all aggregates.
    /// </summary>
    [DataContract(Name = "versionTracker", Namespace = "")]
    [BsonIgnoreExtraElements]
    [Serializable]
    public class VersionTracker : IVersionTracker
    {
        private static readonly string DefaultSchemaVersionStamp = "1.0";
        private static readonly Regex SchemaVersionRegex = new Regex(@"^\d+(?:\.\d+)?$", RegexOptions.Compiled);

        [IgnoreDataMember]
        [NotMapped]
        [JsonIgnore]
        [BsonIgnore]
        public virtual string SchemaVersion { get; protected set; } = DefaultSchemaVersionStamp;

        /// <summary>
        /// Gets or sets date and time when aggregate was created.
        /// </summary>
        [JsonConverter(typeof(CustomDateTimeConverter))]
        [BsonDateTimeOptions(Kind = DateTimeKind.Utc)]
        [BsonElement("createdUtc")]
        [DataMember(Name = "createdAt", Order = 2)]
        public DateTime CreatedUtcDt { get; set; }

        /// <summary>
        /// Gets or sets aggregate most recent update date and time.
        /// </summary>
        [JsonConverter(typeof(CustomDateTimeConverter))]
        [BsonDateTimeOptions(Kind = DateTimeKind.Utc)]
        [BsonElement("updatedUtc")]
        [DataMember(Name = "updatedAt", Order = 2)]
        public DateTime UpdatedUtcDt { get; set; }

        /// <summary>
        /// Gets or sets current aggregate version (update sequence, not schema version).
        /// </summary>
        [BsonElement("version")]
        [DataMember(Name = "version", Order = 2)]
        public int Version { get; set; }

        protected int initialVersion = -1;
        protected bool hasChanges = false;
        protected int eventSequenceNumber;

        /// <summary>
        /// Gets the current event sequence number to be used for ordering the events.
        /// </summary>
        [BsonElement("evtSeq")]
        [IgnoreDataMember]
        [JsonIgnore]
        public virtual int EventSequenceNumber
        {
            get
            {
                if (this.eventSequenceNumber == 0)
                {
                    this.eventSequenceNumber = this.Version;
                }

                return this.eventSequenceNumber;
            }

            set
            {
                this.eventSequenceNumber = value;
            }
        }

        /// <summary>
        /// Method updates aggregate state management indicating it has changes and incrementing its version by 1.
        /// The version won't change if multiple updates are being made to the same state.
        /// </summary>
        public void MarkAsChanged()
        {
            if (this.initialVersion == -1)
            {
                this.initialVersion = this.Version;
            }

            if (this.Version <= 0)
            {
                this.CreatedUtcDt = DateTime.UtcNow;
            }

            if (this.initialVersion == this.Version)
            {
                this.Version++;
            }

            this.UpdatedUtcDt = DateTime.UtcNow;
            this.hasChanges = true;
        }

        /// <summary>
        /// Method updates aggregate state management indicating that state has been persisted to the repository.
        /// This method MUST NOT BE USED from any code OTHER THAN REPOSITORIES. Using this method outside of repositories may lead to data corruption.
        /// </summary>
        public void MarkAsPersisted()
        {
            this.initialVersion = this.Version;
            this.hasChanges = false;
        }

        /// <summary>
        /// Method increments event sequencer. This method must be called before sending each event (only once per event).
        /// </summary>
        protected void IncrementEventSequence()
        {
            this.EventSequenceNumber++;
        }

        /// <summary>
        /// Method determines whether or not an instance represents new aggregate.
        /// </summary>
        /// <returns>Returns boolean value.</returns>
        protected bool IsNew()
        {
            return this.Version == (this.hasChanges ? 1 : 0);
        }

        /// <summary>
        /// Method determines whether or not an aggregate instance has any changes.
        /// </summary>
        /// <returns>Returns boolean value.</returns>
        public bool HasChanges()
        {
            return this.hasChanges;
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="VersionTracker"/> class.
        /// Default constructor.
        /// </summary>
        protected VersionTracker()
        {
            this.CreatedUtcDt = DateTime.UtcNow;
            this.UpdatedUtcDt = DateTime.UtcNow;
        }

        /// <summary>
        /// Method validates format of schema version. Acceptable format is "{major}.{minor}", the minor version is optional. E.g.: 1.4, 3, 15.4566.
        /// </summary>
        /// <param name="schemaVersion">Schema version as a string.</param>
        /// <remarks>It is not recommended to use this method in production due to performance.
        /// Debug.Assert is the best way to validate format in development using debug mode.</remarks>
        /// <returns>Returns boolean value: true if valid, otherwise false.</returns>
        protected bool IsValidSchemaVersion(string schemaVersion)
        {
            return SchemaVersionRegex.IsMatch(schemaVersion);
        }
    }
}
