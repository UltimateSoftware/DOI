using System;
using System.Configuration;
using System.IO;
using Serilog;
using Serilog.Sinks.IOFile;

namespace DDI.Tests.Integration.TestHelpers.CommonSetup.Logging
{
    /// <summary>
    /// LogInitializer
    /// </summary>
    public static class LogInitializer
    {
        /// <summary>
        /// Create
        /// </summary>
        /// <returns>ILogger</returns>
        public static ILogger Create()
        {
            LogEventLevel minimumLogLevel = (LogEventLevel)Enum.Parse(typeof(LogEventLevel), ConfigurationManager.AppSettings["log.minimumLogLevel"]);
            LogDestinations destinations = (LogDestinations)Enum.Parse(typeof(LogDestinations), ConfigurationManager.AppSettings["log.destinations"], true);
            string logFilePath = ConfigurationManager.AppSettings["log.dirPath"] ?? string.Empty;
            string serviceHostName = ConfigurationManager.AppSettings["serviceHostName"];
            logFilePath = Path.Combine(
                logFilePath, string.Format("{0}_{1}_{2}.log", serviceHostName, Guid.NewGuid().ToString("N"), DateTime.UtcNow.ToString("yyyyMMdd_HHmmss")));

            //string mongoDbConnString = ConfigurationManager.ConnectionStrings["logStoreMongoDB"].ConnectionString;
            string sensuAlertsEmailAddress = ConfigurationManager.AppSettings["log.sensuAlertsEmailAddress"] ??
                                             string.Empty;

            var loggerConfiguration = new LoggerConfiguration()
                .Enrich.With(new ApplicationInformationEnricher())
                .MinimumLevel.Is(ApplicationLogger.ConvertToSerilogLevel(minimumLogLevel));

            if (destinations.HasFlag(LogDestinations.Console))
            {
                loggerConfiguration
                    .WriteTo.ColoredConsole(ApplicationLogger.ConvertToSerilogLevel(minimumLogLevel));
            }

            if (destinations.HasFlag(LogDestinations.File) && !string.IsNullOrWhiteSpace(logFilePath))
            {
                // Use NewLine for the closing delimeter.  The logs won't make it to log stash if we use any other closing delimeter.
                loggerConfiguration.WriteTo.Sink(
                    new FileSink(
                        logFilePath,
                        new InlineJsonFormatter(false, Environment.NewLine, true),
                        null),
                    ApplicationLogger.ConvertToSerilogLevel(minimumLogLevel));
            }

            if (destinations.HasFlag(LogDestinations.Sensu))
            {
                loggerConfiguration
                    .WriteTo.Sink(new SensuClientSink(sensuAlertsEmailAddress));
            }

            return loggerConfiguration.CreateLogger();
        }
    }

    /// <summary>
    /// Log Destinations
    /// </summary>
    [Flags]
    public enum LogDestinations
    {
        /// <summary>
        /// 
        /// </summary>
        None = 0,

        /// <summary>
        /// 
        /// </summary>
        MongoDB = 1,

        /// <summary>
        /// 
        /// </summary>
        Console = 2,

        /// <summary>
        /// 
        /// </summary>
        File = 4,

        /// <summary>
        /// 
        /// </summary>
        Sensu = 8
    }
}
