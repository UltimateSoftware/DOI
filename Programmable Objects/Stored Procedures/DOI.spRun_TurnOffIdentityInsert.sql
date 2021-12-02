
IF OBJECT_ID('[DOI].[spRun_TurnOffIdentityInsert]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRun_TurnOffIdentityInsert];

GO

CREATE PROCEDURE [DOI].[spRun_TurnOffIdentityInsert]

      @DatabaseName SYSNAME
    , @SchemaName SYSNAME
    , @TableName SYSNAME

AS
/*
	declare @IdentityInsertOUT varchar(20) 
	exec DOI.spRun_TurnOffIdentityInsert
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
    DECLARE @IdentityInsert VARCHAR(200)


    SET @DbSchemaTable = @DatabaseName + '.' + @SchemaName + '.' + @TableName

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
            SET @IdentityInsert = 'SET IDENTITY_INSERT was OFF in this session for all tables.'
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
            SET @OtherTable = SUBSTRING(@ErrorMessage, CHARINDEX(CHAR(39), @ErrorMessage)+1, 2000)
            SET @OtherTable = SUBSTRING(@OtherTable, 1, CHARINDEX(CHAR(39), @OtherTable)-1)

			EXEC ('SET IDENTITY_INSERT ' + @OtherTable + ' OFF') --this does not work.  it executes it in another dynamic session, not the session that called the sp.

            IF @OtherTable = @DbSchemaTable 
            BEGIN
                -- If the table name is the same, then IDENTITY_INSERT on @table must be ON
                SET @IdentityInsert =  'SET IDENTITY_INSERT was turned OFF for table ' + @DbSchemaTable + '.'
            END
            ELSE
            BEGIN
                -- If the table name is different, then IDENTITY_INSERT on @table must be OFF
                SET @IdentityInsert =  'SET IDENTITY_INSERT was turned OFF for table ' + @OtherTable + '.'
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