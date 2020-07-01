IF OBJECT_ID('[DOI].[spPrintOutLongSQL]') IS NOT NULL
	DROP PROCEDURE [DOI].[spPrintOutLongSQL];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spPrintOutLongSQL]
        @SQLInput NVARCHAR(MAX),
        @VariableName NVARCHAR(128),
        @Debug BIT = 0
AS

/******************************************************************************************************
**    Name: spPrintOutLongSQL.sql
**          Script Type: Stored Procedure
**    Desc: Description
**
**    Auth: Sam Bendayan
**    Database:        HRMS_GLOBALDATA
**          Scrum Team Name: Sherpas
**          VersionOne Story #: ''
**    Resync Parent Node: ''
*******************************************************************************************************
**          USAGE:
        DECLARE @SQLInput NVARCHAR(MAX)

        --SET @SQLInput = ''
        SET @SQLInput = (select replicate('a', 4000))+ char(13)+ char(10)
        SET @SQLInput = @SQLInput +        (select replicate('b', 4000))+ char(13) + char(10)
        SET @SQLInput = @SQLInput +        (select replicate('C', 4000))+ char(13) + char(10)
        SET @SQLInput = @SQLInput +        (select replicate('D', 4000))+ char(13) + char(10)
        SET @SQLInput = @SQLInput +        (select replicate('E', 4000))+ char(13) + char(10)
        SET @SQLInput = @SQLInput +        (select replicate('F', 4000))+ char(13) + char(10)
        SET @SQLInput = @SQLInput +        (select replicate('G', 4000))+ char(13) + char(10)
        SET @SQLInput = @SQLInput +        (select replicate('H', 4000))+ char(13) + char(10)
        --SET @Sqlinput = @SQLInput +  ')'

DECLARE @v_PrintSQL VARCHAR(MAX)
SET @v_PrintSQL = 'PRINT ''' + REPLACE(REPLACE(@SQLInput, '''', ''''''), CHAR(13) + CHAR(10), ''' PRINT ''') + ''''
EXEC(@v_PrintSQL)


        EXEC dbo.spPrintOutLongSQL
                @SQLInput = @SQLInput,
                @VariableName = '@SQL',
                @Debug = 0


                 SELECT ASCII('     ')
                 SELECT ASCII('     ')
                THE PROBLEM WE'RE TRYING TO SOLVE HERE IS THAT A PRINT COMMAND CAN ONLY PRINT 8,000 CHARACTERS.
                SO WE HAVE TO HAVE MULTIPLE PRINT COMMANDS TO PRINT OUT A STRING LONGER THAN THAT.
                BUT, EVERY PRINT COMMAND STARTS ON A NEW LINE (ADDS A CRLF)...THIS IS THE PROBLEM.
                HOW CAN WE REMOVE THIS CRLF THAT THE PRINT COMMAND GENERATES?
*******************************************************************************************************/
SET NOCOUNT ON

BEGIN TRY
--get length of @SQLInput
--loop through it and print out each 4,000 character chunk.
    DECLARE @VariableLength NUMERIC(10,2),
            @PrintSQL                NVARCHAR(MAX),
            @ParmDefinition NVARCHAR(500),
            @Chunk          NVARCHAR(4000),
            @SubstringStart INT,
            @SubstringEnd   INT

    SET @VariableLength = LEN(@SQLInput)
    SET @ParmDefinition = N'@SQLInput NVARCHAR(MAX)'
    SET @PrintSQL = 'PRINT ''--' + @VariableName + ':  ''' + CHAR(10)
    SET @SubstringStart = 0
    SET @SubstringEnd = 4000
        SET @SQLInput = @SQLInput + CHAR(13) + CHAR(10)

        IF (@SubstringStart + @SubstringEnd) < @VariableLength
        BEGIN
                WHILE (@SubstringStart + @SubstringEnd) < @VariableLength
                BEGIN
                        --FIX "BROKEN LINE AT 4,000 CHARACTER POSITION" PROBLEM.
                        SELECT @SubstringStart = @SubstringStart + CASE @SubstringStart WHEN 0 THEN 1 ELSE @SubstringEnd END

                        SET @Chunk = SUBSTRING(@SQLInput, @SubstringStart, 4000)
                        IF RIGHT(@Chunk, 1) NOT IN ('', CHAR(10), CHAR(32), CHAR(9), CHAR(13))--IF THERE IS A LETTER IN THE 4,000th POSITION, ASSUME THAT IT'S A BROKEN LINE...
                        BEGIN
                                SET @SubstringEnd = LEN(@Chunk) - (CHARINDEX(CHAR(10), REVERSE(@Chunk))) --...AND STOP THE PRINT AT THE END OF THE PREVIOUS LINE.
                        END
                        ELSE
                        BEGIN
                                SET @SubstringEnd = LEN(@Chunk) --OTHERWISE, END POSITION IS OK.
                        END

                        IF @Debug = 1
                        BEGIN
                           PRINT 'PRINT SUBSTRING(@SQLInput, ' + CAST(@SubstringStart AS NVARCHAR(10)) + ', ' + CAST(@SubstringEnd AS NVARCHAR(10)) + ')'
                        END

                        SET @PrintSQL = @PrintSQL + 'PRINT SUBSTRING(@SQLInput, ' + CAST(@SubstringStart AS NVARCHAR(10)) + ', ' + CAST(@SubstringEnd AS NVARCHAR(10)) + ')'
                END
        END
        ELSE
        BEGIN
                SET @PrintSQL = @PrintSQL + 'PRINT @SQLInput'
        END

    IF @Debug = 1
    BEGIN
       PRINT @VariableLength
    END

    IF @Debug = 0
    BEGIN
        EXEC sp_executeSQL
            @PrintSQL,
            @ParmDefinition,
            @SQLInput = @SQLInput
    END
    ELSE
    BEGIN
            SET @PrintSQL = @PrintSQL + 'PRINT ''--' + CAST(@VariableLength AS VARCHAR(20)) + ' characters.'''
    END
END TRY

--ERROR HANDLING
BEGIN CATCH
        --Call central error handling proc.
        THROW;
END CATCH
GO
