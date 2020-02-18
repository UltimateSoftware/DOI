using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Runtime.Serialization;
using Newtonsoft.Json;

namespace DDI.Tests.TestHelpers.CommonSetup.Logging
{
    /// <summary>
    /// Class represents the Sensu alert object.
    /// </summary>
    [DataContract]
    [Serializable]
    public class SensuAlert
    {
        /// <summary>
        /// Gets or sets the alert custom command. 
        /// </summary>
        [DataMember(Name = "command")]
        public string CommandName { get; set; }

        /// <summary>
        /// Gets or sets the list of handlers for this alert. 
        /// </summary>
        [DataMember(Name = "handlers")]
        public List<string> Handlers { get; set; }

        /// <summary>
        /// Method enables mailer handler for this alert. 
        /// </summary>
        /// <param name="emailAddress">The email address to use.</param>
        public void EnableMailerHandler(string emailAddress)
        {
            if (string.IsNullOrWhiteSpace(emailAddress))
            {
                throw new ArgumentException($"The {nameof(emailAddress)} should not be null, or empty string.");
            }

            this.MailTo = emailAddress;
            if (!this.Handlers.Contains("mailer"))
            {
                this.Handlers.Add("mailer");
            }
        }

        /// <summary>
        /// Gets or sets a boolean indicator whether the alert is standalone - must be true. 
        /// </summary>
        [DataMember(Name = "standalone")]
        public bool Standalone { get; set; }

        /// <summary>
        /// Gets or sets the alert monitoring interval. 
        /// </summary>
        [DataMember(Name = "interval")]
        public int MonitoringInterval { get; set; }

        /// <summary>
        /// Gets or sets the number of occurrences. 
        /// </summary>
        [DataMember(Name = "occurrences")]
        public int Occurrences { get; set; }

        /// <summary>
        /// Gets or sets the alert escalation level - use "default". 
        /// </summary>
        [DataMember(Name = "escalation")]
        public string EscalationLevel { get; set; }

        /// <summary>
        /// Gets or sets the custom name of the event (check type). 
        /// </summary>
        [DataMember(Name = "name")]
        public string Name { get; set; }

        /// <summary>
        /// Gets or sets the date and time when alert is issued. 
        /// </summary>
        [JsonConverter(typeof(EpochConverter))]
        [DataMember(Name = "issued")]
        public DateTime IssuedUtcDateTime { get; set; }

        /// <summary>
        /// Gets or sets the date and time measurement is executed. 
        /// </summary>
        [JsonConverter(typeof(EpochConverter))]
        [DataMember(Name = "executed")]
        public DateTime ExecutedUtcDateTime { get; set; }

        /// <summary>
        /// Gets or sets the alert output that is used for email subject. 
        /// </summary>
        [DataMember(Name = "output")]
        public string Output { get; set; }

        /// <summary>
        /// Gets or sets the alert status: 0 = okay, 1 = warning, 2 = critical. 
        /// </summary>
        [DataMember(Name = "status")]
        public SensuAlertStatus AlertStatus { get; set; }

        /// <summary>
        /// Gets or sets the alert measurement duration - timeout on a check script (not used). 
        /// </summary>
        [DataMember(Name = "duration")]
        public int CheckScriptDuration { get; set; }

        /// <summary>
        /// Gets or sets the email address to send alert. 
        /// </summary>
        [DataMember(Name = "mail_to")]
        public string MailTo { get; set; }

        /// <summary>
        /// Gets or sets the alert refresh threshold (use 0 for immediate email notification). 
        /// This is the number of alerts Sensu will wait to receive until it sends an email.
        /// </summary>
        [DataMember(Name = "refresh")]
        public int Refresh { get; set; }

        public SensuAlert()
        {
            this.CommandName = "Tax Management Forced Alert";
            this.Handlers = new List<string>();
            this.Handlers.Add("default");
            this.Occurrences = 1;
            this.EscalationLevel = "default";
            this.MonitoringInterval = 1;
            this.IssuedUtcDateTime = DateTime.UtcNow;
            this.ExecutedUtcDateTime = DateTime.UtcNow;
            this.AlertStatus = SensuAlertStatus.Critical;
            this.Name = string.Empty;
            this.Output = string.Empty;
            this.MailTo = string.Empty;
            this.Standalone = true;
        }
    }

