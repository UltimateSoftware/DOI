using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using SmartHub.Hosting.DataAccess;

namespace DDI.Tests.TestHelpers.DataAccess.SqlDataStore
{
    public static class QueryableExtensions
    {
        public static IQueryable<T> OrderBy<T>(this IQueryable<T> source, IEnumerable<SortParameter> sortParameters)
        {
            var expression = source.Expression;
            var count = 0;

            foreach (var sortParameter in sortParameters)
            {
                MemberExpression selector = null;
                Expression currentRoot = null;
                var parameter = Expression.Parameter(typeof(T), "p");
                if (sortParameter.SortBy.Contains("."))
                {
                    var fieldParts = sortParameter.SortBy.Split('.');
                    currentRoot = parameter;
                    foreach (var field in fieldParts)
                    {
                        selector = Expression.PropertyOrField(currentRoot, field);
                        currentRoot = selector;
                    }
                }
                else
                {
                    selector = Expression.PropertyOrField(parameter, sortParameter.SortBy);
                }

                var method = sortParameter.SortDirection == SortDirection.Descending ?
                    (count == 0 ? "OrderByDescending" : "ThenByDescending") :
                    (count == 0 ? "OrderBy" : "ThenBy");
                expression = Expression.Call(
                    typeof(Queryable),
                    method,
                    new Type[] { source.ElementType, selector.Type },
                    expression,
                    Expression.Quote(Expression.Lambda(selector, parameter)));
                count++;
            }

            return count > 0 ? source.Provider.CreateQuery<T>(expression) : source;
        }
    }
}
