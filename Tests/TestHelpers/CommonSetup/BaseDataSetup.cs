using System;
using System.Collections.Generic;
using DDI.Tests.Integration.IntegrationTests.Models;
using DDI.Tests.TestHelpers.CommonSetup.Logging;
using NUnit.Framework;
using DDI.Tests.TestHelpers.CommonSetup.Hosting.Runtime;
using DDI.Tests.TestHelpers.CommonSetup.Security.KeyServer;
using DDI.Tests.TestHelpers.DataAccess;

namespace DDI.Tests.TestHelpers.CommonSetup
{
    public abstract class BaseDataSetup<TSource> 
        where TSource : AggregateViewBase<TSource>
    {
        private List<TSource> aggregates; 

        protected BaseDataSetup()
        {
            this.Logger = new ApplicationLogger();
            var keyServer = new KeyServerAdapter(this.Logger, new HttpClientFactoryBase());
            var sqlReadOnlySqlDbCredentialsProvider = new ReadOnlySqlDbCredentialsProvider(this.Logger, keyServer);
            var sqlDbCredentialsProvider = new UteSqlDbCredentialsProvider(this.Logger, keyServer);

            this.DbConnectivityProvider = new DbConnectivityProvider(sqlDbCredentialsProvider, sqlReadOnlySqlDbCredentialsProvider, null, this.Logger, null, null);
            this.aggregates = new List<TSource>();
        }

        public abstract TSource DefaultAggregator { get; }

        public Guid DefaultUsgBankAccountId => Guid.Parse("0A6A22DB-AF31-FB0F-7734-00411040E7E3");

        public Guid DefaultCustomerBankAccountId => Guid.Parse("0A6A22DB-AF31-FB0F-7734-00411040E7E3");

        public Guid DefaultBai2BankTransactionMatchId => Guid.Parse("67FC1D70-6A1A-A2C4-F987-CFE14F3D87B3");

        public Guid DefaultBankTransactionId => Guid.Parse("12502CB6-2CE6-F192-8114-001496E04735");

        public static Guid DefaultPayId => Guid.Parse("645F4749-760D-39B7-73B3-0008BC479CC8");

        public static Guid DefaultGarnishmentId => Guid.Parse("B97925E0-F895-4AE3-859B-84E842A27D26");

        public ApplicationLogger Logger { get; set; }

        public DbConnectivityProvider DbConnectivityProvider { get; set; }

        public SetupRepository<TSource> Repository { get; set; }

        public List<TSource> Aggregates
        {
            get
            {
                if (this.aggregates.Count == 0)
                {
                    this.aggregates.Add(this.DefaultAggregator);
                }

                return this.aggregates;
            }

            set
            {
                this.aggregates = value;
            }
        }

        public virtual void AddAggregate(TSource aggregate)
        {
            this.Aggregates.Add(aggregate);
            this.Create();
        }

        public virtual void Create()
        {
            foreach (var aggregate in this.Aggregates)
            {
                var cleanUpResult = this.Repository.CleanUp(aggregate.Id);
                Assert.IsTrue(cleanUpResult, $"Failed to delete {this.GetType().Name} in setup.");

                this.AddCommonProperties(aggregate);

                if (!this.Repository.Create(aggregate).Result)
                {
                    Assert.Fail($"Fail to create {this.GetType().Name} record with id '{aggregate.Id}'.");
                }
            }
        }

        public virtual void CleanUp()
        {
            foreach (var aggregate in this.Aggregates)
            {
                var cleanUpResult = this.Repository.CleanUp(aggregate.Id);
                Assert.IsTrue(cleanUpResult, $"Failed to delete {this.GetType().Name} in setup.");
            }
        }

    public virtual void SetDefaultData()
        {
            this.Aggregates.Clear();
            this.Create();
        }

        protected void AddCommonProperties(AggregateViewBase<TSource> aggregate)
        {
            aggregate.AppliedEventSequenceNumber = 1;
            aggregate.AppliedEventDateTime = DateTime.Now;
            aggregate.Version = 1;
            aggregate.CreatedUtcDt = DateTime.Now;
            aggregate.UpdatedUtcDt = DateTime.Now;
        }
    }
}
