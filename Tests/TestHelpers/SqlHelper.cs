// <copyright file="SqlHelper.cs" company="PlaceholderCompany">
// Copyright (c) PlaceholderCompany. All rights reserved.
// </copyright>

namespace DDI.Tests.TestHelpers
{
    using System;
    using System.Collections.Generic;
    using System.Data;
    using System.Data.SqlClient;
    using System.Linq;
    using System.Threading.Tasks;
    using Microsoft.Practices.Unity.Utility;

    public class SqlHelper
    {
        public string GetConnectionString()
        {
            return @"Provider = SQLOLEDB.1; Password = Password01; Persist Security Info = True; User ID = sa; Initial Catalog = DDI; Data Source =.";
        }

        public int Execute(SqlCommand command)
        {
            int retVal;
            SqlConnection connection = null;
            try
            {
                connection = new SqlConnection(this.GetConnectionString());
                command.Connection = connection;
                command.CommandTimeout = 0;

                connection.Open();
                retVal = command.ExecuteNonQuery();
            }
            finally
            {
                connection?.Dispose();
            }

            return retVal;
        }

        public int Execute(string sql, int commandTimeOut = 30, bool marsEnabled = true)
        {
            int retVal;
            SqlCommand command = null;
            SqlConnection connection = null;
            try
            {
                var connectionString = this.GetConnectionString();
                connection = new SqlConnection(connectionString);
                command = new SqlCommand(sql, connection)
                {
                    CommandType = CommandType.Text,
                    CommandTimeout = commandTimeOut
                };
                connection.Open();
                retVal = command.ExecuteNonQuery();
            }
            finally
            {
                command?.Dispose();
                connection?.Dispose();
            }

            return retVal;
        }

        public int Execute(SqlConnection connection, string sqlStatement)
        {
            int retVal;

            using (SqlCommand command = new SqlCommand(sqlStatement, connection))
            {
                command.CommandTimeout = 0;
                command.CommandType = CommandType.Text;
                connection.RetrieveStatistics();

                retVal = command.ExecuteNonQuery();
            }

            return retVal;
        }

        public string ExecuteGetInfoMessageOnly(string sql, int commandTimeOut = 30, bool marsEnabled = false)
        {
            string retVal = string.Empty;
            SqlCommand command = null;
            SqlConnection connection = null;
            try
            {
                var connectionString = this.GetConnectionString();
                connection = new SqlConnection(connectionString);
                command = new SqlCommand(sql, connection)
                {
                    CommandType = CommandType.Text,
                    CommandTimeout = commandTimeOut
                };

                connection.InfoMessage += (s, e) =>
                {
                    retVal += e.Message;
                };

                connection.Open();
                command.ExecuteNonQuery();
            }
            finally
            {
                command?.Dispose();
                connection?.Dispose();
            }

            return retVal;
        }

        public async Task<int> ExecuteAsync(string sql, int commandTimeOut = 30, bool marsEnabled = true)
        {
            int retVal;
            var connectionString = this.GetConnectionString();
            using (var connection = new SqlConnection(connectionString))
            {
                using (var command = new SqlCommand(sql, connection))
                {
                    command.CommandType = CommandType.Text;
                    command.CommandTimeout = commandTimeOut;
                    connection.Open();
                    retVal = await command.ExecuteNonQueryAsync();
                }
            }

            return retVal;
        }

        public T ExecuteScalar<T>(string sql)
        {
            T retVal = default(T);
            SqlCommand command = null;
            SqlConnection connection = null;
            try
            {
                connection = new SqlConnection(this.GetConnectionString());
                command = new SqlCommand(sql, connection)
                {
                    CommandType = CommandType.Text,
                    CommandTimeout = 0
                };
                connection.Open();
                object obj = command.ExecuteScalar();
                if (obj != null && obj != DBNull.Value)
                {
                    retVal = (T)obj;
                }
            }
            catch (Exception e)
            {
                throw e;
            }
            finally
            {
                command?.Dispose();
                connection?.Dispose();
            }

            return retVal;
        }

        public T ExecuteScalar<T>(SqlConnection connection, string sql)
        {
            T retVal = default(T);

            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                try
                {
                    command.CommandTimeout = 0;
                    command.CommandType = CommandType.Text;
                    object obj = command.ExecuteScalar();
                    if (obj != null && obj != DBNull.Value)
                    {
                        retVal = (T)obj;
                    }
                }
                catch (Exception e)
                {
                    throw e;
                }
            }

            return retVal;
        }

        public SqlDataReader ExecuteReader(string sql)
        {
            // ExecuteReader leaves the connection open so that data can be read
            // Make sure to call CloseConnection when you're done reading data
            SqlDataReader retVal;
            SqlCommand command = null;
            try
            {
                var connection = new SqlConnection(this.GetConnectionString());
                command = new SqlCommand(sql, connection)
                {
                    CommandType = CommandType.Text,
                    CommandTimeout = 0
                };
                connection.Open();
                retVal = command.ExecuteReader(CommandBehavior.CloseConnection);
            }
            finally
            {
                command?.Dispose();
            }

            return retVal;
        }

