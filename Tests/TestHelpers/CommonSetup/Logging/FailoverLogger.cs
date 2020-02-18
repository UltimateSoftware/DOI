using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using Serilog.Events;
using Serilog.Parsing;

namespace DDI.Tests.TestHelpers.CommonSetup.Logging
{
    /// <summary>
    /// Class is designed to log an error message into a file when main logger fails to start. 
    /// Use this class only within the application start to report startup failure.
    /// </summary>
    public class FailoverLogger
    {
        public FailoverLogger()
        {
        }

        /// <summary>
        /// Method attempts to write a log file with exception. It suppresses any exceptions encountered during the process.
        /// </summary>
        /// <param name="exception">The exception to write.</param>
        /// <returns>Returns boolean indicator of success.</returns>
        public bool TryWriteException(Exception exception)
        {
            return this.TryWriteException(exception, string.Empty);
        }

        /// <summary>
        /// Method attempts to write a log file with exception and additional details which will be prepended to message.
        /// It suppresses any exceptions encountered during the process.
        /// </summary>
        /// <param name="exception">The exception to write.</param>
        /// <param name="additionalDetails">additional details which will be prepended to message</param>
        /// <returns>Returns boolean indicator of success.</returns>
        public bool TryWriteException(Exception exception, string additionalDetails)
        {
            try
            {
                var applicationAssembly = Assembly.GetEntryAssembly() ?? Assembly.GetExecutingAssembly();
                var assembly = applicationAssembly.GetName();
                string appService = "SPS";
                if (!string.IsNullOrWhiteSpace(ConfigurationManager.AppSettings["appService"]))
                {
                    appService = ConfigurationManager.AppSettings["appService"].ToUpper().Trim();
                }

                LogEvent logData = new LogEvent(DateTimeOffset.Now, Serilog.Events.LogEventLevel.Fatal, exception, new MessageTemplate($"{additionalDetails ?? string.Empty} {exception.Message}", new List<MessageTemplateToken>()), new List<LogEventProperty>());
                logData.AddPropertyIfAbsent(new LogEventProperty("ApplicationName", new ScalarValue(assembly.Name)));
                logData.AddPropertyIfAbsent(new LogEventProperty("ServiceName", new ScalarValue(appService)));
                logData.AddPropertyIfAbsent(new LogEventProperty("Version", new ScalarValue(assembly.Version.ToString())));

                string logFilePath = ConfigurationManager.AppSettings["log.dirPath"] ?? string.Empty;
                if (!string.IsNullOrWhiteSpace(logFilePath))
                {
                    logFilePath = Path.Combine(logFilePath, $"{assembly.Name}_failover_{Guid.NewGuid().ToString("N")}_{DateTime.UtcNow.ToString("yyyyMMdd_HHmmss")}.log");
                    using (var stream = File.OpenWrite(logFilePath))
                    {
                        using (TextWriter wrt = new StreamWriter(stream))
                        {
                            var formatter = new InlineJsonFormatter(false, string.Empty);
                            formatter.Format(logData, wrt);
                            wrt.Flush();
                            wrt.Close();
                        }
                    }
                }

                return true;
            }
            catch (Exception ex)
            {
                Debug.WriteLine(ex.StackTrace);
                return false;
            }
        }
    }
}
