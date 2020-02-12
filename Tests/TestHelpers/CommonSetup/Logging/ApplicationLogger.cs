using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Practices.ObjectBuilder2;
using Serilog.Core;

namespace DDI.Tests.Integration.TestHelpers.CommonSetup.Logging
{
    /// <summary>
    /// The logging API, used for writing log events.
    /// </summary>
    /// <example>
    /// IAppLogger log = ... 
    /// var thing = "World";
    /// log.Information("Hello, {Thing}!", thing);
    /// </example>
    public interface IAppLogger
    {
        /// <summary>
        /// Create a logger that enriches log events with provided properties.
        /// </summary>
        /// <param name="props">Properties that apply in the event.</param>
        /// <returns>A logger that will enrich log events as specified.</returns>
        IAppLogger WithProperty(IEnumerable<KeyValuePair<string, object>> props);

        /// <summary>
        /// Create a logger that enriches log events with the specified property.
        /// </summary>
        /// <param name="propertyName">The property Name. </param>
        /// <param name="value">The value.</param>
        /// <param name="destructureObjects">The destructure Objects.</param>
        /// <returns>A logger that will enrich log events as specified.</returns>
        IAppLogger WithProperty(string propertyName, object value, bool destructureObjects = false);

        /// <summary>
        /// Create a logger that enriches log events with the module and submodule properties.
        /// </summary>
        /// <param name="moduleName">The module Name. </param>
        /// <param name="subModule">The submodule Name.</param>
        /// <returns>A logger that will enrich log events for the module and submodule properties.</returns>
        IAppLogger WithModule(string moduleName, string subModule);

        /// <summary>
        /// Create a logger that enriches log events with the specified correlation id.
        /// </summary>
        /// <param name="correlationId">The correlation id. </param>
        /// <returns>A logger that will enrich log events as specified.</returns>
        IAppLogger WithCorrelation(string correlationId);

        /// <summary>
        /// Create a logger that enriches log events with the specified correlation id.
        /// </summary>
        /// <param name="correlationId">The correlation id. </param>
        /// <returns>A logger that will enrich log events as specified.</returns>
        IAppLogger WithCorrelation(Guid correlationId);

        /// <summary>
        /// Create a logger that marks log events as being from the specified
        /// source type.
        /// </summary>
        /// <typeparam name="TSource">Type generating log messages in the context.</typeparam>
        /// <returns>A logger that will enrich log events as specified.</returns>
        IAppLogger FromSource<TSource>();

        /// <summary>
        /// Create a logger that marks log events as required to be sent to Sensu monitoring system.
        /// </summary>
        /// <param name="alertType">The application custom Sensu alert type.</param>
        /// <returns>A logger that will enrich log events as specified.</returns>
        IAppLogger AsSensuAlert(SensuAlertType alertType);

        /// <summary>
        /// Create a logger that marks log events as being from the specified
        /// source type.
        /// </summary>
        /// <param name="source">Type generating log messages in the context.</param>
        /// <returns>A logger that will enrich log events as specified.</returns>
        IAppLogger FromSource(Type source);

        /// <summary>
        /// Write a log event with the specified level.
        /// </summary>
        /// <param name="level">The level of the event.</param>
        /// <param name="messageTemplate">The messageTemplate</param>
        /// <param name="propertyValues">The propertyValues</param>
        void Write(LogEventLevel level, string messageTemplate, params object[] propertyValues);

        /// <summary>
        /// Write a log event with the specified level and associated exception.
        /// </summary>
        /// <param name="level">The level of the event.</param>
        /// <param name="exception">Exception related to the event.</param>
        /// <param name="messageTemplate">Message template describing the event.</param>
        /// <param name="propertyValues">Objects positionally formatted into the message template.</param>
        void Write(LogEventLevel level, Exception exception, string messageTemplate, params object[] propertyValues);

        /// <summary>
        /// Determine if events at the specified level will be passed through
        /// to the log sinks.
        /// </summary>
        /// <param name="level">Level to check.</param>
        /// <returns>True if the level is enabled; otherwise, false.</returns>
        bool IsEnabled(LogEventLevel level);

        /// <summary>
        /// Write a log event with the <see cref="LogEventLevel.Verbose"/> level and associated exception.
        /// </summary>
        /// <param name="messageTemplate">Message template describing the event.</param>
        /// <param name="propertyValues">Objects positionally formatted into the message template.</param>
        /// <example>
        /// Log.Verbose("Staring into space, wondering if we're alone.");
        /// </example>
        void Verbose(string messageTemplate, params object[] propertyValues);