        /*
        /// <summary>
        ///
        /// </summary>
        /// <param name="sqlcommand"></param>
        /// <returns>
        /// Returns a List of Rows. Each Row is a list of Pairs. Each Pair contains columns name and value.
        /// </returns>*/
        public List<List<Pair<string, object>>> ExecuteQuery(SqlCommand sqlcommand)
        {
            using (var connection = new SqlConnection(this.GetConnectionString()))
            {
                var result = new List<List<Pair<string, object>>>();
                sqlcommand.CommandType = CommandType.Text;
                sqlcommand.CommandTimeout = 0;
                sqlcommand.Connection = connection;
                connection.Open();

                SqlDataReader reader = sqlcommand.ExecuteReader(CommandBehavior.CloseConnection);

                while (reader.Read())
                {
                    var row = new List<Pair<string, object>>();
                    for (int i = 0; i < reader.FieldCount; i++)
                    {
                        row.Add(new Pair<string, object>(reader.GetName(i), reader.GetValue(i)));
                    }

                    result.Add(row);
                }

                return result;
            }
        }

        /*
        /// <summary>
        /// Executes a query and returns the result which can have multiple result sets.
        /// </summary>
        /// <param name="sqlcommand"></param>
        /// <returns>
        /// Returns a List of Result Sets.
        /// A Result Set is represented as a List of Rows.
        /// A Row is represented as a list of Columns.
        /// A Column represented as a Pair of string and object, the column name is the string and the value is the object.
        /// </returns>*/
        public List<List<List<Pair<string, object>>>> ExecuteQueryMultipleResultSets(SqlCommand sqlcommand)
        {
            using (var connection = new SqlConnection(this.GetConnectionString()))
            {
                var resultSets = new List<List<List<Pair<string, object>>>>();
                sqlcommand.CommandType = CommandType.Text;
                sqlcommand.CommandTimeout = 0;
                sqlcommand.Connection = connection;
                connection.Open();

                SqlDataReader reader = sqlcommand.ExecuteReader(CommandBehavior.CloseConnection);

                do
                {
                    var result = new List<List<Pair<string, object>>>();
                    while (reader.Read())
                    {
                        var row = new List<Pair<string, object>>();
                        for (int i = 0; i < reader.FieldCount; i++)
                        {
                            row.Add(new Pair<string, object>(reader.GetName(i), reader.GetValue(i)));
                        }

                        result.Add(row);
                    }

                    resultSets.Add(result);
                }
                while (reader.NextResult()); // go to next result set

                return resultSets;
            }
        }

        public T ExecuteScalar<T>(SqlCommand command)
        {
            var retVal = default(T);
            using (var connection = new SqlConnection(this.GetConnectionString()))
            {
                command.Connection = connection;
                command.CommandTimeout = 0;

                this.OpenConnection(connection);
                var obj = command.ExecuteScalar();
                if (obj != null && obj != DBNull.Value)
                {
                    retVal = (T)obj;
                }
            }

            return retVal;
        }

        public List<T> ExecuteList<T>(string sql, int commandTimeOut = 30)
        {
            var retVal = new List<T>();
            using (var connection = new SqlConnection(this.GetConnectionString()))
            {
                using (var command = new SqlCommand(sql, connection)
                {
                    CommandType = CommandType.Text,
                    CommandTimeout = commandTimeOut
                })
                {
                    this.OpenConnection(connection);
                    using (var reader = command.ExecuteReader(CommandBehavior.SequentialAccess))
                    {
                        while (reader.Read())
                        {
                            retVal.Add((T)reader.GetValue(0));
                        }
                    }
                }
            }

            return retVal;
        }

        public List<T> GetList<T>(string sql, int commandTimeOut = 30)
        {
            var results = new List<T>();
            using (var connection = new SqlConnection(this.GetConnectionString()))
            {
                using (var command = new SqlCommand(sql, connection)
                {
                    CommandType = CommandType.Text,
                    CommandTimeout = commandTimeOut
                })
                {
                    this.OpenConnection(connection);
                    using (var reader = command.ExecuteReader(CommandBehavior.SequentialAccess))
                    {
                        var properties = typeof(T).GetProperties();

                        while (reader.Read())
                        {
                            var tableDic = Enumerable.Range(0, reader.FieldCount).ToDictionary(i => reader.GetName(i).ToUpper(), i => reader.GetValue(i));

                            var item = Activator.CreateInstance<T>();
                            foreach (var property in properties)
                            {
                                var propName = property.Name.ToUpper();
                                if (!tableDic.Keys.Contains(propName))
                                {
                                    continue;
                                }

                                if (tableDic[propName].GetType() == typeof(DBNull))
                                {
                                    continue;
                                }

                                var convertTo = Nullable.GetUnderlyingType(property.PropertyType) ?? property.PropertyType;
                                if (convertTo.IsEnum)
                                {
                                    property.SetValue(item, Enum.ToObject(convertTo, tableDic[propName]), null);
                                    continue;
                                }

                                if (convertTo == typeof(string))
                                {
                                    property.SetValue(item, Convert.ChangeType(tableDic[propName].ToString().Trim(), convertTo), null);
                                    continue;
                                }

                                property.SetValue(item, Convert.ChangeType(tableDic[propName], convertTo), null);
                            }

                            results.Add(item);
                        }
                    }
                }
            }

            return results;
        }

        protected void OpenConnection(SqlConnection connection)
        {
            connection.Open();
        }
    }
}
