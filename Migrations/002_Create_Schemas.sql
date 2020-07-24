-- <Migration ID="e0d00486-b7e9-4a30-bae0-8281658e0d1a" />
IF NOT EXISTS (SELECT 'True' FROM [$(DatabaseName)].sys.schemas WHERE name = 'DOI')
BEGIN
	EXEC('CREATE SCHEMA [DOI] AUTHORIZATION [dbo]')
END
GO

IF NOT EXISTS (SELECT 'True' FROM [$(DatabaseName)].sys.schemas WHERE name = 'Utility')
BEGIN
	EXEC('CREATE SCHEMA [Utility] AUTHORIZATION [dbo]')
END
GO