        /// <summary>
        /// Write a log event with the <see cref="LogEventLevel.Verbose"/> level and associated exception.
        /// </summary>
        /// <param name="exception">Exception related to the event.</param>
        /// <param name="messageTemplate">Message template describing the event.</param>
        /// <param name="propertyValues">Objects positionally formatted into the message template.</param>
        /// <example>
        /// Log.Verbose(ex, "Staring into space, wondering where this comet came from.");
        /// </example>
        void Verbose(Exception exception, string messageTemplate, params object[] propertyValues);

        /// <summary>
        /// Write a log event with the <see cref="System.Diagnostics.Debug"/> level and associated exception.
        /// </summary>
        /// <param name="messageTemplate">Message template describing the event.</param>
        /// <param name="propertyValues">Objects positionally formatted into the message template.</param>
        /// <example>
        /// Log.Debug("Starting up at {StartedAt}.", DateTime.UtcNow);
        /// </example>
        void Debug(string messageTemplate, params object[] propertyValues);

        /// <summary>
        /// Write a log event with the <see cref="System.Diagnostics.Debug"/> level and associated exception.
        /// </summary>
        /// <param name="exception">Exception related to the event.</param>
        /// <param name="messageTemplate">Message template describing the event.</param>
        /// <param name="propertyValues">Objects positionally formatted into the message template.</param>
        /// <example>
        /// Log.Debug(ex, "Swallowing a mundane exception.");
        /// </example>
        void Debug(Exception exception, string messageTemplate, params object[] propertyValues);

        /// <summary>
        /// Write a log event with the <see cref="System.Diagnostics.Debug"/> level and multiple associated exceptions.
        /// </summary>
        /// <param name="exceptions">Collection of exceptions related to the event.</param>
        /// <param name="messageTemplate">Message template describing the event.</param>
        /// <param name="propertyValues">Objects positionally formatted into the message template.</param>
        /// <example>
        /// Log.Debug(ex, "Swallowing a mundane exception.");
        /// </example>
        void Debug(IEnumerable<Exception> exceptions, string messageTemplate, params object[] propertyValues);

        /// <summary>
        /// Write a log event with the System.Diagnostics.Warning level and multiple associated exceptions.
        /// </summary>
        /// <param name="exceptions">Collection of exceptions related to the event.</param>
        /// <param name="messageTemplate">Message template describing the event.</param>
        /// <param name="propertyValues">Objects positionally formatted into the message template.</param>
        /// <example>
        /// Log.Warning(ex, "Swallowing a mundane exception.");
        /// </example>
        void Warning(IEnumerable<Exception> exceptions, string messageTemplate, params object[] propertyValues);

        /// <summary>
        /// Write a log event with the <see cref="LogEventLevel.Information"/> level and associated exception.
        /// </summary>
        /// <param name="messageTemplate">Message template describing the event.</param>
        /// <param name="propertyValues">Objects positionally formatted into the message template.</param>
        /// <example>
        /// Log.Information("Processed {RecordCount} records in {TimeMS}.", records.Length, sw.ElapsedMilliseconds);
        /// </example>
        void Information(string messageTemplate, params object[] propertyValues);

        /// <summary>
        /// Write a log event with the <see cref="LogEventLevel.Information"/> level and associated exception.
        /// </summary>
        /// <param name="exception">Exception related to the event.</param>
        /// <param name="messageTemplate">Message template describing the event.</param>
        /// <param name="propertyValues">Objects positionally formatted into the message template.</param>
        /// <example>
        /// Log.Information(ex, "Processed {RecordCount} records in {TimeMS}.", records.Length, sw.ElapsedMilliseconds);
        /// </example>
        void Information(Exception exception, string messageTemplate, params object[] propertyValues);

        /// <summary>
        /// Write a log event with the <see cref="LogEventLevel.Warning"/> level and associated exception.
        /// </summary>
        /// <param name="messageTemplate">Message template describing the event.</param>
        /// <param name="propertyValues">Objects positionally formatted into the message template.</param>
        /// <example>
        /// Log.Warning("Skipped {SkipCount} records.", skippedRecords.Length);
        /// </example>
        void Warning(string messageTemplate, params object[] propertyValues);

