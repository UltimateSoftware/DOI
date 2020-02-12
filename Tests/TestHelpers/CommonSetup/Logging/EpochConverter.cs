using System;
using System.Globalization;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace DDI.Tests.Integration.TestHelpers.CommonSetup.Logging
{
    internal class EpochConverter : DateTimeConverterBase
    {
        private static readonly DateTime UtcEpochStart = new DateTime(1970, 1, 1).ToUniversalTime();

        public EpochConverter()
            : base()
        {
        }

        public override void WriteJson(JsonWriter writer, object value, JsonSerializer serializer)
        {
            var epoch = Convert.ToInt64(((DateTime)value).ToUniversalTime().Subtract(UtcEpochStart).TotalSeconds);
            writer.WriteRawValue(epoch.ToString(CultureInfo.InvariantCulture));
        }

        public override object ReadJson(JsonReader reader, Type objectType, object existingValue, JsonSerializer serializer)
        {
            if (reader.Value == null)
            {
                return null;
            }

            return UtcEpochStart.AddSeconds((long)reader.Value);
        }
    }
}