    /// <summary>
    /// Represents the Sensu alert status (level).
    /// </summary>
    public enum SensuAlertStatus
    {
        Ok = 0,
        Warning = 1,
        Critical = 2
    }

    /// <summary>
    /// Represents the Sensu alert type known to support team.
    /// </summary>
    public enum SensuAlertType
    {
        /// <summary>
        /// An alert used for testing.
        /// </summary>
        [Description("txm_alert_test")]
        [SensuRefresh(1)]
        TestAlert = 0,

        /// <summary>
        /// Indicates an issue with security infrastructure, such as availability of Identity service, or key data.
        /// </summary>
        [Description("txm_alert_security_infrastructure")]
        SecurityInfrastructure = 1,

        /// <summary>
        /// Indicates an issue with outbound files
        /// </summary>
        [Description("txm_outbound_files")]
        OutboundFiles = 5,

        /// <summary>
        /// Indicates an issue with messaging infrastructure, such as connectivity issues, including stability, to the RabbitMQ.
        /// </summary>
        [Description("txm_alert_messaging_infrastructure")]
        MessagingInfrastructure = 7,

        /// <summary>
        /// Indicates an issue with data store infrastructure, such as connectivity issues, including stability, to MongoDB or SQL.
        /// </summary>
        [Description("txm_alert_data_store_infrastructure")]
        DataStoreInfrastructure = 8,

        /// <summary>
        /// Indicates that not all pays are received while running non payroll process.
        /// </summary>
        [Description("txm_non_payroll_tax_processing")]
        NonPayrollTaxProcessing = 10,

        /// <summary>
        /// Indicates that not all pays are received while running payroll process.
        /// </summary>
        [Description("txm_payroll_processing_tax")]
        PayrollProcessingTax = 20,

        /// <summary>
        /// Indicates that quarterly process failed.
        /// </summary>
        [Description("txm_quarterly_processing_tax")]
        QuarterlyProcessingTax = 30,

        /// <summary>
        /// Indicates that we failed to load the tax code mappings.
        /// </summary>
        [Description("txm_alert_tax_code_mappings")]
        TaxCodeMapping = 40,

        /// <summary>
        /// Indicates that there was an error when generating a report through the reporting gateway.
        /// </summary>
        [Description("txm_reporting_gateway_request")]
        ReportingGatewayRequest = 50,

        /// <summary>
        /// Indicates that yearly process failed.
        /// </summary>
        [Description("txm_yearly_processing_tax")]
        YearlyProcessingTax = 60,

        /// <summary>
        /// Indicates that export state zero eft process failed.
        /// </summary>
        [Description("txm_export_state_zero_eft_processing")]
        [SensuAlertScope("banking-sensu")]
        ExportZeroEftError = 70,

        /// <summary>
        /// Indicates a collection request occurs for an import payroll, and it fails to create
        /// </summary>
        [Description("txm_collection_creation_on_import_error")]
        [SensuRefresh(1)]
        [SensuAlertScope("banking-sensu")]
        CollectionCreationOnImportErrorRefreshThreshold1 = 80,

        /// <summary>
        /// Indicates a collection request occurs for an import payroll, and it fails to create
        /// </summary>
        [Description("txm_collection_creation_on_import_error")]
        [SensuRefresh(1)]
        [SensuAlertScope("banking-sensu")]
        CollectionCreationOnImportErrorRefreshThreshold5 = 90,

        /// <summary>
        /// Indicates a collection request occurs for an input payroll, and it fails to create
        /// </summary>
        [Description("txm_collection_creation_on_input_error")]
        [SensuRefresh(1)]
        [SensuAlertScope("banking-sensu")]
        CollectionCreationOnInputErrorRefreshThreshold1 = 100,

