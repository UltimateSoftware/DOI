using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Dynamic;
using System.Linq;
using System.Reflection;
using System.Text;
using Serilog.Events;
using Serilog.Sinks.PeriodicBatching;

namespace DDI.Tests.Integration.TestHelpers.CommonSetup.Logging
{
    /// <summary>
    /// Writes log events as documents to a Sensu local client.
    /// </summary>
    public class SensuClientSink : PeriodicBatchingSink, IDisposable
    {
        private readonly SensuClientAdapter sensuClientAdapter;

        private readonly string sensuAlertsEmailAddress;

        /// <summary>
        /// The name of property used to indicate the Sensu Alert type.
        /// </summary>
        public const string SensuAlertTypePropertyName = "SensuAlertType";

        /// <summary>
        /// A reasonable default for the number of events posted in each batch.
        /// </summary>
        public const int DefaultBatchPostingLimit = 50;

        /// <summary>
        /// A reasonable default time to wait between checking for event batches.
        /// </summary>
        public static readonly TimeSpan DefaultPeriod = TimeSpan.FromSeconds(2);

        private readonly Dictionary<string, dynamic> alertTypes;

        /// <summary>
        /// Construct a sink posting to the local Sensu client.
        /// </summary>
        /// <param name="sensuAlertsEmailAddress">The Sensu alerts email notification address.</param>
        public SensuClientSink(string sensuAlertsEmailAddress)
            : this(DefaultBatchPostingLimit, DefaultPeriod, sensuAlertsEmailAddress)
        {
        }

        /// <summary>
        /// Construct a sink posting to the local Sensu client.
        /// </summary>
        /// <param name="batchPostingLimit">The maximum number of events to post in a single batch.</param>
        /// <param name="period">The time to wait between checking for event batches.</param>
        /// <param name="sensuAlertsEmailAddress">The Sensu alerts email notification address.</param>
        public SensuClientSink(int batchPostingLimit, TimeSpan period, string sensuAlertsEmailAddress)
            : base(batchPostingLimit, period)
        {
            try
            {
                this.sensuClientAdapter = new SensuClientAdapter();
            }
            catch (Exception ex)
            {
                throw new Exception("Failed to establish connection to Sensu client.", ex);
            }

            this.sensuAlertsEmailAddress = sensuAlertsEmailAddress;
            this.alertTypes = new Dictionary<string, dynamic>();
            TypeInfo typeInfo = typeof(SensuAlertType).GetTypeInfo();
            Enum.GetNames(typeof(SensuAlertType)).ToList().ForEach(
                e =>
                {
                    var descAttr = typeInfo.GetDeclaredField(e).GetCustomAttribute<DescriptionAttribute>();
                    var refreshAttr = typeInfo.GetDeclaredField(e).GetCustomAttribute<SensuRefreshAttribute>();
                    this.alertTypes.Add(
                        e,
                        new
                        {
                            AlertTypeName = descAttr == null ? e : descAttr.Description,
                            RefreshThreshold = refreshAttr?.RefreshThreshold ?? 1
                        });
                });
        }

        /// <summary>
        /// Emit a batch of log events, running to completion synchronously.
        /// </summary>
        /// <param name="events">The events to emit.</param>
        /// <remarks>Override either <see cref="PeriodicBatchingSink.EmitBatch"/> or <see cref="PeriodicBatchingSink.EmitBatchAsync"/>,
        /// not both.</remarks>
        protected override void EmitBatch(IEnumerable<LogEvent> events)
        {
            try
            {
                events.Where(
                        e => (e.Level == Serilog.Events.LogEventLevel.Error || e.Level == Serilog.Events.LogEventLevel.Fatal)
                             && e.Properties.ContainsKey(SensuAlertTypePropertyName))
                    .ToList().ForEach(this.EmitLogEvent);
            }
            catch (Exception ex)
            {
                new FailoverLogger().TryWriteException(ex);
                throw;
            }
        }

        /// <summary>
        /// Emit a log event.
        /// </summary>
        /// <param name="evt">The event to emit.</param>
        private void EmitLogEvent(LogEvent evt)
        {
            StringBuilder additionalDetails = new StringBuilder();
            try
            {
                dynamic alertMetadata = this.alertTypes[
                    evt.Properties[SensuAlertTypePropertyName].ToString().Replace("\"", string.Empty)];
                ExpandoObject pars = new ExpandoObject();
                var dict = pars as IDictionary<string, object>;
                evt.Properties.Keys.ToList().ForEach(p => dict.Add(p, evt.Properties[p]));
                dict.Add("messageTemplate", evt.MessageTemplate.Text);
                additionalDetails.Append($"Message Template: {evt.MessageTemplate.Text}, ");
                var alert = new SensuAlert()
                {
                    AlertStatus = SensuAlertStatus.Critical,
                    ExecutedUtcDateTime = evt.Timestamp.DateTime,
                    IssuedUtcDateTime = evt.Timestamp.DateTime,
                    Output = evt.RenderMessage() + '\n' + ConvertLogParamsToHtml(evt.Properties),
                    Name = alertMetadata.AlertTypeName,
                    Refresh = alertMetadata.RefreshThreshold,
                };

                additionalDetails.Append($"Alert Status: {SensuAlertStatus.Critical}, ");
                additionalDetails.Append($"Executed and Issued Utc Date Time: {evt.Timestamp.DateTime}, ");
                additionalDetails.Append($"Output: {evt.RenderMessage() + '\n' + ConvertLogParamsToHtml(evt.Properties)}, ");
                additionalDetails.Append($"Name: {alertMetadata.AlertTypeName}, ");
                additionalDetails.Append($"Refresh: {alertMetadata.RefreshThreshold}, ");

                alert.EnableMailerHandler(this.sensuAlertsEmailAddress);
                additionalDetails.Append($"Enable Mailer Handler: {this.sensuAlertsEmailAddress}. ");

                this.sensuClientAdapter.SendAlert(alert);
            }
            catch (Exception ex)
            {
                new FailoverLogger().TryWriteException(ex, additionalDetails.ToString());
            }
        }

        private static string ConvertLogParamsToHtml(IReadOnlyDictionary<string, LogEventPropertyValue> props)
        {
            var stringBuilder = new StringBuilder();
            stringBuilder.Append("</li>");

            var idx = 0;
            foreach (var prop in props)
            {
                stringBuilder.Append($"<li>{prop.Key}<ul><li>value: {prop.Value.ToString()}</li></ul>");

                if (idx != props.Count - 1)
                {
                    stringBuilder.Append("</li>");
                }

                idx += 1;
            }

            return stringBuilder.ToString();
        }
    }
}
