using System;
using System.Collections;
using System.Diagnostics;
using System.IO;
using System.Text.RegularExpressions;
using JetBrains.Annotations;
using SmartHub.Hosting.Annotations;
using SmartHub.Hosting.Exceptions;

namespace DOI.Tests.TestHelpers.CommonSetup.Hosting
{
    /// <summary>
    /// Provides methods for checking method arguments for validity and throwing localizable exceptions for invalid
    /// arguments or argument combinations.
    /// </summary>
    /// <remarks>The alternative names for this class were: Validator, Pact, Deal.</remarks>
    [DebuggerStepThrough]
    public static class Convention
    {
        #region Null/Empty Checking

        /// <summary>
        /// Checks the specified parameter to ensure it is not null and if so, throws an <see cref="T:ArgumentNullException"/>.
        /// </summary>
        /// <param name="value">The parameter value to compare with null.</param>
        /// <param name="parameterName">Name of the parameter.</param>
        /// <param name="message">The message to pass to the exception.</param>
        /// <exception cref="T:ArgumentNullException">The parameter is null.</exception>
        [ContractAnnotation("value:null => halt")]
        public static void ThrowIfNull([ValidatedNotNull] object value, string parameterName = null, string message = null)
        {
            if (value == null)
            {
                if (string.IsNullOrEmpty(message))
                {
                    throw new ArgumentNullException(parameterName);
                }
                else
                {
                    throw new ArgumentNullException(parameterName, message);
                }
            }
        }

        /// <summary>
        /// Checks the specified string to ensure it is not null or empty and if so, throws an <see cref="T:ArgumentNullException"/>.
        /// </summary>
        /// <param name="value">The parameter value to check.</param>
        /// <param name="parameterName">Name of the parameter.</param>
        /// <param name="message">The message to pass to the exception.</param>
        /// <exception cref="T:ArgumentNullException">The parameter is null.</exception>
        /// <exception cref="T:ArgumentException">The parameter is an empty string or a string consisting of only whitespace.</exception>
        [ContractAnnotation("value:null => halt")]
        public static void ThrowIfNullOrEmpty([ValidatedNotNullAttribute] string value, string parameterName = null, string message = null)
        {
            if (value == null)
            {
                if (string.IsNullOrEmpty(message))
                {
                    throw new ArgumentNullException(parameterName);
                }
                else
                {
                    throw new ArgumentNullException(parameterName, message);
                }
            }

            if (value.Length == 0)
            {
                throw new ArgumentException(
                    string.Format("{0} cannot be an empty string." + (message ?? string.Empty), parameterName ?? "Value"),
                    parameterName);
            }
        }

        /// <summary>
        /// Checks the specified string to ensure it is not null, empty, or consists solely of whitespace and if so, throws an <see cref="T:ArgumentNullException"/>.
        /// </summary>
        /// <param name="value">The parameter value to check.</param>
        /// <param name="parameterName">Name of the parameter.</param>
        /// <exception cref="T:ArgumentNullException">The parameter is null.</exception>
        /// <exception cref="T:ArgumentException">The parameter is an empty string or a string consisting of only whitespace.</exception>
        [ContractAnnotation("value:null => halt")]
        public static void ThrowIfNullOrWhitespace([ValidatedNotNullAttribute] string value, string parameterName = null)
        {
            if (value == null)
            {
                throw new ArgumentNullException(parameterName);
            }

            if (value.Length == 0)
            {
                throw new ArgumentException(
                    $"{parameterName ?? "Value"} cannot be an empty string.",
                    parameterName);
            }

            for (int i = 0; i < value.Length; i++)
            {
                if (!char.IsWhiteSpace(value, i))
                {
                    // Found a non-whitespace character
                    return;
                }
            }

            throw new ArgumentException($"{parameterName ?? "Value"} cannot consist entirely of whitespace.", parameterName);
        }

        /// <summary>
        /// Checks the specified array to ensure it is not null or empty and if so, throws an <see cref="T:ArgumentNullException"/>.
        /// </summary>
        /// <param name="array">The parameter value to check.</param>
        /// <param name="parameterName">Name of the parameter.</param>
        /// <exception cref="T:ArgumentNullException">The parameter is null.</exception>
        /// <exception cref="T:ArgumentException">The parameter is an empty array.</exception>
        [ContractAnnotation("value:null => halt")]
        public static void ThrowIfNullOrEmpty([ValidatedNotNullAttribute] Array array, string parameterName = null)
        {
            if (array == null)
            {
                throw new ArgumentNullException(parameterName);
            }

            if (array.Length == 0)
            {
                throw new ArgumentException($"{parameterName ?? "Array"} cannot be an empty array.", parameterName);
            }
        }