        /// <summary>
        /// Write a log event with the <see cref="LogEventLevel.Warning"/> level and associated exception.
        /// </summary>
        /// <param name="exception">Exception related to the event.</param>
        /// <param name="messageTemplate">Message template describing the event.</param>
        /// <param name="propertyValues">Objects positionally formatted into the message template.</param>
        /// <example>
        /// Log.Warning(ex, "Skipped {SkipCount} records.", skippedRecords.Length);
        /// </example>
        void Warning(Exception exception, string messageTemplate, params object[] propertyValues);

        /// <summary>
        /// Write a log event with the <see cref="LogEventLevel.Warning"/> level and associated exception.
        /// </summary>
        /// <param name="exception">Exception related to the event.</param>
        /// <example>
        /// Log.Warning(ex, "Skipped {SkipCount} records.", skippedRecords.Length);
        /// </example>
        void Warning(Exception exception);

        /// <summary>
        /// Write a log event with the <see cref="LogEventLevel.Error"/> level and associated exception.
        /// </summary>
        /// <param name="messageTemplate">Message template describing the event.</param>
        /// <param name="propertyValues">Objects positionally formatted into the message template.</param>
        /// <example>
        /// Log.Error("Failed {ErrorCount} records.", brokenRecords.Length);
        /// </example>
        void Error(string messageTemplate, params object[] propertyValues);

        /// <summary>
        /// Write a log event with the <see cref="LogEventLevel.Error"/> level and associated exception.
        /// </summary>
        /// <param name="exception">Exception related to the event.</param>
        /// <param name="messageTemplate">Message template describing the event.</param>
        /// <param name="propertyValues">Objects positionally formatted into the message template.</param>
        /// <example>
        /// Log.Error(ex, "Failed {ErrorCount} records.", brokenRecords.Length);
        /// </example>
        void Error(Exception exception, string messageTemplate, params object[] propertyValues);

        /// <summary>
        /// Write a log event with the <see cref="LogEventLevel.Error"/> level and associated exception.
        /// </summary>
        /// <param name="exception">Exception related to the event.</param>
        /// <example>
        /// Log.Error(ex, "Failed {ErrorCount} records.", brokenRecords.Length);
        /// </example>
        void Error(Exception exception);

        /// <summary>
        /// Write a log event with the <see cref="LogEventLevel.Error"/> level and multiple associated exceptions.
        /// </summary>
        /// <param name="exceptions">Collection of exceptions related to the event.</param>
        /// <param name="messageTemplate">Message template describing the event.</param>
        /// <param name="propertyValues">Objects positionally formatted into the message template.</param>
        /// <example>
        /// Log.Error(exs, "Failed {ErrorCount} records.", brokenRecords.Length);
        /// </example>
        void Error(IEnumerable<Exception> exceptions, string messageTemplate, params object[] propertyValues);

        /// <summary>
        /// Write a log event with the <see cref="LogEventLevel.Critical"/> level and associated exception.
        /// </summary>
        /// <param name="messageTemplate">Message template describing the event.</param>
        /// <param name="propertyValues">Objects positionally formatted into the message template.</param>
        /// <example>
        /// Log.Fatal("Process terminating.");
        /// </example>
        void Fatal(string messageTemplate, params object[] propertyValues);

        /// <summary>
        /// Write a log event with the <see cref="LogEventLevel.Critical"/> level and associated exception.
        /// </summary>
        /// <param name="exception">Exception related to the event.</param>
        /// <param name="messageTemplate">Message template describing the event.</param>
        /// <param name="propertyValues">Objects positionally formatted into the message template.</param>
        /// <example>
        /// Log.Fatal(ex, "Process terminating.");
        /// </example>
        void Fatal(Exception exception, string messageTemplate, params object[] propertyValues);
    }

    /// <summary>
    /// An entry point for logging that can be easily referenced by different parts of an application.
    /// </summary>
    /// <example>
    /// IAppLogger log = ... 
    /// var thing = "World";
    /// log.Information("Hello, {Thing}!", thing);
    /// </example>
    public class ApplicationLogger : IAppLogger
    {
        private Serilog.ILogger logger;

        private ApplicationLogger(Serilog.ILogger logger)
        {
            this.logger = logger;
        }

        /// <summary>
        /// NOTE: Do not use this constructor outside of application initialization. Creating a logger is an expensive operation and it should be done only once.
        /// </summary>
        public ApplicationLogger()
        {
            this.logger = LogInitializer.Create();
        }

