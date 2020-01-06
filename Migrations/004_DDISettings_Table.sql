-- <Migration ID="a554310f-9be4-40a7-8d38-9daace3f094c" TransactionHandling="Custom" />
IF OBJECT_ID('[DDI].[DDISettings]') IS NULL
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