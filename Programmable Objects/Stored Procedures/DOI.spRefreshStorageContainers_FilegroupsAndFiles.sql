
GO

IF OBJECT_ID('[DOI].[spRefreshStorageContainers_FilegroupsAndFiles]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshStorageContainers_FilegroupsAndFiles];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DOI].[spRefreshStorageContainers_FilegroupsAndFiles]
    @DatabaseName SYSNAME,
	@Debug BIT = 0

AS

/*
	EXEC DOI.spRefreshStorageContainers_FilegroupsAndFiles
        @DatabaseName = 'PaymentReporting',
		@Debug = 1
*/

DECLARE @CreateFileGroupsSQL NVARCHAR(MAX) = '' + CHAR(13) + CHAR(10),
		@CreateFilesSQL NVARCHAR(MAX) = '' + CHAR(13) + CHAR(10) 


SELECT @CreateFileGroupsSQL = (	SELECT DISTINCT AddFileGroupSQL + CHAR(13) + CHAR(10)
								FROM DOI.vwPartitionFunctionPartitions
								WHERE DatabaseName = @DatabaseName
								FOR XML PATH(''), TYPE).value(N'.[1]', N'nvarchar(max)')

IF @Debug = 1
BEGIN
	EXEC DOI.spPrintOutLongSQL 
		@SQLInput = @CreateFileGroupsSQL ,
		@VariableName = N'@CreateFileGroupsSQL'
END
ELSE
BEGIN
	EXEC (@CreateFileGroupsSQL)
END


SELECT @CreateFilesSQL = (	SELECT DISTINCT AddFileSQL + CHAR(13) + CHAR(10)
							FROM DOI.vwPartitionFunctionPartitions
							WHERE DatabaseName = @DatabaseName
							FOR XML PATH(''), TYPE).value(N'.[1]', N'nvarchar(max)')
FROM DOI.vwPartitionFunctionPartitions


IF @Debug = 1
BEGIN
	EXEC DOI.spPrintOutLongSQL 
		@SQLInput = @CreateFilesSQL ,
		@VariableName = N'@CreateFilesSQL'
END
ELSE
BEGIN
	EXEC (@CreateFilesSQL)
END

GO