        /// <summary>
        /// Checks the specified IList to ensure it is not null or empty and if so, throws an <see cref="T:ArgumentNullException"/>.
        /// </summary>
        /// <param name="list">The parameter value to check.</param>
        /// <param name="parameterName">Name of the parameter.</param>
        /// <exception cref="T:ArgumentNullException">The parameter is null.</exception>
        /// <exception cref="T:ArgumentException">The parameter is an empty array.</exception>
        [ContractAnnotation("value:null => halt")]
        public static void ThrowIfNullOrEmpty([ValidatedNotNullAttribute] IList list, string parameterName = null)
        {
            if (list == null)
            {
                throw new ArgumentNullException(parameterName);
            }

            if (list.Count == 0)
            {
                throw new ArgumentException($"{parameterName ?? "List"} cannot be an empty list.", parameterName);
            }
        }

        /// <summary>
        /// Checks the specified guid to ensure it is not empty and if so, throws an <see cref="T:ArgumentException"/>.
        /// </summary>
        /// <param name="guid">The parameter value to check.</param>
        /// <param name="parameterName">Name of the parameter.</param>
        /// <param name="message">Optional custom error message.</param>
        /// <exception cref="T:ArgumentException">The parameter is an empty guid.</exception>
        public static void ThrowIfEmpty(Guid guid, string parameterName = null, string message = null)
        {
            if (guid == Guid.Empty)
            {
                if (string.IsNullOrWhiteSpace(message))
                {
                    throw new ArgumentException($"{parameterName ?? "guid"} cannot be an empty guid.", parameterName);
                }
                else
                {
                    throw new ArgumentException(message, parameterName);
                }
            }
        }

        /// <summary>
        /// Throws if the specified guid is null or empty.
        /// </summary>
        /// <param name="guid">The unique identifier.</param>
        /// <param name="parameterName">Name of the parameter.</param>
        /// <param name="message">The message.</param>
        public static void ThrowIfNullOrEmpty(Guid? guid, string parameterName = null, string message = null)
        {
            if (!guid.HasValue)
            {
                throw new ArgumentException($"{parameterName ?? "guid"} should have a value.", parameterName);
            }

            ThrowIfEmpty(guid.Value, parameterName, message);
        }

        /// <summary>
        /// Checks the specified array to ensure it does not contain any null references and if so,
        /// throws an <see cref="T:ArgumentException"/>.
        /// </summary>
        /// <remarks>
        /// If the value specified in the <paramref name="array"/> parameter is itself null, no check
        /// is performed. Use <see cref="M:ThrowIfNull"/> or <see cref="M:ThrowIfNullOrEmpty"/> if
        /// aDOItional validation is needed.
        /// </remarks>
        /// <param name="array">The array to check. Only the first dimension is checked.</param>
        /// <param name="parameterName">Name of the parameter.</param>
        /// <exception cref="T:ArgumentException">The array contains at least one null reference.</exception>
        public static void ThrowIfNullElement(Array array, string parameterName = null)
        {
            // Don't check null arrays
            if (array != null)
            {
                for (long i = 0; i < array.LongLength; i++)
                {
                    if (array.GetValue(i) == null)
                    {
                        throw new ArgumentException($"{parameterName ?? "Array"} cannot contain null references.", parameterName);
                    }
                }
            }
        }

        /// <summary>
        /// Checks the specified collection to ensure it does not contain any null references and if so,
        /// throws an <see cref="T:ArgumentException"/>.
        /// </summary>
        /// <remarks>
        /// If the value specified in the <paramref name="collection"/> parameter is itself null, no check
        /// is performed. Use <see cref="M:ThrowIfNull"/> or <see cref="M:ThrowIfNullOrEmpty"/> if
        /// aDOItional validation is needed.
        /// The collections non-generic enumerator will be used to enumerate the collection, even if the
        /// type implements IList.
        /// </remarks>
        /// <param name="collection">The collection to check.</param>
        /// <param name="parameterName">Name of the parameter.</param>
        /// <exception cref="T:ArgumentException">The collection contains at least one null reference.</exception>
        public static void ThrowIfNullElement(System.Collections.IEnumerable collection, string parameterName = null)
        {
            // Don't check null collections
            if (collection != null)
            {
                foreach (object item in collection)
                {
                    if (item == null)
                    {
                        throw new ArgumentException($"{parameterName ?? "Collection"} cannot contain null references.", parameterName);
                    }
                }
            }
        }
        #endregion

