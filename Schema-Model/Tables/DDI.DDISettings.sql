CREATE TABLE [DDI].[DDISettings]
(
[SettingName] [sys].[sysname] NOT NULL,
[SettingValue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CONSTRAINT [PK_DDISettings] PRIMARY KEY NONCLUSTERED  ([SettingName])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
