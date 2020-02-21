CREATE TABLE [DDI].[DDISettings]
(
[DatabaseName] [sys].[sysname] NOT NULL,
[SettingName] [sys].[sysname] NOT NULL,
[SettingValue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_DDISettings] PRIMARY KEY NONCLUSTERED  ([DatabaseName], [SettingName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
