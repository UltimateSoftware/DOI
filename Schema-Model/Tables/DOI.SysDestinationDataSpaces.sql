CREATE TABLE [DOI].[SysDestinationDataSpaces]
(
[database_id] [int] NOT NULL,
[partition_scheme_id] [int] NOT NULL,
[destination_id] [int] NOT NULL,
[data_space_id] [int] NOT NULL,
CONSTRAINT [PK_SysDestinationDataSpaces] PRIMARY KEY NONCLUSTERED  ([database_id], [partition_scheme_id], [destination_id])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
