-- <Migration ID="a554310f-9be4-40a7-8d38-9daace3f094c" TransactionHandling="Custom" />
IF OBJECT_ID('[DOI].[DOISettings]') IS NULL
CREATE TABLE [DOI].[DOISettings]
(
[DatabaseName] [sys].[sysname] NOT NULL,
[SettingName] [sys].[sysname] NOT NULL,
[SettingValue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_DOISettings] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SettingName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO