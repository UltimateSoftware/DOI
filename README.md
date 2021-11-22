# DOI
DevOps Indexing

Utility for managing SQL Server Indexing operations in a DevOps environment, where we may not have permissions to the production server and it's a 24x7 operation with little or
no tolerance for maintenance windows.



ARCHITECTURAL PRINCIPLES

1. We “draw the line” at deploying DB changes and notifying the users that the changes are done.
    1. SQL Agent Job needs to send an alert when it’s done with an operation that is a precursor to some other dev change.
    2. Don’t get any further into the dependencies between any indexing and code changes; let the teams figure them out.


2. We don’t drop any objects; we only notify that they are not in metadata and the user has to drop it manually
    1. That way we can’t be accused of dropping any objects unintentionally.
3. Prohibit users from making changes on their own?  
    1. I think we just suggest it and have them deal with the consequences.  The worst that can happen is that their next Queue operation gets aborted because of ‘Not In Metadata’ errors.
