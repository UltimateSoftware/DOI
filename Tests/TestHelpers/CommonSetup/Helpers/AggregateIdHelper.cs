using System;

namespace DDI.Tests.TestHelpers.CommonSetup.Helpers
{
    /// <summary>
    /// Helper functionality to convert from aggregate id of type int to Guid and vice versa. 
    /// </summary>
    public static class AggregateIdHelper
    {
        /// <summary>
        /// To the unique identifier.
        /// </summary>
        /// <param name="value">The value.</param>
        /// <returns>A guid based on an integer.</returns>
        public static Guid ConvertIdFromIntToGuid(this int value)
        {
            try
            {
                var bytes = new byte[16];
                BitConverter.GetBytes(value).CopyTo(bytes, 0);
                return new Guid(bytes);
            }
            catch (Exception)
            {
                throw new Exception($"Unable to convert {value} to Guid");
            }
        }

        /// <summary>
        /// Converts the Guid representation of a number to an integer.
        /// </summary>
        /// <param name="value">The value.</param>
        /// <returns>The corresponding integer</returns>
        public static int ConvertIdFromGuidToInt(this Guid value)
        {
            try
            {
                var bytes = value.ToByteArray();
                var bint = BitConverter.ToInt32(bytes, 0);
                return bint;
            }
            catch (Exception)
            {
                throw new Exception($"Unable to convert {value} to int");
            }
        }
    }
}
