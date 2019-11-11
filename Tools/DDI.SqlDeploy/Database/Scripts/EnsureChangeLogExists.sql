
USE $(///Database///);



--Create changelog table if not exist
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[changelog]') AND type in (N'U'))
	BEGIN
		PRINT 'Table does not exist, creating table'
		CREATE TABLE [dbo].[changelog](
			[is_setup] [bit] NOT NULL,
			[change_number] [int] NOT NULL,
			[complete_dt] [datetime2] NOT NULL,
			[applied_by] [varchar](100) NOT NULL,
			[description] [varchar](500) NOT NULL,
			[ID] INT IDENTITY PRIMARY KEY NOT NULL
		)
	 
END

-- switch complete_dt to datetime2 from datetime
IF EXISTS(SELECT 1 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE 
TABLE_SCHEMA = 'dbo' AND
	 TABLE_NAME = 'changelog' AND 
	 COLUMN_NAME = 'complete_dt'
	AND DATA_TYPE = 'datetime')
BEGIN
	PRINT 'Converting dbo.changelog.complete_dt from datetime => datetime2 and Add New Id Primary Key'

	
	BEGIN TRANSACTION
		
	ALTER TABLE dbo.changelog DROP CONSTRAINT Pkchangelog

	ALTER TABLE dbo.changelog 
		ADD ID INT IDENTITY

	ALTER TABLE dbo.changelog
		ADD CONSTRAINT PK_changelog
		PRIMARY KEY(ID)

	ALTER TABLE  dbo.changelog 
		ALTER COLUMN complete_dt datetime2(7) NOT NULL
	

	
	INSERT INTO changelog (is_setup, change_number, complete_dt, applied_by, description)
		VALUES (1, 0, SYSDATETIME(), SYSTEM_USER, 
		'Converting dbo.changelog.complete_dt from datetime => datetime2 and Add New Id Primary Key')


	COMMIT
END


--if log entry of this change does not exist
--if change log
IF 0 = (select count(change_number) from dbo.changelog where change_number = 0)
BEGIN
	--Insert log entry of this change
	EXEC('INSERT INTO changelog (is_setup, change_number, complete_dt, applied_by, description) VALUES (1, 0, SYSDATETIME(), SYSTEM_USER, ''Create Database'')')
END