        #region Pattern Checking

        /// <summary>
        /// Matches the specified <paramref name="value"/> against a regular expression, <paramref name="regex"/>,
        /// and throws an <see cref="T:ArgumentException"/> if the pattern does not match.
        /// </summary>
        /// <remarks>
        /// If the value specified in the <paramref name="value"/> parameter is itself null, no check
        /// is performed. Use <see cref="M:ThrowIfNull"/> or <see cref="M:ThrowIfNullOrEmpty"/> if
        /// aDOItional validation is needed.
        /// </remarks>
        /// <param name="value">The parameter, which is not checked if it's null.</param>
        /// <param name="regex">The regular expression pattern to match.</param>
        /// <exception cref="T:ArgumentException"><paramref name="value"/> does not match the regular expression.</exception>
        public static void ThrowIfPatternFails(string value, string regex)
        {
            ThrowIfPatternFails(value, null, new Regex(regex));
        }

        /// <summary>
        /// Matches the specified <paramref name="value"/> against a regular expression, <paramref name="regex"/>,
        /// and throws an <see cref="T:ArgumentException"/> if the pattern does not match.
        /// </summary>
        /// <remarks>
        /// If the value specified in the <paramref name="value"/> parameter is itself null, no check
        /// is performed. Use <see cref="M:ThrowIfNull"/> or <see cref="M:ThrowIfNullOrEmpty"/> if
        /// aDOItional validation is needed.
        /// </remarks>
        /// <param name="value">The parameter, which is not checked if it's null.</param>
        /// <param name="parameterName">Name of the parameter.</param>
        /// <param name="regex">The regular expression pattern to match.</param>
        /// <exception cref="T:ArgumentException"><paramref name="value"/> does not match the regular expression.</exception>
        public static void ThrowIfPatternFails(string value, string parameterName, string regex)
        {
            ThrowIfPatternFails(value, parameterName, new Regex(regex));
        }

        /// <summary>
        /// Matches the specified <paramref name="value"/> against a regular expression, <paramref name="regex"/>,
        /// and throws an <see cref="T:ArgumentException"/> if the pattern does not match.
        /// </summary>
        /// <remarks>
        /// If the value specified in the <paramref name="value"/> parameter is itself null, no check
        /// is performed. Use <see cref="M:ThrowIfNull"/> or <see cref="M:ThrowIfNullOrEmpty"/> if
        /// aDOItional validation is needed.
        /// </remarks>
        /// <param name="value">The parameter, which is not checked if it's null.</param>
        /// <param name="regex">The regular expression pattern to match.</param>
        /// <exception cref="T:ArgumentException"><paramref name="value"/> does not match the regular expression.</exception>
        public static void ThrowIfPatternFails(string value, Regex regex)
        {
            ThrowIfPatternFails(value, null, regex);
        }

        /// <summary>
        /// Matches the specified <paramref name="value"/> against a regular expression, <paramref name="regex"/>,
        /// and throws an <see cref="T:ArgumentException"/> if the pattern does not match.
        /// </summary>
        /// <remarks>
        /// If the value specified in the <paramref name="value"/> parameter is itself null, no check
        /// is performed. Use <see cref="M:ThrowIfNull"/> or <see cref="M:ThrowIfNullOrEmpty"/> if
        /// aDOItional validation is needed.
        /// </remarks>
        /// <param name="value">The parameter, which is not checked if it's null.</param>
        /// <param name="parameterName">Name of the parameter.</param>
        /// <param name="regex">The regular expression pattern to match.</param>
        /// <exception cref="T:ArgumentException"><paramref name="value"/> does not match the regular expression.</exception>
        public static void ThrowIfPatternFails(string value, string parameterName, Regex regex)
        {
            // Don't check null strings
            if (value != null)
            {
                if (!regex.IsMatch(value))
                {
                    throw new ArgumentException($"{parameterName ?? "Value"} does not match the expected format.", parameterName);
                }
            }
        }

