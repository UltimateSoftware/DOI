using System;
using System.Collections.Generic;


namespace DDI.Tests.Integration.TestHelpers.DataAccess
{
    //
    // Summary:
    //     Class represents a collection of filters supplied to the API call.
    public class FilterCollection : List<KeyValuePair<string, string>>
    {
        //
        // Summary:
        //     Default constructor.
        public FilterCollection();
        //
        // Summary:
        //     Default constructor.
        //
        // Parameters:
        //   collection:
        //     The collection to add.
        public FilterCollection(IEnumerable<KeyValuePair<string, string>> collection);

        public static FilterCollection FromList(IEnumerable<KeyValuePair<string, string>> filters);
        //
        // Summary:
        //     Method returns boolean value whether or not filter with specified named exists
        //     in the collection.
        //
        // Parameters:
        //   filterName:
        //     The name of filter. Casing is ignored.
        //
        // Returns:
        //     Returns boolean.
        public bool HasFilter(string filterName);
        //
        // Summary:
        //     Parses filter with given name as an array of string objects. Returns boolean
        //     indicator whether filter exists.
        //
        // Parameters:
        //   filterName:
        //     The filter name. Casing is ignored.
        //
        //   value:
        //     The output parameter for parsed value.
        //
        // Returns:
        //     Returns true if filter exists; otherwise false.
        //
        // Exceptions:
        //   T:System.FormatException:
        //     Throws exception if filter exists, but parsing fails.
        public bool ParseAsArray(string filterName, out string[] value);
        //
        // Summary:
        //     Parses filter with given name as an array of T type objects. Returns boolean
        //     indicator whether filter exists.
        //
        // Parameters:
        //   filterName:
        //     The filter name. Casing is ignored.
        //
        //   value:
        //     The output parameter for parsed value.
        //
        // Returns:
        //     Returns true if filter exists; otherwise false.
        //
        // Exceptions:
        //   T:System.FormatException:
        //     Throws exception if filter exists, but parsing fails.
        public bool ParseAsArray<T>(string filterName, out T[] value) where T : struct, IConvertible;
        public bool ParseAsArray(string filterName, out Guid[] value);
        //
        // Summary:
        //     Parses filter with given name as Boolean object. Returns boolean indicator whether
        //     filter exists.
        //
        // Parameters:
        //   filterName:
        //     The filter name. Casing is ignored.
        //
        //   value:
        //     The output parameter for parsed value.
        //
        // Returns:
        //     Returns true if filter exists; otherwise false.
        //
        // Exceptions:
        //   T:System.FormatException:
        //     Throws exception if filter exists, but parsing fails.
        public bool ParseAsBoolean(string filterName, out bool value);
        //
        // Summary:
        //     Parses filter with given name as Byte object. Returns boolean indicator whether
        //     filter exists.
        //
        // Parameters:
        //   filterName:
        //     The filter name. Casing is ignored.
        //
        //   value:
        //     The output parameter for parsed value.
        //
        // Returns:
        //     Returns true if filter exists; otherwise false.
        //
        // Exceptions:
        //   T:System.FormatException:
        //     Throws exception if filter exists, but parsing fails.
        public bool ParseAsByte(string filterName, out byte value);
        //
        // Summary:
        //     Parses filter with given name as DateTime object. Returns boolean indicator whether
        //     filter exists.
        //
        // Parameters:
        //   filterName:
        //     The filter name. Casing is ignored.
        //
        //   value:
        //     The output parameter for parsed value.
        //
        // Returns:
        //     Returns true if filter exists; otherwise false.
        //
        // Exceptions:
        //   T:System.FormatException:
        //     Throws exception if filter exists, but parsing fails.
        public bool ParseAsDateTime(string filterName, out DateTime value);
        //
        // Summary:
        //     Parses filter with given name as Decimal object. Returns boolean indicator whether
        //     filter exists.
        //
        // Parameters:
        //   filterName:
        //     The filter name. Casing is ignored.
        //
        //   value:
        //     The output parameter for parsed value.
        //
        // Returns:
        //     Returns true if filter exists; otherwise false.
        //
        // Exceptions:
        //   T:System.FormatException:
        //     Throws exception if filter exists, but parsing fails.
        public bool ParseAsDecimal(string filterName, out decimal value);
        //
        // Summary:
        //     Parses filter with given name as Double object. Returns boolean indicator whether
        //     filter exists.
        //
        // Parameters:
        //   filterName:
        //     The filter name. Casing is ignored.
        //
        //   value:
        //     The output parameter for parsed value.
        //
        // Returns:
        //     Returns true if filter exists; otherwise false.
        //
        // Exceptions:
        //   T:System.FormatException:
        //     Throws exception if filter exists, but parsing fails.
        public bool ParseAsDouble(string filterName, out double value);
        //
        // Summary:
        //     Parses filter with given name as an array of T Enum type objects. Returns boolean
        //     indicator whether filter exists.
        //
        // Parameters:
        //   filterName:
        //     The filter name. Casing is ignored.
        //
        //   value:
        //     The output parameter for parsed value.
        //
        // Returns:
        //     Returns true if filter exists; otherwise false.
        //
        // Exceptions:
        //   T:System.FormatException:
        //     Throws exception if filter exists, but parsing fails.
        public bool ParseAsEnumArray<T>(string filterName, out T[] value) where T : struct, IConvertible;
        //
        // Summary:
        //     Parses filter with given name as Float object. Returns boolean indicator whether
        //     filter exists.
        //
        // Parameters:
        //   filterName:
        //     The filter name. Casing is ignored.
        //
        //   value:
        //     The output parameter for parsed value.
        //
        // Returns:
        //     Returns true if filter exists; otherwise false.
        //
        // Exceptions:
        //   T:System.FormatException:
        //     Throws exception if filter exists, but parsing fails.
        public bool ParseAsFloat(string filterName, out float value);
        //
        // Summary:
        //     Parses filter with given name as Guid object. Returns boolean indicator whether
        //     filter exists.
        //
        // Parameters:
        //   filterName:
        //     The filter name. Casing is ignored.
        //
        //   value:
        //     The output parameter for parsed value.
        //
        // Returns:
        //     Returns true if filter exists; otherwise false.
        //
        // Exceptions:
        //   T:System.FormatException:
        //     Throws exception if filter exists, but parsing fails.
        public bool ParseAsGuid(string filterName, out Guid value);
        //
        // Summary:
        //     Parses filter with given name as Int16 object. Returns boolean indicator whether
        //     filter exists.
        //
        // Parameters:
        //   filterName:
        //     The filter name. Casing is ignored.
        //
        //   value:
        //     The output parameter for parsed value.
        //
        // Returns:
        //     Returns true if filter exists; otherwise false.
        //
        // Exceptions:
        //   T:System.FormatException:
        //     Throws exception if filter exists, but parsing fails.
        public bool ParseAsInt16(string filterName, out short value);
        //
        // Summary:
        //     Parses filter with given name as Int32 object. Returns boolean indicator whether
        //     filter exists.
        //
        // Parameters:
        //   filterName:
        //     The filter name. Casing is ignored.
        //
        //   value:
        //     The output parameter for parsed value.
        //
        // Returns:
        //     Returns true if filter exists; otherwise false.
        //
        // Exceptions:
        //   T:System.FormatException:
        //     Throws exception if filter exists, but parsing fails.
        public bool ParseAsInt32(string filterName, out int value);
        //
        // Summary:
        //     Parses filter with given name as Int64 object. Returns boolean indicator whether
        //     filter exists.
        //
        // Parameters:
        //   filterName:
        //     The filter name. Casing is ignored.
        //
        //   value:
        //     The output parameter for parsed value.
        //
        // Returns:
        //     Returns true if filter exists; otherwise false.
        //
        // Exceptions:
        //   T:System.FormatException:
        //     Throws exception if filter exists, but parsing fails.
        public bool ParseAsInt64(string filterName, out long value);
        //
        // Summary:
        //     Parses filter with given name as String object. Returns boolean indicator whether
        //     filter exists.
        //
        // Parameters:
        //   filterName:
        //     The filter name. Casing is ignored.
        //
        //   value:
        //     The output parameter for parsed value.
        //
        // Returns:
        //     Returns true if filter exists; otherwise false.
        //
        // Exceptions:
        //   T:System.FormatException:
        //     Throws exception if filter exists, but parsing fails.
        //
        // Remarks:
        //     Empty string or white spaces are ignored.
        public bool ParseAsString(string filterName, out string value);
        //
        // Summary:
        //     Parses filter with given name as String object. Returns boolean indicator whether
        //     filter exists.
        //
        // Parameters:
        //   filterName:
        //     The filter name. Casing is ignored.
        //
        //   allowEmptyOrWhiteSpace:
        //     If true assumes no filter present if filter is an empty string or consists of
        //     white spaces.
        //
        //   value:
        //     The output parameter for parsed value.
        //
        // Returns:
        //     Returns true if filter exists; otherwise false.
        //
        // Exceptions:
        //   T:System.FormatException:
        //     Throws exception if filter exists, but parsing fails.
        public bool ParseAsString(string filterName, bool allowEmptyOrWhiteSpace, out string value);
    }
}
