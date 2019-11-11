
USE master;

DECLARE @dbname nvarchar(128)
SET @dbname = N'$(///Database///)'

--If database exists, leave alone, otherwise create
IF (NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE ('[' + name + ']' = @dbname OR name = @dbname)))
	BEGIN
		CREATE DATABASE $(///Database///) 
	END