        #endregion

        #region Range Checking

        /// <summary>
        /// Throws an <see cref="T:ArgumentOutOfRangeException"/> exception of the specified <paramref name="value"/> is not
        /// a valid value within the specified range.
        /// </summary>
        /// <param name="value">The enum value to validate.</param>
        /// <param name="parameterName">The name of the parameter.</param>
        /// <exception cref="T:ArgumentOutOfRangeException"><paramref name="value"/> is not a valid enum value.</exception>
        public static void ThrowIfOutOfRange(Enum value, string parameterName = null)
        {
            Type enumType = value.GetType();

            if (!Enum.IsDefined(enumType, value))
            {
                ThrowArgumentOutOfRangeException(parameterName, value, $"{parameterName ?? "Value"} is not a valid {enumType.Name} value.");
            }
        }

        /// <summary>
        /// Throws an <see cref="T:ArgumentOutOfRangeException"/> exception of the specified <paramref name="value"/> is not
        /// a valid value within the specified range.
        /// </summary>
        /// <param name="value">The parameter value to validate.</param>
        /// <param name="parameterName">The name of the parameter.</param>
        /// <param name="min">The minimum allowable value (inclusive).</param>
        /// <param name="max">The maximum allowable value (inclusive).</param>
        /// <exception cref="T:ArgumentOutOfRangeException"><paramref name="value"/> is not within the inclusive range.</exception>
        public static void ThrowIfOutOfRange(int value, string parameterName = null, int min = 0, int max = int.MaxValue)
        {
            if (value > max || value < min)
            {
                ThrowArgumentOutOfRangeException(parameterName, value, $"{parameterName ?? "Value"} is out of range.");
            }
        }

        /// <summary>
        /// Throws an <see cref="T:ArgumentOutOfRangeException"/> exception of the specified <paramref name="value"/> is not
        /// a valid value within the specified range.
        /// </summary>
        /// <param name="value">The parameter value to validate.</param>
        /// <param name="parameterName">The name of the parameter.</param>
        /// <param name="min">The minimum allowable value (inclusive).</param>
        /// <param name="max">The maximum allowable value (inclusive).</param>
        /// <exception cref="T:ArgumentOutOfRangeException"><paramref name="value"/> is not within the inclusive range.</exception>
        public static void ThrowIfOutOfRange(long value, string parameterName = null, long min = 0, long max = long.MaxValue)
        {
            if (value > max || value < min)
            {
                ThrowArgumentOutOfRangeException(parameterName, value, $"{parameterName ?? "Value"} is out of range.");
            }
        }

        /// <summary>
        /// Throws an <see cref="T:ArgumentOutOfRangeException"/> exception of the specified <paramref name="value"/> is not
        /// a valid value within the specified range.
        /// </summary>
        /// <param name="value">The parameter value to validate.</param>
        /// <param name="parameterName">The name of the parameter.</param>
        /// <param name="min">The minimum allowable value (inclusive).</param>
        /// <param name="max">The maximum allowable value (inclusive).</param>
        /// <exception cref="T:ArgumentOutOfRangeException"><paramref name="value"/> is not within the inclusive range.</exception>
        public static void ThrowIfOutOfRange(decimal value, string parameterName = null, decimal min = 0, decimal max = decimal.MaxValue)
        {
            if (value > max || value < min)
            {
                ThrowArgumentOutOfRangeException(parameterName, value, $"{parameterName ?? "Value"} is out of range.");
            }
        }

        /// <summary>
        /// Throws an <see cref="T:ArgumentOutOfRangeException"/> exception of the specified <paramref name="value"/> is not
        /// a valid value within the specified range.
        /// </summary>
        /// <param name="value">The parameter value to validate.</param>
        /// <param name="parameterName">The name of the parameter.</param>
        /// <param name="min">The minimum allowable value (inclusive).</param>
        /// <param name="max">The maximum allowable value (inclusive).</param>
        /// <exception cref="T:ArgumentOutOfRangeException"><paramref name="value"/> is not within the inclusive range.</exception>
        public static void ThrowIfOutOfRange(double value, string parameterName = null, double min = 0, double max = double.MaxValue)
        {
            if (value > max || value < min)
            {
                ThrowArgumentOutOfRangeException(parameterName, value, $"{parameterName ?? "Value"} is out of range.");
            }
        }

