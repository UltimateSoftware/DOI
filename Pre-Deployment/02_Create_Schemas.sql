USE [$(DatabaseName2)]
GO

PRINT N'Creating schemas'
GO
IF NOT EXISTS (SELECT 'True' FROM [$(DatabaseName2)].sys.schemas WHERE name = 'DOI')
BEGIN
	EXEC('CREATE SCHEMA [DOI] AUTHORIZATION [dbo]')
END
GO

IF NOT EXISTS (SELECT 'True' FROM [$(DatabaseName2)].sys.schemas WHERE name = 'DOI')
BEGIN
	EXEC('CREATE SCHEMA [Utility] AUTHORIZATION [dbo]')
END
GO