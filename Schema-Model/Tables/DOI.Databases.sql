
GO

CREATE TABLE [DOI].[Databases]
(
[DatabaseName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OnlineOperations] BIT NOT NULL
	CONSTRAINT Def_Databases_OnlineOperations DEFAULT 0,
CONSTRAINT [PK_Databases] PRIMARY KEY NONCLUSTERED  ([DatabaseName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
