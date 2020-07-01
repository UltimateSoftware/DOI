using System;
using System.Configuration;
using System.Diagnostics;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Reflection;
using Serilog.Core;
using Serilog.Events;

namespace DOI.Tests.TestHelpers.CommonSetup.Logging
{
    /// <summary>
    /// The application information enricher.
    /// </summary>
    public class ApplicationInformationEnricher : ILogEventEnricher
    {
        private string processName;

        private string appName;

        private string appVersion;

        private string appService = "TXM";

        private string hostName;

        private string ipAddress;

        /// <summary>
        /// Enrich the log event.
        /// </summary>
        /// <param name="logEvent">The log event to enrich.</param>
        /// <param name="propertyFactory">Factory for creating new properties to add to the event.</param>
        public void Enrich(LogEvent logEvent, ILogEventPropertyFactory propertyFactory)
        {
            if (this.processName == null)
            {
                var applicationAssembly = Assembly.GetEntryAssembly() ?? Assembly.GetExecutingAssembly();
                var assembly = applicationAssembly.GetName();
                this.processName = Process.GetCurrentProcess().ProcessName;
                this.appName = assembly.Name;
                this.appVersion = assembly.Version.ToString();
                if (!string.IsNullOrWhiteSpace(ConfigurationManager.AppSettings["appService"]))
                {
                    this.appService = ConfigurationManager.AppSettings["appService"].ToUpper().Trim();
                }

                IPHostEntry host = Dns.GetHostEntry(Dns.GetHostName());
                if (host != null)
                {
                    this.hostName = host.HostName;
                    IPAddress addr = host.AddressList.FirstOrDefault(ip => ip.AddressFamily == AddressFamily.InterNetwork);
                    if (addr != null)
                    {
                        this.ipAddress = addr.MapToIPv4().ToString();
                    }
                }
            }

            logEvent.AddPropertyIfAbsent(propertyFactory.CreateProperty("SourceIp", this.ipAddress));
            logEvent.AddPropertyIfAbsent(propertyFactory.CreateProperty("HostName", this.hostName));
            logEvent.AddPropertyIfAbsent(propertyFactory.CreateProperty("ApplicationName", this.appName));
            logEvent.AddPropertyIfAbsent(propertyFactory.CreateProperty("ServiceName", this.appService));
            logEvent.AddPropertyIfAbsent(propertyFactory.CreateProperty("Version", this.appVersion));

            //include Data elements
            if (logEvent.Exception != null)
            {
                foreach (var key in logEvent.Exception.Data.Keys)
                {
                    logEvent.AddPropertyIfAbsent(propertyFactory.CreateProperty(key.ToString().Replace(".", "_"), logEvent.Exception.Data[key]));
                }

                var ex = logEvent.Exception.GetBaseException();
                foreach (var key in ex.Data.Keys)
                {
                    logEvent.AddPropertyIfAbsent(propertyFactory.CreateProperty(key.ToString().Replace(".", "_"), ex.Data[key]));
                }
            }
        }
    }
}