        /// <summary>
        /// Indicates a collection request occurs for an input payroll, and it fails to create
        /// </summary>
        [Description("txm_collection_creation_on_input_error")]
        [SensuRefresh(1)]
        [SensuAlertScope("banking-sensu")]
        CollectionCreationOnInputErrorRefreshThreshold5 = 110,

        /// <summary>
        /// Indicates a refund fails to create when payment is voided
        /// </summary>
        [Description("txm_refund_creation_when_void_error")]
        [SensuRefresh(1)]
        [SensuAlertScope("banking-sensu")]
        RefundCreationWhenVoidErrorRefreshThreshold1 = 120,

        /// <summary>
        /// Indicates a refund fails to create when payment is voided
        /// </summary>
        [Description("txm_refund_creation_when_void_error")]
        [SensuRefresh(1)]
        [SensuAlertScope("banking-sensu")]
        RefundCreationWhenVoidErrorRefreshThreshold5 = 130,

        /// <summary>
        /// Indicates a refund fails to create when credit is applied
        /// </summary>
        [Description("txm_refund_creation_when_credit_applied_error")]
        [SensuRefresh(1)]
        [SensuAlertScope("banking-sensu")]
        RefundCreationWhenCreditAppliedErrorRefreshThreshold1 = 140,

        /// <summary>
        /// Indicates a refund fails to create when credit is applied
        /// </summary>
        [Description("txm_refund_creation_when_credit_applied_error")]
        [SensuRefresh(1)]
        [SensuAlertScope("banking-sensu")]
        RefundCreationWhenCreditAppliedErrorRefreshThreshold5 = 150,

        /// <summary>
        /// Indicates an export check process failed to generate a check
        /// </summary>
        [Description("txm_check_failed_to_generate")]
        [SensuRefresh(5)]
        [SensuAlertScope("banking-sensu")]
        CheckFailedToGenerate = 160,

        /// <summary>
        /// Indicates a process failed to generate printable document when exporting a check
        /// </summary>
        [Description("txm_check_pdf_failed_to_generate")]
        [SensuRefresh(1)]
        [SensuAlertScope("banking-sensu")]
        CheckPDFFailedToGenerateRefreshThreshold1 = 170,

        /// <summary>
        /// Indicates a process failed to generate printable document when exporting a check
        /// </summary>
        [Description("txm_check_pdf_failed_to_generate")]
        [SensuRefresh(1)]
        [SensuAlertScope("banking-sensu")]
        CheckPDFFailedToGenerateRefreshThreshold5 = 180,

        /// <summary>
        /// Indicates an EFT failed to export
        /// </summary>
        [Description("txm_eft_failed_to_export")]
        [SensuAlertScope("banking-sensu")]
        EftExportError = 190,

        /// <summary>
        /// Indicates a Zero EFT failed to create
        /// </summary>
        [Description("txm_zero_eft_failed_to_create")]
        [SensuAlertScope("banking-sensu")]
        CreateZeroEftError = 200,

        /// <summary>
        /// Indicates a credit application fail to be ensured for a given payroll assembled event
        /// </summary>
        [Description("txm_credit_application_on_payroll_assembled_error")]
        [SensuRefresh(1)]
        [SensuAlertScope("banking-sensu")]
        CreditApplicationErrorOnPayrollAssembledRefreshThreshold5 = 210,

        /// <summary>
        /// Indicates a credit application fail to be ensured for a cash Mgmt liability updated event
        /// </summary>
        [Description("txm_credit_application_on_cash_liability_updated_error")]
        [SensuRefresh(1)]
        [SensuAlertScope("banking-sensu")]
        CreditApplicationErrorOnCashLiabilityUpdatedRefreshThreshold5 = 220,

        /// <summary>
        /// Indicates a credit application fail to be ensured for a payment status updated to Valid event
        /// </summary>
        [Description("txm_credit_application_on_payment_updated_to_valid_error")]
        [SensuRefresh(1)]
        [SensuAlertScope("banking-sensu")]
        CreditApplicationErrorOnPaymentUpdatedToValidRefreshThreshold5 = 225,