        /// <summary>
        /// Create a logger that enriches log events with provided properties.
        /// </summary>
        /// <param name="props">Properties that apply in the event.</param>
        /// <returns>A logger that will enrich log events as specified.</returns>
        public IAppLogger WithProperty(IEnumerable<KeyValuePair<string, object>> props)
        {
            Serilog.ILogger locLogger = null;
            props.ToList().ForEach(prop => locLogger = this.logger.ForContext(prop.Key, prop.Value));
            return new ApplicationLogger(locLogger ?? this.logger);
        }

        /// <summary>
        /// Create a logger that enriches log events with the specified property.
        /// </summary>
        /// <param name="propertyName">The property Name. </param>
        /// <param name="value">The value.</param>
        /// <param name="destructureObjects">The destructure Objects.</param>
        /// <returns>A logger that will enrich log events as specified.</returns>
        public IAppLogger WithProperty(string propertyName, object value, bool destructureObjects = false)
        {
            return new ApplicationLogger(this.logger.ForContext(propertyName, value, destructureObjects));
        }

        /// <summary>
        /// Create a logger that enriches log events with the module and submodule properties.
        /// </summary>
        /// <param name="moduleName">The module Name. </param>
        /// <param name="subModule">The submodule Name.</param>
        /// <returns>A logger that will enrich log events for the module and submodule properties.</returns>
        public IAppLogger WithModule(string moduleName, string subModule)
        {
            return new ApplicationLogger(this.logger.ForContext("module", moduleName).ForContext("submodule", subModule));
        }

        /// <summary>
        /// Create a logger that enriches log events with the specified correlation id.
        /// </summary>
        /// <param name="correlationId">The correlation id. </param>
        /// <returns>A logger that will enrich log events as specified.</returns>
        public IAppLogger WithCorrelation(string correlationId)
        {
            return new ApplicationLogger(this.logger.ForContext("correlationId", correlationId, false));
        }

        /// <summary>
        /// Create a logger that enriches log events with the specified correlation id.
        /// </summary>
        /// <param name="correlationId">The correlation id. </param>
        /// <returns>A logger that will enrich log events as specified.</returns>
        public IAppLogger WithCorrelation(Guid correlationId)
        {
            return this.WithCorrelation(correlationId.ToString());
        }

        /// <summary>
        /// Create a logger that marks log events as being from the specified
        /// source type.
        /// </summary>
        /// <typeparam name="TSource">Type generating log messages in the context.</typeparam>
        /// <returns>A logger that will enrich log events as specified.</returns>
        public IAppLogger FromSource<TSource>()
        {
            return this.FromSource(typeof(TSource));
        }

        /// <summary>
        /// Create a logger that marks log events as being from the specified
        /// source type.
        /// </summary>
        /// <param name="source">Type generating log messages in the context.</param>
        /// <returns>A logger that will enrich log events as specified.</returns>
        public IAppLogger FromSource(Type source)
        {
            return new ApplicationLogger(this.logger.ForContext(Constants.SourceContextPropertyName, source.FullName));
        }

        /// <summary>
        /// Create a logger that marks log events as required to be sent to Sensu monitoring system.
        /// </summary>
        /// <param name="alertType">The application custom Sensu alert type.</param>
        /// <returns>A logger that will enrich log events as specified.</returns>
        public IAppLogger AsSensuAlert(SensuAlertType alertType)
        {
            var serilogLogger = this.logger.ForContext(SensuClientSink.SensuAlertTypePropertyName, alertType.ToString());

            var sensuAlertScope = alertType.ResolveScope();

            return !string.IsNullOrEmpty(sensuAlertScope)
                ? new ApplicationLogger(serilogLogger.ForContext(nameof(sensuAlertScope), sensuAlertScope))
                : new ApplicationLogger(serilogLogger);
        }

        /// <summary>
        /// Write a log event with the specified level.
        /// </summary>
        /// <param name="level">The level of the event.</param>
        /// <param name="messageTemplate">The messageTemplate</param>
        /// <param name="propertyValues">The propertyValues</param>
        public void Write(LogEventLevel level, string messageTemplate, params object[] propertyValues)
        {
            this.logger.Write(ConvertToSerilogLevel(level), messageTemplate, propertyValues);
        }

