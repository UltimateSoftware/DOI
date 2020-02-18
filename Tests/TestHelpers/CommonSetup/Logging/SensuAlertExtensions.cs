using System;
using DDI.Tests.TestHelpers.CommonSetup.Logging;

namespace DDI.Tests.Integration.TestHelpers.CommonSetup.Logging
{
    public static class SensuAlertExtensions
    {
        public static string ResolveScope(this SensuAlertType sensuAlertType)
        {
            try
            {
                var fieldInfo = sensuAlertType.GetType().GetField(sensuAlertType.ToString());
                var attributes = fieldInfo.GetCustomAttributes(typeof(SensuAlertScopeAttribute), false);

                return attributes.Length == 0 ? string.Empty : ((SensuAlertScopeAttribute)attributes[0]).SensuAlertScope;
            }
            catch (Exception)
            {
                return string.Empty;
            }
        }
    }
}
