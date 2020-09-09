using System;
using System.Collections.Generic;
using System.Linq;

namespace DOI.Tests.TestHelpers
{
    /// <summary>
    /// GuidExtensions
    /// </summary>
    public static class ObjectExtensions
    {
        public static Dictionary<string, object> GetPropertyValues(this object obj)
        {
            return obj.GetType()
                .GetProperties()
                .Select(prop => new { prop.Name, value = prop.GetValue(obj) }).ToDictionary(x => x.Name, y => y.value);
        }

        public static string ObjectToString(this object item)
        {
            return item?.ToString();
        }

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

        /// <summary>
        /// To the unique identifier.
        /// </summary>
        /// <param name="item">The item.</param>
        /// <returns>Same Guid item</returns>
        public static Guid ToGuid(this Guid item)
        {
            return item;
        }

        /// <summary>
        /// ObjectToDateTime
        /// </summary>
        /// <param name="item">item</param>
        /// <returns>DateTime</returns>
        public static DateTime ObjectToDateTime(this object item)
        {
            DateTime dt;

            CheckForNull(item);

            if (DateTime.TryParse(item.ToString(), out dt))
            {
                return dt;
            }

            return DateTime.MinValue;
        }

        /// <summary>
        /// ObjectToDecimal
        /// </summary>
        /// <param name="item">item</param>
        /// <returns>decimal</returns>
        public static decimal ObjectToDecimal(this object item)
        {
            decimal number;

            CheckForNull(item);

            if (decimal.TryParse(item.ToString(), out number))
            {
                return number;
            }

            return default(decimal);
        }

        /// <summary>
        /// ObjectToInteger
        /// </summary>
        /// <param name="item">item</param>
        /// <returns>int</returns>
        public static int ObjectToInteger(this object item)
        {
            int number;

            CheckForNull(item);

            if (int.TryParse(item.ToString(), out number))
            {
                return number;
            }

            return default(int);
        }

        private static void CheckForNull(object item)
        {
            if (item == null)
            {
                throw new ArgumentNullException(nameof(item));
            }
        }
    }
}