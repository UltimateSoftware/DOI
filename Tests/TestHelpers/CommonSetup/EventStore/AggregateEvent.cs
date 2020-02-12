using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DDI.Tests.Integration.TestHelpers.CommonSetup.Hosting;

namespace DDI.Tests.Integration.TestHelpers.CommonSetup.EventStore
{
    /// <summary>
    /// The delegate used to raise an aggregate event.
    /// </summary>
    /// <param name="sender">The sender of event.</param>
    /// <param name="e">The event arguments.</param>
    public delegate void AggregateEvent(object sender, AggregateEventArgs e);

    /// <summary>
    /// The aggregate event arguments to use with AggregateEvent.
    /// </summary>
    [Serializable]
    public class AggregateEventArgs : EventArgs
    {
        /// <summary>
        /// Gets or sets the event data.
        /// </summary>
        public DomainEventData EventData { get; set; }

        /// <summary>
        /// Constructor that accepts event data.
        /// </summary>
        /// <param name="eventData">The event data.</param>
        public AggregateEventArgs(DomainEventData eventData)
        {
            Convention.ThrowIfNull(eventData, "eventData");

            this.EventData = eventData;
        }

        /// <summary>
        /// Default constructor.
        /// </summary>
        public AggregateEventArgs()
        {
        }
    }
}