        /// <summary>
        /// Throws an <see cref="T:ArgumentOutOfRangeException"/> exception of the specified <paramref name="value"/> is not
        /// a valid value within the specified range.
        /// </summary>
        /// <remarks>
        /// If the value specified in the <paramref name="value"/> parameter is a null reference, the check will not
        /// be performed. Use <see cref="M:ThrowIfNull"/> if aDOItional validation is needed.
        /// </remarks>
        /// <param name="value">The parameter value to validate. If this value is null, no check is performed.</param>
        /// <param name="min">The minimum allowable value (inclusive).</param>
        /// <param name="max">The maximum allowable value (inclusive).</param>
        /// <exception cref="T:ArgumentOutOfRangeException"><paramref name="value"/> is not within the inclusive range.</exception>
        /// <typeparam name="T">bla</typeparam>
        public static void ThrowIfOutOfRange<T>(T value, T min, T max)
            where T : IComparable
        {
            // Can't use optional parameters here because we do not know what sensible defaults to use for
            // min and max value - especially if T is a reference type
            ThrowIfOutOfRange<T>(value, null, min, max);
        }

        /// <summary>
        /// Throws an <see cref="T:ArgumentOutOfRangeException"/> exception of the specified <paramref name="value"/> is not
        /// a valid value within the specified range.
        /// </summary>
        /// <remarks>
        /// If the value specified in the <paramref name="value"/> parameter is a null reference, the check will not
        /// be performed. Use <see cref="M:ThrowIfNull"/> if aDOItional validation is needed.
        /// </remarks>
        /// <param name="value">The parameter value to validate. If this value is null, no check is performed.</param>
        /// <param name="parameterName">The name of the parameter.</param>
        /// <param name="min">The minimum allowable value (inclusive).</param>
        /// <param name="max">The maximum allowable value (inclusive).</param>
        /// <exception cref="T:ArgumentOutOfRangeException"><paramref name="value"/> is not within the inclusive range.</exception>
        /// <typeparam name="T">bla</typeparam>
        public static void ThrowIfOutOfRange<T>(T value, string parameterName, T min, T max)
            where T : IComparable
        {
            // Skip null values
            if (value != null)
            {
                if (min != null && value.CompareTo(min) < 0)
                {
                    ThrowArgumentOutOfRangeException(
                        parameterName,
                        value,
                        $"{parameterName ?? "Value"} is out of range.");
                }

                if (max != null && value.CompareTo(max) > 0)
                {
                    ThrowArgumentOutOfRangeException(
                        parameterName,
                        value,
                        $"{parameterName ?? "Value"} is out of range.");
                }
            }
        }

        #endregion

        #region Negative Checking

        /// <summary>
        /// Throws an <see cref="T:ArgumentOutOfRangeException"/> exception of the specified <paramref name="value"/> is less
        /// than zero.
        /// </summary>
        /// <param name="value">The parameter value to validate.</param>
        /// <param name="parameterName">The name of the parameter.</param>
        /// <exception cref="T:ArgumentOutOfRangeException"><paramref name="value"/> is negative.</exception>
        public static void ThrowIfNegative(int value, string parameterName = null)
        {
            if (value < 0)
            {
                ThrowArgumentOutOfRangeException(parameterName, value, $"{parameterName ?? "Value"} cannot be negative.");
            }
        }

        /// <summary>
        /// Throws an <see cref="T:ArgumentOutOfRangeException"/> exception of the specified <paramref name="value"/> is less
        /// than zero.
        /// </summary>
        /// <param name="value">The parameter value to validate.</param>
        /// <param name="parameterName">The name of the parameter.</param>
        /// <exception cref="T:ArgumentOutOfRangeException"><paramref name="value"/> is negative.</exception>
        public static void ThrowIfNegative(long value, string parameterName = null)
        {
            if (value < 0L)
            {
                ThrowArgumentOutOfRangeException(parameterName, value, $"{parameterName ?? "Value"} cannot be negative.");
            }
        }

