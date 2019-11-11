
USE master;

DECLARE @dbname nvarchar(128)
SET @dbname = N'$(///Database///)'

--If database exists, re-create
IF (EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE ('[' + name + ']' = @dbname OR name = @dbname)))
	BEGIN
		ALTER DATABASE $(///Database///) SET SINGLE_USER WITH ROLLBACK IMMEDIATE
		DROP DATABASE $(///Database///) 
	END

CREATE DATABASE $(///Database///) 
