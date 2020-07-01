using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DOI.TestHelpers
{
    public static class GenericDictionaryExtensions
    {
        /// <summary>
        /// Tries to get the value and if not exists returns the default value 
        /// for the value type instead of throwing an exception
        /// </summary>
        /// <typeparam name="TK">Key type</typeparam>
        /// <typeparam name="TV">value type</typeparam>
        /// <param name="dictionary">dictionary to extend</param>
        /// <param name="key">Key to search</param>
        /// <param name="defaultValue">Default value. Optional</param>
        /// <returns>The value if exists, otherwise the default value</returns>
        public static TV GetValue<TK, TV>(this IDictionary<TK, TV> dictionary, TK key, TV defaultValue = default(TV))
        {
            TV value;
            return dictionary.TryGetValue(key, out value) ? value : defaultValue;
        }
    }
}
