-- <Migration ID="18ff79cb-7bbd-43b4-866b-f185b3f7e1db" />

IF OBJECT_ID('[DOI].[spQueue]') IS NOT NULL
	DROP PROCEDURE [DOI].[spQueue];

GO

CREATE   PROCEDURE [DOI].[spQueue]
	@OnlineOperations BIT,
    @DatabaseName SYSNAME = NULL,
    @SchemaName SYSNAME = NULL,
    @TableName SYSNAME = NULL,
	@IncludeMaintenance BIT = 0,
	@BatchIdOUT UNIQUEIDENTIFIER OUTPUT 

AS

/*
    declare @BatchId uniqueidentifier

	EXEC DOI.spQueue 
		@DatabaseName = 'DOIUnitTests',
        @BatchIdOUT = @BatchId
*/

BEGIN TRY
	SET @BatchIdOUT = NEWID()

    EXEC DOI.spRefreshMetadata_Run_All
		@DatabaseName = @DatabaseName,
		@IncludeMaintenance = @IncludeMaintenance

	DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10)

	DECLARE @CurrentDatabaseName					NVARCHAR(128),
			@InsertQueueSQL							VARCHAR(MAX) =''

 
	DECLARE Databases_Queued_Cur CURSOR LOCAL FAST_FORWARD FOR
	SELECT DatabaseName
	FROM DOI.Databases
	WHERE DatabaseName = CASE WHEN @DatabaseName IS NULL THEN DatabaseName ELSE @DatabaseName END

	OPEN Databases_Queued_Cur

	FETCH NEXT FROM Databases_Queued_Cur INTO @CurrentDatabaseName

	WHILE @@FETCH_STATUS <> -1
	BEGIN
		IF @@FETCH_STATUS <> -2
		BEGIN
			SELECT @InsertQueueSQL = InsertQueueSQL
			FROM DOI.fnIndexesSQLToRun(@CurrentDatabaseName, @SchemaName, @TableName, @OnlineOperations)

			EXEC (@InsertQueueSQL)
		END --@@fetch_status <> -2, Databases cursor
		
		FETCH NEXT FROM Databases_Queued_Cur INTO @CurrentDatabaseName
	END --@@fetch_status <> -1, Databases cursor
	CLOSE Databases_Queued_Cur
	DEALLOCATE Databases_Queued_Cur
END TRY

BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK TRAN 

	--CLOSE CURSORS IF OPEN
	IF (SELECT CURSOR_STATUS('local','Databases_Queued_Cur')) >= -1
	BEGIN
		IF (SELECT CURSOR_STATUS('local','Databases_Queued_Cur')) > -1
		BEGIN
			CLOSE Databases_Queued_Cur
		END

		DEALLOCATE Databases_Queued_Cur
	END;

	THROW;
END CATCH


--CLOSE CURSORS IF OPEN
IF (SELECT CURSOR_STATUS('local','Databases_Queued_Cur')) >= -1
BEGIN
	IF (SELECT CURSOR_STATUS('local','Databases_Queued_Cur')) > -1
	BEGIN
		CLOSE Databases_Queued_Cur
	END

	DEALLOCATE Databases_Queued_Cur
END

RETURN

GO