        /// <summary>
        /// Write a log event with the specified level and associated exception.
        /// </summary>
        /// <param name="level">The level of the event.</param>
        /// <param name="exception">Exception related to the event.</param>
        /// <param name="messageTemplate">Message template describing the event.</param>
        /// <param name="propertyValues">Objects positionally formatted into the message template.</param>
        public void Write(LogEventLevel level, Exception exception, string messageTemplate, params object[] propertyValues)
        {
            this.logger.Write(ConvertToSerilogLevel(level), exception, messageTemplate, propertyValues);
        }

        /// <summary>
        /// Determine if events at the specified level will be passed through
        /// to the log sinks.
        /// </summary>
        /// <param name="level">Level to check.</param>
        /// <returns>True if the level is enabled; otherwise, false.</returns>
        public bool IsEnabled(LogEventLevel level)
        {
            return this.logger.IsEnabled(ConvertToSerilogLevel(level));
        }

        /// <summary>
        /// Write a log event with the <see cref="LogEventLevel.Verbose"/> level and associated exception.
        /// </summary>
        /// <param name="messageTemplate">Message template describing the event.</param>
        /// <param name="propertyValues">Objects positionally formatted into the message template.</param>
        /// <example>
        /// Log.Verbose("Staring into space, wondering if we're alone.");
        /// </example>
        public void Verbose(string messageTemplate, params object[] propertyValues)
        {
            this.logger.Verbose(messageTemplate, propertyValues);
        }

        /// <summary>
        /// Write a log event with the <see cref="LogEventLevel.Verbose"/> level and associated exception.
        /// </summary>
        /// <param name="exception">Exception related to the event.</param>
        /// <param name="messageTemplate">Message template describing the event.</param>
        /// <param name="propertyValues">Objects positionally formatted into the message template.</param>
        /// <example>
        /// Log.Verbose(ex, "Staring into space, wondering where this comet came from.");
        /// </example>
        public void Verbose(Exception exception, string messageTemplate, params object[] propertyValues)
        {
            this.logger.Verbose(exception, messageTemplate, propertyValues);
        }

        /// <summary>
        /// Write a log event with the <see cref="System.Diagnostics.Debug"/> level and associated exception.
        /// </summary>
        /// <param name="messageTemplate">Message template describing the event.</param>
        /// <param name="propertyValues">Objects positionally formatted into the message template.</param>
        /// <example>
        /// Log.Debug("Starting up at {StartedAt}.", DateTime.Now);
        /// </example>
        public void Debug(string messageTemplate, params object[] propertyValues)
        {
            this.logger.Debug(messageTemplate, propertyValues);
        }

        /// <summary>
        /// Write a log event with the <see cref="System.Diagnostics.Debug"/> level and associated exception.
        /// </summary>
        /// <param name="exception">Exception related to the event.</param>
        /// <param name="messageTemplate">Message template describing the event.</param>
        /// <param name="propertyValues">Objects positionally formatted into the message template.</param>
        /// <example>
        /// Log.Debug(ex, "Swallowing a mundane exception.");
        /// </example>
        public void Debug(Exception exception, string messageTemplate, params object[] propertyValues)
        {
            this.logger.Debug(exception, messageTemplate, propertyValues);
        }

        /// <summary>
        /// Write a log event with the <see cref="System.Diagnostics.Debug"/> level and multiple associated exceptions.
        /// </summary>
        /// <param name="exceptions">Collection of exceptions related to the event.</param>
        /// <param name="messageTemplate">Message template describing the event.</param>
        /// <param name="propertyValues">Objects positionally formatted into the message template.</param>
        /// <example>
        /// Log.Debug(ex, "Swallowing a mundane exception.");
        /// </example>
        public void Debug(IEnumerable<Exception> exceptions, string messageTemplate, params object[] propertyValues)
        {
            exceptions.GroupBy(ex => new { ExType = ex.GetType(), ex.Message })
                .ToList().ForEach(
                    g =>
                    {
                        Exception ex = g.FirstOrDefault();
                        int count = g.Count();
                        if (ex != null)
                        {
                            if (count == 1)
                            {
                                this.logger.Debug(ex, messageTemplate, propertyValues);
                            }
                            else
                            {
                                this.logger.ForContext("occurrenceCount", count).Debug(ex, messageTemplate, propertyValues);
                            }
                        }
                    });
        }

