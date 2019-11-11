/*************************************	MASTER DB OBJECTS *********************************************/
USE master
GO

IF OBJECT_ID('dbo.JobsToGovern') IS NULL
BEGIN
	CREATE TABLE dbo.JobsToGovern(
		JobID UNIQUEIDENTIFIER NOT NULL,
        JobName SYSNAME,
		MatchString NVARCHAR(256) PRIMARY KEY CLUSTERED,
		DateInserted DATETIME2 NOT NULL DEFAULT SYSDATETIME())

	PRINT 'Created table dbo.JobsToGovern.'
END

GO