        /// <summary>
        /// Throws an <see cref="T:ArgumentOutOfRangeException"/> exception of the specified <paramref name="value"/> is less
        /// than zero.
        /// </summary>
        /// <param name="value">The parameter value to validate.</param>
        /// <param name="parameterName">The name of the parameter.</param>
        /// <exception cref="T:ArgumentOutOfRangeException"><paramref name="value"/> is negative.</exception>
        public static void ThrowIfNegative(decimal value, string parameterName = null)
        {
            if (value < 0m)
            {
                ThrowArgumentOutOfRangeException(parameterName, value, $"{parameterName ?? "Value"} cannot be negative.");
            }
        }

        /// <summary>
        /// Throws an <see cref="T:ArgumentOutOfRangeException"/> exception of the specified <paramref name="value"/> is less
        /// than zero.
        /// </summary>
        /// <param name="value">The parameter value to validate.</param>
        /// <param name="parameterName">The name of the parameter.</param>
        /// <exception cref="T:ArgumentOutOfRangeException"><paramref name="value"/> is negative.</exception>
        public static void ThrowIfNegative(double value, string parameterName = null)
        {
            if (value < 0d)
            {
                ThrowArgumentOutOfRangeException(parameterName, value, $"{parameterName ?? "Value"} cannot be negative.");
            }
        }

        /// <summary>
        /// Throws an <see cref="T:ArgumentOutOfRangeException"/> exception of the specified <paramref name="value"/> is less
        /// than zero.
        /// </summary>
        /// <param name="value">The parameter value to validate.</param>
        /// <param name="parameterName">The name of the parameter.</param>
        /// <exception cref="T:ArgumentOutOfRangeException"><paramref name="value"/> is negative.</exception>
        public static void ThrowIfNegative(TimeSpan value, string parameterName = null)
        {
            if (value.Ticks < 0L)
            {
                ThrowArgumentOutOfRangeException(parameterName, value, $"{parameterName ?? "Value"} cannot be negative.");
            }
        }

        /// <summary>
        /// Throws an <see cref="T:ArgumentOutOfRangeException"/> exception of the specified <paramref name="value"/> is less
        /// than one.
        /// </summary>
        /// <param name="value">The parameter value to validate.</param>
        /// <param name="parameterName">The name of the parameter.</param>
        /// <exception cref="T:ArgumentOutOfRangeException"><paramref name="value"/> is not greater than zero.</exception>
        public static void ThrowIfNegativeOrZero(int value, string parameterName)
        {
            if (value <= 0)
            {
                ThrowArgumentOutOfRangeException(parameterName, value, $"{parameterName ?? "Value"} must be greater than zero.");
            }
        }

        /// <summary>
        /// Throws an <see cref="T:ArgumentOutOfRangeException"/> exception of the specified <paramref name="value"/> is less
        /// than one.
        /// </summary>
        /// <param name="value">The parameter value to validate.</param>
        /// <param name="parameterName">The name of the parameter.</param>
        /// <exception cref="T:ArgumentOutOfRangeException"><paramref name="value"/> is not greater than zero.</exception>
        public static void ThrowIfNegativeOrZero(long value, string parameterName)
        {
            if (value <= 0L)
            {
                ThrowArgumentOutOfRangeException(parameterName, value, $"{parameterName ?? "Value"} must be greater than zero.");
            }
        }

        /// <summary>
        /// Throws an <see cref="ArgumentOutOfRangeException"/> exception of the specified <paramref name="value"/> is less
        /// than one.
        /// </summary>
        /// <param name="value">The parameter value to validate.</param>
        /// <param name="parameterName">The name of the parameter.</param>
        /// <exception cref="T:ArgumentOutOfRangeException"><paramref name="value"/> is not greater than zero.</exception>
        public static void ThrowIfNegativeOrZero(decimal value, string parameterName)
        {
            if (value <= 0m)
            {
                ThrowArgumentOutOfRangeException(parameterName, value, $"{parameterName ?? "Value"} must be greater than zero.");
            }
        }

        /// <summary>
        /// Throws an <see cref="ArgumentOutOfRangeException"/> exception of the specified <paramref name="value"/> is less
        /// than or equal to zero.
        /// </summary>
        /// <param name="value">The parameter value to validate.</param>
        /// <param name="parameterName">The name of the parameter.</param>
        /// <exception cref="T:ArgumentOutOfRangeException"><paramref name="value"/> is not greater than zero.</exception>
        public static void ThrowIfNegativeOrZero(double value, string parameterName)
        {
            if (value <= 0d)
            {
                ThrowArgumentOutOfRangeException(parameterName, value, $"{parameterName ?? "Value"} must be greater than zero.");
            }
        }

