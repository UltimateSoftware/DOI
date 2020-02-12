using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DDI.Tests.Integration.TestHelpers.CommonSetup.Runtime
{
    public interface IVersionTracker
    {
        /// <summary>
        /// Gets or sets aggregate's current version.
        /// </summary>
        int Version { get; set; }

        /// <summary>
        /// Method updates aggregate state management indicating that state has been persisted to the repository. 
        /// This method MUST NOT BE USED from any code OTHER THAN REPOSITORIES. Using this method outside of repositories may lead to data corruption.
        /// </summary>
        void MarkAsPersisted();

        /// <summary>
        /// Method returns boolean indicator whether it has any changes since last time it was retrieved from the repository or been saved to the repository.
        /// </summary>
        /// <returns>Returns boolean value.</returns>
        bool HasChanges();
    }
}
