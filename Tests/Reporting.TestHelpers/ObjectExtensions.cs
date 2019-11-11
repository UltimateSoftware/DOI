using System;

namespace Reporting.TestHelpers
{
    /// <summary>
    /// GuidExtensions
    /// </summary>
    public static class ObjectExtensions
    {
        /// <summary>
        /// ObjectToGuid
        /// </summary>
        /// <param name="item">item</param>
        /// <returns>Guid</returns>
        public static Guid ToGuid(this object item)
        {
            Guid id;

            if (Guid.TryParse(item.ToString(), out id))
            {
                return id;
            }

            throw new Exception($"'{item}' is invalid value for Guid.");
        }
    }
}