        /// <summary>
        /// Throws an <see cref="ArgumentOutOfRangeException"/> exception of the specified <paramref name="value"/> is less
        /// than or equal to zero.
        /// </summary>
        /// <param name="value">The parameter value to validate.</param>
        /// <param name="parameterName">The name of the parameter.</param>
        /// <exception cref="T:ArgumentOutOfRangeException"><paramref name="value"/> is not greater than zero.</exception>
        public static void ThrowIfNegativeOrZero(TimeSpan value, string parameterName = null)
        {
            if (value.Ticks <= 0L)
            {
                ThrowArgumentOutOfRangeException(parameterName, value, $"{parameterName ?? "Value"} must be greater than zero.");
            }
        }

        #endregion

        #region IO Exceptions

        private const int MaxPath = 260;

        /// <summary>
        /// Throws an <see cref="T:ArgumentException"/> if the specified <paramref name="fileName"/> contains
        /// characters that are invalid in a file name such as directory separators or other reserved characters.
        /// Throws a <see cref="T:PathTooLongException"/> if the file name is too long.
        /// </summary>
        /// <remarks>
        /// If the <paramref name="fileName"/> parameter is null, no checks will be performed. Use the
        /// <see cref="M:ThrowIfNull"/> if aDOItional checks are necessary.
        /// </remarks>
        /// <param name="fileName">The file name to validate.</param>
        /// <param name="parameterName">The name of the parameter.</param>
        /// <exception cref="T:PathTooLongException">The file name contains too many characters.</exception>
        /// <exception cref="T:ArgumentException">The file name contains invalid characters.</exception>
        public static void ThrowIfInvalidFileName(string fileName, string parameterName = null)
        {
            if (fileName != null)
            {
                if (fileName.Length > MaxPath)
                {
                    throw new PathTooLongException($"{parameterName ?? "Path"} is too long.");
                }

                char[] invalidChars = Path.GetInvalidFileNameChars();

                foreach (char c in fileName)
                {
                    if (Array.IndexOf(invalidChars, c) > -1)
                    {
                        throw new ArgumentException($"{parameterName ?? "File name"} contains invalid characters.", parameterName);
                    }
                }
            }
        }

        /// <summary>
        /// Throws an <see cref="T:ArgumentException"/> if the specified <paramref name="path"/> contains
        /// characters that are invalid in a path name such as directory separators or other reserved characters.
        /// Throws a <see cref="T:PathTooLongException"/> if the path is too long.
        /// </summary>
        /// <remarks>
        /// If the <paramref name="path"/> parameter is null, no checks will be performed. Use the
        /// <see cref="M:ThrowIfNull"/> if aDOItional checks are necessary.
        /// </remarks>
        /// <param name="path">The path to validate.</param>
        /// <param name="parameterName">The name of the parameter.</param>
        /// <exception cref="T:PathTooLongException">The path contains too many characters.</exception>
        /// <exception cref="T:ArgumentException">The path contains invalid characters.</exception>
        public static void ThrowIfInvalidPath(string path, string parameterName = null)
        {
            if (path != null)
            {
                if (path.Length > MaxPath)
                {
                    throw new PathTooLongException($"{parameterName ?? "Path"} is too long.");
                }

                char[] invalidChars = Path.GetInvalidPathChars();

                foreach (char c in path)
                {
                    if (Array.IndexOf(invalidChars, c) > -1)
                    {
                        throw new ArgumentException($"{parameterName ?? "Path"} contains invalid characters.", parameterName);
                    }
                }
            }
        }

        /// <summary>
        /// Throws a <see cref="T:FileNotFoundException"/> if the specified file does not exist on disk.
        /// </summary>
        /// <remarks>
        /// If the value specified in the <paramref name="fileName"/> parameter is itself null, no check
        /// is performed. Use <see cref="M:ThrowIfNull"/> or <see cref="M:ThrowIfNullOrEmpty"/> if
        /// aDOItional validation is needed.
        /// </remarks>
        /// <param name="fileName">The path and file name to check the existence of.</param>
        /// <param name="parameterName">The name of the parameter.</param>
        /// <exception cref="T:FileNotFoundException">The <paramref name="fileName"/> specified does not exist.</exception>
        public static void ThrowIfFileNotFound(string fileName, string parameterName = null)
        {
            if (fileName != null)
            {
                if (!File.Exists(fileName))
                {
                    throw new FileNotFoundException($"{parameterName ?? "File"}: File not found <{fileName}>", fileName);
                }
            }
        }

