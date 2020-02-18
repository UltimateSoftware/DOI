using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Serilog.Events;
using Serilog.Formatting.Json;

namespace DDI.Tests.TestHelpers.CommonSetup.Logging
{
    //spec ref: http://devgit01.dev.us.corp:7990/projects/DOCS/repos/docs/browse/Logs.md
    internal class InlineJsonFormatter : JsonFormatter
    {
        private static readonly string[] TopLevelProperties = { "SourceIp", "HostName", "ApplicationName", "ServiceName", "Version" };

        private readonly bool useMessagePropertyForTemplate;

        public InlineJsonFormatter(bool omitEnclosingObject = false, string closingDelimiter = null, bool renderMessage = false, IFormatProvider formatProvider = null)
            : base(omitEnclosingObject, closingDelimiter, renderMessage, formatProvider)
        {
            this.useMessagePropertyForTemplate = !renderMessage;
        }

        protected override void WriteTimestamp(DateTimeOffset timestamp, ref string delim, TextWriter output)
        {
            //use ISO8601 format
            this.WriteJsonProperty("Date", timestamp.LocalDateTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffK"), ref delim, output);
        }

        protected override void WriteMessageTemplate(string message, ref string delim, TextWriter output)
        {
            this.WriteJsonProperty(this.useMessagePropertyForTemplate ? "Message" : "MessageTemplate", message, ref delim, output);
        }

        protected override void WriteRenderedMessage(string message, ref string delim, TextWriter output)
        {
            this.WriteJsonProperty("RenderedMessage", message, ref delim, output);
        }

        protected override void WriteLevel(Serilog.Events.LogEventLevel level, ref string delim, TextWriter output)
        {
            this.WriteJsonProperty("Level", level, ref delim, output);
        }

        protected override void WriteException(Exception exception, ref string delim, TextWriter output)
        {
            this.WriteJsonProperty("Stacktrace", exception, ref delim, output);
        }

        protected override void WriteProperties(IReadOnlyDictionary<string, LogEventPropertyValue> properties, TextWriter output)
        {
            output.Write(",");
            this.WriteCommonPropertiesValues(properties, output);

            output.Write(",\"{0}\":{{", "TXM");
            this.WriteDomainSpecificPropertiesValues(properties, output);
            output.Write("}");
        }

        protected virtual void WriteDomainSpecificPropertiesValues(IReadOnlyDictionary<string, LogEventPropertyValue> properties, TextWriter output)
        {
            var precedingDelimiter = string.Empty;
            foreach (var property in properties)
            {
                if (!TopLevelProperties.Contains(property.Key))
                {
                    string key = (property.Key == "sourceContext") ? "SourceContext" : property.Key;
                    this.WriteJsonProperty(key, property.Value, ref precedingDelimiter, output);
                }
            }
        }

        protected virtual void WriteCommonPropertiesValues(IReadOnlyDictionary<string, LogEventPropertyValue> properties, TextWriter output)
        {
            var precedingDelimiter = string.Empty;
            foreach (var property in properties)
            {
                if (TopLevelProperties.Contains(property.Key))
                {
                    this.WriteJsonProperty(property.Key, property.Value, ref precedingDelimiter, output);
                }
            }
        }
    }
}
