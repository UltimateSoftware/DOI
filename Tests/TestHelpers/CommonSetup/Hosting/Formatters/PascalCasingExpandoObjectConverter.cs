using System;
using Newtonsoft.Json;

namespace DDI.Tests.Integration.TestHelpers.CommonSetup.Hosting.Formatters
{
    //
    // Summary:
    //     Converts an ExpandoObject to and from JSON using conversion from camelCasing
    //     to PascalCasing for naming convention.
    public class PascalCasingExpandoObjectConverter : JsonConverter
    {
        public PascalCasingExpandoObjectConverter();

        //
        // Summary:
        //     Gets a value indicating whether this Newtonsoft.Json.JsonConverter can write
        //     JSON.
        public override bool CanWrite { get; }

        //
        // Summary:
        //     Determines whether this instance can convert the specified object type.
        //
        // Parameters:
        //   objectType:
        //     Type of the object.
        //
        // Returns:
        //     true if this instance can convert the specified object type; otherwise, false.
        public override bool CanConvert(Type objectType);
        //
        // Summary:
        //     Reads the JSON representation of the object.
        //
        // Parameters:
        //   reader:
        //     The Newtonsoft.Json.JsonReader to read from.
        //
        //   objectType:
        //     Type of the object.
        //
        //   existingValue:
        //     The existing value of object being read.
        //
        //   serializer:
        //     The calling serializer.
        //
        // Returns:
        //     The object value.
        public override object ReadJson(JsonReader reader, Type objectType, object existingValue, JsonSerializer serializer);
        //
        // Summary:
        //     Writes the JSON representation of the object.
        //
        // Parameters:
        //   writer:
        //     The Newtonsoft.Json.JsonWriter to write to.
        //
        //   value:
        //     The value.
        //
        //   serializer:
        //     The calling serializer.
        public override void WriteJson(JsonWriter writer, object value, JsonSerializer serializer);
    }
}
