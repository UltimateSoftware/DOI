using System;
using System.ServiceProcess;

namespace DDI.Tests.TestHelpers
{
    public class WindowsServiceHelper
    {
        /// <summary>
        /// Attempts to starts SQLSERVERAGENT service if its status is different from [RUNNING].
        /// </summary>
        /// <returns>
        /// Returns TRUE if the status SQLServerAgent service was equal to [RUNNING] timeout specified. Else, it throws a System.TimeoutException().
        /// </returns>
        public static bool StartSqlServerAgent()
        {
            const string servicename = "SQLSERVERAGENT";
            const long timeoutmilliseconds = 10000;

            if (StartService(servicename, timeoutmilliseconds))
            {
                return true;
            }
            else
            {
                throw new System.TimeoutException($"Failed to start {servicename} service within {timeoutmilliseconds} milliseconds.");
            }
        }

        /// <summary>
        /// Attempts to starts a Windows service if its status is different from [RUNNING].
        /// </summary>
        /// <param name="serviceName"></param>
        /// <param name="timeoutmilliseconds"></param>
        /// <returns>Returns TRUE if the status of the service was equal to [RUNNING] within the timeout specified. Else, it returns FALSE.</returns>
        private static bool StartService(string serviceName, long timeoutmilliseconds)
        {
            foreach (var serviceController in ServiceController.GetServices())
            {
                if (serviceController.ServiceName == serviceName)
                {
                    if (serviceController.Status == ServiceControllerStatus.Running)
                    {
                        return true;
                    }
                    else
                    {
                        serviceController.Start();
                        Func<bool> checkIfServiceIsRunningAlready = () =>
                        {
                            serviceController.Refresh();
                            return serviceController.Status == ServiceControllerStatus.Running;
                        };

                        if (WaitHelper.WaitFor(checkIfServiceIsRunningAlready, timeoutmilliseconds))
                        {
                            return true;
                        }
                    }
                }
            }
            return false;
        }
    }
}
