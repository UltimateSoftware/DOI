IF OBJECT_ID('[DDI].[spInsertMetadata_PartitionFunctions]') IS NOT NULL
	DROP PROCEDURE [DDI].[spInsertMetadata_PartitionFunctions];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE    PROCEDURE [DDI].[spInsertMetadata_PartitionFunctions](
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

INSERT INTO DDI.PartitionFunctions ( DatabaseName ,PartitionFunctionName ,PartitionFunctionDataType ,BoundaryInterval ,NumOfFutureIntervals ,InitialDate ,UsesSlidingWindow ,SlidingWindowSize ,IsDeprecated ,PartitionSchemeName ,NumOfCharsInSuffix ,LastBoundaryDate ,NumOfTotalPartitionFunctionIntervals ,NumOfTotalPartitionSchemeIntervals ,MinValueOfDataType )
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

EXEC [DDI].[spRefreshMetadata_System_PartitionFunctionsAndSchemes]

GO