        /// <summary>
        /// Write a log event with the <see cref="LogEventLevel.Information"/> level and associated exception.
        /// </summary>
        /// <param name="messageTemplate">Message template describing the event.</param>
        /// <param name="propertyValues">Objects positionally formatted into the message template.</param>
        /// <example>
        /// Log.Information("Processed {RecordCount} records in {TimeMS}.", records.Length, sw.ElapsedMilliseconds);
        /// </example>
        public void Information(string messageTemplate, params object[] propertyValues)
        {
            this.logger.Information(messageTemplate, propertyValues);
        }

        /// <summary>
        /// Write a log event with the <see cref="LogEventLevel.Information"/> level and associated exception.
        /// </summary>
        /// <param name="exception">Exception related to the event.</param>
        /// <param name="messageTemplate">Message template describing the event.</param>
        /// <param name="propertyValues">Objects positionally formatted into the message template.</param>
        /// <example>
        /// Log.Information(ex, "Processed {RecordCount} records in {TimeMS}.", records.Length, sw.ElapsedMilliseconds);
        /// </example>
        public void Information(Exception exception, string messageTemplate, params object[] propertyValues)
        {
            this.logger.Information(exception, messageTemplate, propertyValues);
        }

        /// <summary>
        /// Write a log event with the <see cref="LogEventLevel.Warning"/> level and associated exception.
        /// </summary>
        /// <param name="messageTemplate">Message template describing the event.</param>
        /// <param name="propertyValues">Objects positionally formatted into the message template.</param>
        /// <example>
        /// Log.Warning("Skipped {SkipCount} records.", skippedRecords.Length);
        /// </example>
        public void Warning(string messageTemplate, params object[] propertyValues)
        {
            this.logger.Warning(messageTemplate, propertyValues);
        }

        /// <summary>
        /// Write a log event with the System.Diagnostics.Warning level and multiple associated exceptions.
        /// </summary>
        /// <param name="exceptions">Collection of exceptions related to the event.</param>
        /// <param name="messageTemplate">Message template describing the event.</param>
        /// <param name="propertyValues">Objects positionally formatted into the message template.</param>
        /// <example>
        /// Log.Warning(ex, "Swallowing a mundane exception.");
        /// </example>
        public void Warning(IEnumerable<Exception> exceptions, string messageTemplate, params object[] propertyValues)
        {
            exceptions.GroupBy(ex => new { ExType = ex.GetType(), ex.Message })
                .ForEach(
                    g =>
                    {
                        Exception ex = g.FirstOrDefault();
                        int count = g.Count();
                        if (ex != null)
                        {
                            if (count == 1)
                            {
                                this.logger.Warning(ex, messageTemplate, propertyValues);
                            }
                            else
                            {
                                this.logger.ForContext("occurrenceCount", count).Warning(ex, messageTemplate, propertyValues);
                            }
                        }
                    });
        }

        /// <summary>
        /// Write a log event with the <see cref="LogEventLevel.Warning"/> level and associated exception.
        /// </summary>
        /// <param name="exception">Exception related to the event.</param>
        /// <param name="messageTemplate">Message template describing the event.</param>
        /// <param name="propertyValues">Objects positionally formatted into the message template.</param>
        /// <example>
        /// Log.Warning(ex, "Skipped {SkipCount} records.", skippedRecords.Length);
        /// </example>
        public void Warning(Exception exception, string messageTemplate, params object[] propertyValues)
        {
            this.logger.Warning(exception, messageTemplate, propertyValues);
        }

        public void Warning(Exception exception)
        {
            this.logger.Warning(exception, exception.Message);
        }

        /// <summary>
        /// Write a log event with the <see cref="LogEventLevel.Error"/> level and associated exception.
        /// </summary>
        /// <param name="messageTemplate">Message template describing the event.</param>
        /// <param name="propertyValues">Objects positionally formatted into the message template.</param>
        /// <example>
        /// Log.Error("Failed {ErrorCount} records.", brokenRecords.Length);
        /// </example>
        public void Error(string messageTemplate, params object[] propertyValues)
        {
            this.logger.Error(messageTemplate, propertyValues);
        }

        /// <summary>
        /// Write a log event with the <see cref="LogEventLevel.Error"/> level and associated exception.
        /// </summary>
        /// <param name="exception">Exception related to the event.</param>
        /// <param name="messageTemplate">Message template describing the event.</param>
        /// <param name="propertyValues">Objects positionally formatted into the message template.</param>
        /// <example>
        /// Log.Error(ex, "Failed {ErrorCount} records.", brokenRecords.Length);
        /// </example>
        public void Error(Exception exception, string messageTemplate, params object[] propertyValues)
        {
            this.logger.Error(exception, messageTemplate, propertyValues);
        }

