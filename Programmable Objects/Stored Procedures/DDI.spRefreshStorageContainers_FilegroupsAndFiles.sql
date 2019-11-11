IF OBJECT_ID('[DDI].[spRefreshStorageContainers_FilegroupsAndFiles]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRefreshStorageContainers_FilegroupsAndFiles];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DDI].[spRefreshStorageContainers_FilegroupsAndFiles]
    @DatabaseName SYSNAME,
	@Debug BIT = 0

AS

/*
	EXEC DDI.spRefreshStorageContainers_FilegroupsAndFiles
        @DatabaseName = 'PaymentReporting',
		@Debug = 1
*/

DECLARE @CreateFileGroupsSQL NVARCHAR(MAX) = '' + CHAR(13) + CHAR(10),
		@CreateFilesSQL NVARCHAR(MAX) = '' + CHAR(13) + CHAR(10) 


SELECT @CreateFileGroupsSQL = (	SELECT DISTINCT AddFileGroupSQL + CHAR(13) + CHAR(10)
								FROM DDI.vwPartitionFunctionPartitions
								WHERE DatabaseName = @DatabaseName
								FOR XML PATH(''), TYPE).value(N'.[1]', N'nvarchar(max)')

IF @Debug = 1
BEGIN
	EXEC DDI.spPrintOutLongSQL 
		@SQLInput = @CreateFileGroupsSQL ,
		@VariableName = N'@CreateFileGroupsSQL'
END
ELSE
BEGIN
	EXEC (@CreateFileGroupsSQL)
END


SELECT @CreateFilesSQL = (	SELECT DISTINCT AddFileSQL + CHAR(13) + CHAR(10)
							FROM DDI.vwPartitionFunctionPartitions
							WHERE DatabaseName = @DatabaseName
							FOR XML PATH(''), TYPE).value(N'.[1]', N'nvarchar(max)')
FROM DDI.vwPartitionFunctionPartitions


IF @Debug = 1
BEGIN
	EXEC DDI.spPrintOutLongSQL 
		@SQLInput = @CreateFilesSQL ,
		@VariableName = N'@CreateFilesSQL'
END
ELSE
BEGIN
	EXEC (@CreateFilesSQL)
END

GO
