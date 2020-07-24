
GO

IF OBJECT_ID('[DOI].[sp_ExecuteSQLByBatch]') IS NOT NULL
	DROP PROCEDURE [DOI].[sp_ExecuteSQLByBatch];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[sp_ExecuteSQLByBatch]
        @SQL NVARCHAR(MAX),
        @Debug BIT = 0
AS

SET NOCOUNT ON

BEGIN TRY
        --TAKE SQL STRING AND EXECUTE ONE BATCH AT A TIME (THE CODE IN BETWEEN 'GO' STATEMENTS.
        DECLARE @SQLBatch NVARCHAR(MAX),
                @SQLLength INT,
                @CurrentPosition INT,
                @GOString NVARCHAR(20),
                @GOPosition INT

        SET @GOString = '%[' + CHAR(10) + CHAR(13) + SPACE(1) + CHAR(9) + ']GO[' + CHAR(10) + CHAR(13) + SPACE(1) + CHAR(9) + ']%'
        SET @SQL = RTRIM(@SQL)--LEN FUNCTION DOESN'T COUNT TRAILING BLANKS, SO WE REMOVE THEM.
        SET @SQL = @SQL + CHAR(13) + CHAR(10) --IF THE SQL DOESN'T HAVE A CRLF AT THE END THIS CODE BREAKS.
        SET @SQLLength = LEN(@SQL)
        SET @CurrentPosition = 0

        WHILE (@CurrentPosition <= @SQLLength)
        BEGIN
                SET @GOPosition =   CASE
                                        WHEN PATINDEX(@GOString, @SQL) = 0 --IF NO MORE 'GO' STATEMENTS ARE FOUND...
                                        THEN @SQLLength + 1--GO TO THE END OF THE STRING.
                                        ELSE PATINDEX(@GOString, @SQL)
                                    END

                --SELECT THE SQL BATCH BETWEEN THE 'GO' STATEMENTS...
                SELECT @SQLBatch = SUBSTRING(@SQL, @CurrentPosition, @GOPosition - @CurrentPosition)

                --COMMENT OUT THE 'GO' SO THE PATINDEX DOESN'T FIND IT AGAIN.
                IF @GOPosition <> @SQLLength + 1 --IF IT'S AN ACTUAL 'GO' STRING...
                BEGIN
                    SELECT @SQL = STUFF(@SQL, @GOPosition, 2, '--')
                                END

                --SET CURRENT POSITION TO SKIP 'GO' STMT AND GET READY FOR NEXT BATCH.
                SET @CurrentPosition = @CurrentPosition + (@GOPosition - @CurrentPosition) + 4

                IF @Debug = 1
                BEGIN
                        --PRINT '@SQL ' + @SQL
                        PRINT '/****************************        BATCH        ***********************************/'
                        PRINT '--@SQLLength ' + CAST(@SQLLength AS NVARCHAR(20))
                        PRINT '--@GOPosition ' +  CAST(@GOPosition AS NVARCHAR(20))
                        IF (LEN(@SQLBatch) <= 4000)
                        BEGIN
                                                        PRINT @SQLBatch
                                                END
                                                ELSE
                                                BEGIN
                            EXEC DOI.spPrintOutLongSQL
                                        @SQLInput = @SQLBatch,
                                        @VariableName = '@SQLBatch',
                                        @Debug = 0
                                                END
                        PRINT '--Length of SQL Batch ' + CAST(LEN(@SQLBatch) AS NVARCHAR(20))
                        PRINT '--@CurrentPosition ' +  CAST(@CurrentPosition AS NVARCHAR(20))
                END
                ELSE
                BEGIN
                        EXEC dbo.sp_ExecuteSQL @SQLBatch
                END
        END
END TRY

--ERROR HANDLING
BEGIN CATCH
        --Call central error handling proc.
        THROW;
END CATCH

GO
