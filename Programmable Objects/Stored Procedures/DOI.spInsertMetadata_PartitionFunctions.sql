IF OBJECT_ID('[DOI].[spInsertMetadata_PartitionFunctions]') IS NOT NULL
	DROP PROCEDURE [DOI].[spInsertMetadata_PartitionFunctions];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE    PROCEDURE [DOI].[spInsertMetadata_PartitionFunctions](
           @DatabaseName sysname
           ,@PartitionFunctionName sysname
           ,@PartitionFunctionDataType sysname
           ,@BoundaryInterval varchar(10)
           ,@NumOfFutureIntervals tinyint
           ,@InitialDate date
           ,@UsesSlidingWindow bit
           ,@SlidingWindowSize smallint
           ,@IsDeprecated bit
           ,@PartitionSchemeName nvarchar(128)
           ,@NumOfCharsInSuffix tinyint
           ,@LastBoundaryDate date
           ,@NumOfTotalPartitionFunctionIntervals smallint
           ,@NumOfTotalPartitionSchemeIntervals smallint
           ,@MinValueOfDataType varchar(20))
AS

INSERT INTO DOI.PartitionFunctions ( DatabaseName ,PartitionFunctionName ,PartitionFunctionDataType ,BoundaryInterval ,NumOfFutureIntervals ,InitialDate ,UsesSlidingWindow ,SlidingWindowSize ,IsDeprecated ,PartitionSchemeName ,NumOfCharsInSuffix ,LastBoundaryDate ,NumOfTotalPartitionFunctionIntervals ,NumOfTotalPartitionSchemeIntervals ,MinValueOfDataType )
     VALUES
           (@DatabaseName
           ,@PartitionFunctionName
           ,@PartitionFunctionDataType
           ,@BoundaryInterval
           ,@NumOfFutureIntervals
           ,@InitialDate
           ,@UsesSlidingWindow
           ,@SlidingWindowSize
           ,@IsDeprecated
           ,@PartitionSchemeName
           ,@NumOfCharsInSuffix
           ,@LastBoundaryDate
           ,@NumOfTotalPartitionFunctionIntervals
           ,@NumOfTotalPartitionSchemeIntervals
           ,@MinValueOfDataType)

EXEC [DOI].[spRefreshMetadata_System_PartitionFunctionsAndSchemes]

GO