        public void Error(Exception exception)
        {
            this.logger.Error(exception, exception.Message);
        }

        /// <summary>
        /// Write a log event with the <see cref="LogEventLevel.Error"/> level and multiple associated exceptions.
        /// </summary>
        /// <param name="exceptions">Collection of exceptions related to the event.</param>
        /// <param name="messageTemplate">Message template describing the event.</param>
        /// <param name="propertyValues">Objects positionally formatted into the message template.</param>
        /// <example>
        /// Log.Error(exs, "Failed {ErrorCount} records.", brokenRecords.Length);
        /// </example>
        public void Error(IEnumerable<Exception> exceptions, string messageTemplate, params object[] propertyValues)
        {
            exceptions.GroupBy(ex => new { ExType = ex.GetType(), ex.Message })
                .ToList().ForEach(
                    g =>
                    {
                        Exception ex = g.FirstOrDefault();
                        int count = g.Count();
                        if (ex != null)
                        {
                            if (count == 1)
                            {
                                this.logger.Error(ex, messageTemplate, propertyValues);
                            }
                            else
                            {
                                this.logger.ForContext("occurrenceCount", count).Error(ex, messageTemplate, propertyValues);
                            }
                        }
                    });
        }

        /// <summary>
        /// Write a log event with the <see cref="LogEventLevel.Critical"/> level and associated exception.
        /// </summary>
        /// <param name="messageTemplate">Message template describing the event.</param>
        /// <param name="propertyValues">Objects positionally formatted into the message template.</param>
        /// <example>
        /// Log.Fatal("Process terminating.");
        /// </example>
        public void Fatal(string messageTemplate, params object[] propertyValues)
        {
            this.logger.Fatal(messageTemplate, propertyValues);
        }

        /// <summary>
        /// Write a log event with the <see cref="LogEventLevel.Critical"/> level and associated exception.
        /// </summary>
        /// <param name="exception">Exception related to the event.</param>
        /// <param name="messageTemplate">Message template describing the event.</param>
        /// <param name="propertyValues">Objects positionally formatted into the message template.</param>
        /// <example>
        /// Log.Fatal(ex, "Process terminating.");
        /// </example>
        public void Fatal(Exception exception, string messageTemplate, params object[] propertyValues)
        {
            this.logger.Fatal(exception, messageTemplate, propertyValues);
        }

        internal static Serilog.Events.LogEventLevel ConvertToSerilogLevel(LogEventLevel level)
        {
            switch (level)
            {
                case LogEventLevel.Verbose:
                    return Serilog.Events.LogEventLevel.Verbose;
                case LogEventLevel.Warning:
                    return Serilog.Events.LogEventLevel.Warning;
                case LogEventLevel.Error:
                    return Serilog.Events.LogEventLevel.Error;
                case LogEventLevel.Critical:
                    return Serilog.Events.LogEventLevel.Fatal;
            }

            return Serilog.Events.LogEventLevel.Information;
        }

        internal static TaxHub.Common.Logging.LogEventLevel ConvertFromSerilogLevel(Serilog.Events.LogEventLevel level)
        {
            switch (level)
            {
                case Serilog.Events.LogEventLevel.Verbose:
                    return LogEventLevel.Verbose;
                case Serilog.Events.LogEventLevel.Warning:
                    return LogEventLevel.Warning;
                case Serilog.Events.LogEventLevel.Error:
                    return LogEventLevel.Error;
                case Serilog.Events.LogEventLevel.Fatal:
                    return LogEventLevel.Critical;
            }

            return LogEventLevel.Information;
        }
    }

    /// <summary>
    /// Specifies the meaning and relative importance of a log event.
    /// </summary>
    public enum LogEventLevel
    {
        /// <summary>
        /// Anything and everything you might want to know about
        /// a running block of code.
        /// </summary>
        Verbose = 16,

        /// <summary>
        /// The lifeblood of operational intelligence - things
        /// happen.
        /// </summary>
        Information = 8,

        /// <summary>
        /// Service is degraded or endangered.
        /// </summary>
        Warning = 4,

        /// <summary>
        /// Functionality is unavailable, invariants are broken
        /// or data is lost.
        /// </summary>
        Error = 2,

        /// <summary>
        /// If you have a pager, it goes off when one of these
        /// occurs.
        /// </summary>
        Critical = 1
    }
}