        /// <summary>
        /// Indicates a credit request failed and got stuck in progress
        /// </summary>
        [Description("txm_credit_request_stuck")]
        [SensuRefresh(1)]
        [SensuAlertScope("banking-sensu")]
        CreditRequestErrorStuckInProgressUpdatedRefreshThreshold5 = 230,

        /// <summary>
        /// Indicates a credit request failed and got stuck in progress
        /// </summary>
        [Description("txm_credit_request_stuck")]
        [SensuRefresh(1)]
        [SensuAlertScope("banking-sensu")]
        CreditRequestErrorStuckInProgressUpdatedRefreshThreshold1 = 240,

        /// <summary>
        /// Indicates a credit application fail when applying credits
        /// </summary>
        [Description("txm_credit_application_on_apply_credit")]
        [SensuRefresh(1)]
        [SensuAlertScope("banking-sensu")]
        CreditApplicationErrorOnApplyCredit5 = 250,

        /// <summary>
        /// Indicates a credit application fail when releasing credits
        /// </summary>
        [Description("txm_credit_application_on_release_credit")]
        [SensuRefresh(1)]
        [SensuAlertScope("banking-sensu")]
        CreditApplicationErrorOnReleaseCredit5 = 260,

        /// <summary>
        /// Indicates a credit application fail when applying credits
        /// </summary>
        [Description("txm_credit_application_on_apply_credit")]
        [SensuAlertScope("banking-sensu")]
        CreditApplicationErrorOnApplyCredit1 = 270,

        /// <summary>
        /// Indicates a failure related to Object Storage
        /// </summary>
        [Description("txm_object_store_error")]
        ObjectStoreError = 280,

        /// <summary>
        /// Indicates a credit application refund request failed
        /// </summary>
        [Description("txm_credit_application_refund_request_error")]
        [SensuRefresh(1)]
        [SensuAlertScope("banking-sensu")]
        CreditApplicationErrorOnRefundRequestThreshold5 = 290,

        /// <summary>
        /// Indicates failure during processing of refund created event
        /// </summary>
        [Description("txm_liability_refund_created_event_processing_error")]
        [SensuRefresh(1)]
        [SensuAlertScope("banking-sensu")]
        LiabilityRefundCreatedEventProcessingErrorThreshold5 = 300,

        /// <summary>
        /// Indicates a credit application fail when re queuing credits
        /// </summary>
        [Description("txm_credit_application_on_requeue_credit")]
        [SensuRefresh(1)]
        [SensuAlertScope("banking-sensu")]
        CreditApplicationErrorOnReQueueCredit5 = 310,

        /// <summary>
        /// Indicates failure during credit application for payment unsent
        /// </summary>
        [Description("txm_credit_application_on_payment_unsent_error")]
        [SensuRefresh(1)]
        [SensuAlertScope("banking-sensu")]
        CreditApplicationErrorOnPaymentUnsentRefreshThreshold5 = 320,

        /// <summary>
        /// Indicates update tenant usg bank account id failed
        /// </summary>
        [Description("txm_tenant_usg_bank_account")]
        [SensuRefresh(1)]
        [SensuAlertScope("banking-sensu")]
        TenantUpdateUsgBankAccount5 = 330,

        /// <summary>
        /// Indicates update tenant usg bank account id failed
        /// </summary>
        [Description("txm_tenant_usg_bank_account")]
        [SensuAlertScope("banking-sensu")]
        TenantUpdateUsgBankAccount1 = 340,
    }

    [AttributeUsage(AttributeTargets.Field, Inherited = false, AllowMultiple = false)]
    internal sealed class SensuRefreshAttribute : Attribute
    {
        public SensuRefreshAttribute(int refreshThreshold)
        {
            this.RefreshThreshold = refreshThreshold;
        }

        public int RefreshThreshold { get; private set; }
    }

    [AttributeUsage(AttributeTargets.Field, Inherited = false, AllowMultiple = false)]
    internal sealed class SensuAlertScopeAttribute : Attribute
    {
        public SensuAlertScopeAttribute(string sensuAlertScope)
        {
            this.SensuAlertScope = sensuAlertScope;
        }

        public string SensuAlertScope { get; private set; }
    }
}