        /// <summary>
        /// Throws a <see cref="T:DirectoryNotFoundException"/> if the specified file does not exist on disk.
        /// </summary>
        /// <remarks>
        /// If the value specified in the <paramref name="directory"/> parameter is itself null, no check
        /// is performed. Use <see cref="M:ThrowIfNull"/> or <see cref="M:ThrowIfNullOrEmpty"/> if
        /// aDOItional validation is needed.
        /// </remarks>
        /// <param name="directory">The directory path to check the existence of.</param>
        /// <param name="parameterName">The name of the parameter.</param>
        /// <exception cref="T:DirectoryNotFoundException">The <paramref name="directory"/> specified does not exist.</exception>
        public static void ThrowIfDirectoryNotFound(string directory, string parameterName = null)
        {
            if (directory != null)
            {
                if (!Directory.Exists(directory))
                {
                    throw new DirectoryNotFoundException($"{parameterName ?? "Directory"}: Directory not found <{directory}>");
                }
            }
        }

        #endregion

        #region Exception Helpers

        /// <summary>
        /// Throws a <see cref="T:ArgumentOutOfRangeException"/>
        /// </summary>
        /// <param name="paramName">The name of the parameter that caused the exception.</param>
        /// <param name="actualValue">The value of the argument that causes this exception.</param>
        /// <param name="message">The message that describes the error.</param>
        [ContractAnnotation("=> halt")]
        private static void ThrowArgumentOutOfRangeException(string paramName, object actualValue, string message)
        {
            throw new ArgumentOutOfRangeException(paramName, actualValue, message);
        }

        /// <summary>
        /// Asserts condition and throws an exception if the condition fails.
        /// </summary>
        /// <param name="condition">The condition to validate.</param>
        /// <param name="message">The exception message.</param>
        public static void Require(Func<bool> condition, string message)
        {
            if (!condition())
            {
                throw new Exception(message);
            }
        }

        /// <summary>
        /// Asserts condition and throws an exception if the condition fails.
        /// </summary>
        /// <param name="condition">The condition to validate.</param>
        /// <param name="format">The exception message template (format).</param>
        /// <param name="args">The exception message template arguments.</param>
        public static void Require(Func<bool> condition, string format, params object[] args)
        {
            if (!condition())
            {
                throw new Exception(string.Format(format, args));
            }
        }

        /// <summary>
        /// Asserts condition and throws an exception if the condition fails.
        /// </summary>
        /// <param name="condition">The condition to validate.</param>
        /// <param name="message">The exception message.</param>
        [ContractAnnotation("condition:false => halt")]
        public static void Require(bool condition, string message)
        {
            if (!condition)
            {
                throw new Exception(message);
            }
        }

        /// <summary>
        /// Asserts condition and throws an exception if the condition fails.
        /// </summary>
        /// <param name="condition">The condition to validate.</param>
        /// <param name="format">The exception message template (format).</param>
        /// <param name="args">The exception message template arguments.</param>
        [ContractAnnotation("condition:false => halt")]
        public static void Require(bool condition, string format, params object[] args)
        {
            if (!condition)
            {
                throw new Exception(string.Format(format, args));
            }
        }

        /// <summary>
        /// Asserts condition and throws a Authorization exception if the condition fails.
        /// </summary>
        /// <param name="condition">The condition to validate.</param>
        /// <param name="message">The exception message.</param>
        [ContractAnnotation("condition:false => halt")]
        public static void RequireAuthorization(bool condition, string message)
        {
            if (!condition)
            {
                throw new AuthorizationException(message);
            }
        }

        /// <summary>
        /// Asserts condition and throws a BusinessRule exception if the condition fails.
        /// </summary>
        /// <param name="condition">The condition to validate.</param>
        /// <param name="message">The exception message.</param>
        [ContractAnnotation("condition:false => halt")]
        public static void RequireBusinessRule(bool condition, string message)
        {
            if (!condition)
            {
                throw new BusinessRuleException(message);
            }
        }

        #endregion
    }
}
