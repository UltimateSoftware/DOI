namespace DDI.Tests.TestHelpers.CommonSetup.Models
{
    /// <summary>
    /// Enum for applied event sequence type
    /// </summary>
    public enum AppliedEventSequenceType
    {
        /// <summary>
        /// The sequence number is less or equal to sequence of event that already was proccessed 
        /// so ignore the event.
        /// </summary>
        Ignore = 1,

        /// <summary>
        /// The sequence number is larger than +1 of the sequence of event that already was proccessed, 
        /// store the event in staging to proccessed later.
        /// </summary>
        StoreToStaging = 2,

        /// <summary>
        /// The sequence number is +1 of the sequence of event that laready was proccessed,
        /// proccess the event and check if there are any events in staging that need to be proccessed.
        /// </summary>
        ReadyToProccess = 3
    }
}
