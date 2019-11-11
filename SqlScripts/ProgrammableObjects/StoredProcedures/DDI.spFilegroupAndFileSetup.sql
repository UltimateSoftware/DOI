--FILEGROUPS AND FILES
SET NOCOUNT ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET NUMERIC_ROUNDABORT OFF
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE DDI.spFilegroupAndFileSetup
    @DatabaseName SYSNAME,
	@Debug BIT = 0

AS

/*
	EXEC DDI.spFilegroupAndFileSetup
        @DatabaseName = 'PaymentReporting',
		@Debug = 1
*/

DECLARE @CreateFileGroupsSQL NVARCHAR(MAX) = '' + CHAR(13) + CHAR(10),
		@CreateFilesSQL NVARCHAR(MAX) = '' + CHAR(13) + CHAR(10) 


SELECT @CreateFileGroupsSQL = (	SELECT DISTINCT AddFileGroupSQL + CHAR(13) + CHAR(10)
								FROM DDI.vwPartitionFunctionPartitions
								FOR XML PATH(''), TYPE).value(N'.[1]', N'nvarchar(max)')

IF @Debug = 1
BEGIN
	EXEC dbo.spPrintOutLongSQL 
		@SQLInput = @CreateFileGroupsSQL ,
		@VariableName = N'@CreateFileGroupsSQL'
END
ELSE
BEGIN
	EXEC (@CreateFileGroupsSQL)
END


SELECT @CreateFilesSQL = (	SELECT DISTINCT AddFileSQL + CHAR(13) + CHAR(10)
							FROM DDI.vwPartitionFunctionPartitions
							FOR XML PATH(''), TYPE).value(N'.[1]', N'nvarchar(max)')
FROM DDI.vwPartitionFunctionPartitions


IF @Debug = 1
BEGIN
	EXEC dbo.spPrintOutLongSQL 
		@SQLInput = @CreateFilesSQL ,
		@VariableName = N'@CreateFilesSQL'
END
ELSE
BEGIN
	EXEC (@CreateFilesSQL)
END

GO

EXEC DDI.spFilegroupAndFileSetup
    @DatabaseName = 'PaymentReporting'
GO
