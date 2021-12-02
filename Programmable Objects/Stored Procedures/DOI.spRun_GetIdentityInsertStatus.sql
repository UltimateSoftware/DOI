-- <Migration ID="e470dece-8f81-4013-9c0e-727e3091efef" />
GO
IF OBJECT_ID('[DOI].[spRun_GetIdentityInsertStatus]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRun_GetIdentityInsertStatus];

GO
-- ================================================================================
-- Check whether the table specified has its IDENTITY_INSERT set to ON or OFF.
-- If the table does not have an identity column, NO_IDENTITY is returned.
-- Tested on SQL 2008.
-- ================================================================================
CREATE PROCEDURE DOI.spRun_GetIdentityInsertStatus

      @DatabaseName SYSNAME
    , @SchemaName SYSNAME
    , @TableName SYSNAME
    , @IdentityInsert VARCHAR(20) OUTPUT

AS
/*
	declare @IdentityInsertOUT varchar(20) 
	exec DOI.spRun_GetIdentityInsertStatus
		@dbname = 'ultipro_calendar',
		@schemaname = 'dbo',
		@table = 'EmpHJob',
		@IdentityInsert = @IdentityInsertOUT OUTPUT

	SELECT @IdentityInsertOUT

    CHANGE this so it's not table specific and it turns OFF IDENTITY_INSERT if it's ON.

*/

BEGIN

    SET NOCOUNT ON

    DECLARE @OtherTable nvarchar(max)
    DECLARE @DbSchemaTable nvarchar(max)

    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    DECLARE @ErrorNumber INT;
    DECLARE @object_id INT;

    SET @DbSchemaTable = @dbname + '.' + @schemaname + '.' + @table

    SET @object_id = OBJECT_ID(@DbSchemaTable)
    IF @object_id IS NULL
    BEGIN
        RAISERROR('table %s doesn''t exist', 16, 1, @DbSchemaTable)
        RETURN
    END


    BEGIN TRY

        SET @object_id = OBJECT_ID(@DbSchemaTable)

        IF OBJECTPROPERTY(@object_id,'TableHasIdentity') = 0
        BEGIN
            SET @IdentityInsert = 'NO_IDENTITY'
        END
        ELSE
        BEGIN
            -- Attempt to set IDENTITY_INSERT on a temp table. This will fail if any other table
            -- has IDENTITY_INSERT set to ON, and we'll process that in the CATCH
            CREATE TABLE #GetIdentityInsert(ID INT IDENTITY)
            SET IDENTITY_INSERT #GetIdentityInsert ON
            SET IDENTITY_INSERT #GetIdentityInsert OFF
            DROP TABLE #GetIdentityInsert

            -- It didn't fail, so IDENTITY_INSERT on @table must set to OFF
            SET @IdentityInsert = 'OFF'
        END
    END TRY


    BEGIN CATCH

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE(),
            @ErrorNumber = ERROR_NUMBER();

        IF @ErrorNumber = 8107  --IDENTITY_INSERT is already set on a table
        BEGIN
            SET @OtherTable = SUBSTRING(@ErrorMessage, CHARINDEX(char(39), @ErrorMessage)+1, 2000)
            SET @OtherTable = SUBSTRING(@OtherTable, 1, CHARINDEX(char(39), @OtherTable)-1)

            IF @OtherTable = @DbSchemaTable 
            BEGIN
                -- If the table name is the same, then IDENTITY_INSERT on @table must be ON
                SET @IdentityInsert = 'ON'
            END
            ELSE
            BEGIN
                -- If the table name is different, then IDENTITY_INSERT on @table must be OFF
                SET @IdentityInsert =  'OFF'
            END
        END
        ELSE
        BEGIN
            RAISERROR (@ErrorNumber, @ErrorMessage, @ErrorSeverity, @ErrorState);
            --THROW     Use this if SQL 2012 or higher
        END

    END CATCH

    SELECT [IDENTITY_INSERT] = @IdentityInsert
END
GO