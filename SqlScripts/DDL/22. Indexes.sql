USE DDI
GO

--EXEC Utility.spForeignKeysDrop 
--    @ForMetadataTablesOnly = 1,
--    @ReferencedSchemaName = 'Utility',
--    @ReferencedTableName = 'IndexesRowStore'

--GO

DROP TABLE IF EXISTS DDI.IndexesRowStore
GO

IF OBJECT_ID('DDI.IndexesRowStore') IS NULL
BEGIN
	CREATE TABLE DDI.IndexesRowStore (
        DatabaseName				NVARCHAR(128) NOT NULL,
		SchemaName					NVARCHAR(128) NOT NULL,
		TableName					NVARCHAR(128) NOT NULL,
		IndexName					NVARCHAR(128) NOT NULL,
		IsUnique					BIT NOT NULL,
		IsPrimaryKey				BIT NOT NULL,
		IsUniqueConstraint			BIT NOT NULL
			CONSTRAINT Chk_IndexesRowStore_IsUniqueConstraint
				CHECK (IsUniqueConstraint = 0)
			CONSTRAINT Def_IndexesRowStore_IsUniqueConstraint
				DEFAULT(0),
		IsClustered					BIT NOT NULL,
		KeyColumnList				NVARCHAR(MAX) NOT NULL,
		IncludedColumnList			NVARCHAR(MAX) NULL,
		IsFiltered					BIT NOT NULL,
		FilterPredicate				VARCHAR(MAX) NULL
/*			CONSTRAINT Chk_IndexesRowStore_FilterPredicate
				CHECK ((FilterPredicate IS NOT NULL AND FilterPredicate LIKE '|(%|[%|]%|)' ESCAPE '|')--must use parentheses around expression and square brackets around columnnames.
						OR (FilterPredicate IS NULL))*/, 
		[Fillfactor]				TINYINT NOT NULL
			CONSTRAINT Chk_Indexes_FillFactor
				CHECK ([Fillfactor] BETWEEN 0 AND 100)
			CONSTRAINT Def_Indexes_FillFactor
				DEFAULT (90),
		OptionPadIndex				BIT NOT NULL
			CONSTRAINT Def_IndexesRowStore_OptionPadIndex
				DEFAULT(1),
		OptionStatisticsNoRecompute BIT NOT NULL
			CONSTRAINT Def_IndexesRowStore_OptionStatisticsNoRecompute
				DEFAULT(0),
		OptionStatisticsIncremental BIT NOT NULL
			CONSTRAINT Def_IndexesRowStore_OptionStatisticsIncremental
				DEFAULT(0),
		OptionIgnoreDupKey			BIT NOT NULL
			CONSTRAINT Def_IndexesRowStore_OptionIgnoreDupKey
				DEFAULT(0),
		OptionResumable				BIT NOT NULL
			CONSTRAINT Def_IndexesRowStore_OptionResumable
				DEFAULT(0),
		OptionMaxDuration			SMALLINT NOT NULL
			CONSTRAINT Def_IndexesRowStore_OptionMaxDuration
				DEFAULT(0),
		OptionAllowRowLocks			BIT NOT NULL
			CONSTRAINT Def_IndexesRowStore_OptionAllowRowLocks
				DEFAULT(1),
		OptionAllowPageLocks		BIT NOT NULL
			CONSTRAINT Def_IndexesRowStore_OptionAllowPageLocks
				DEFAULT(1),
		OptionDataCompression		NVARCHAR(60) NOT NULL --solves collation conflict with sys.partitions column.
			CONSTRAINT Chk_IndexesRowStore_OptionDataCompression
				CHECK (OptionDataCompression IN ('NONE', 'ROW', 'PAGE'))
			CONSTRAINT Def_IndexesRowStore_OptionDataCompression
				DEFAULT('PAGE'),
		NewStorage					NVARCHAR(128) NOT NULL,
		PartitionColumn				NVARCHAR(128) NULL

		CONSTRAINT PK_IndexesRowStore
			PRIMARY KEY NONCLUSTERED (DatabaseName, SchemaName, TableName, IndexName),
		CONSTRAINT Chk_IndexesRowStore_Filter
			CHECK ((IsFiltered = 1 AND FilterPredicate IS NOT NULL AND IsPrimaryKey = 0 AND IsUniqueConstraint = 0 AND IsClustered = 0 AND OptionStatisticsIncremental = 0)
						OR (IsFiltered = 0 AND FilterPredicate IS NULL)),
		CONSTRAINT Chk_IndexesRowStore_PrimaryKeyIsUnique
			CHECK ((IsPrimaryKey = 1 AND IsUnique = 1)
						OR (IsPrimaryKey = 0)),
		CONSTRAINT Chk_IndexesRowStore_UniqueConstraintIsUnique
			CHECK ((IsUniqueConstraint = 1 AND IsUnique = 1)
						OR (IsUniqueConstraint = 0)),
		CONSTRAINT Chk_IndexesRowStore_PKvsUQ
			CHECK ((IsPrimaryKey = 1 AND IsUniqueConstraint = 0)
						OR (IsPrimaryKey = 0 AND IsUniqueConstraint = 1)
						OR (IsPrimaryKey = 0 AND IsUniqueConstraint = 0)),
		CONSTRAINT Chk_IndexesRowStore_IncludedColumnsNotAllowed
			CHECK ((IncludedColumnList IS NOT NULL AND (IsClustered = 0 AND IsPrimaryKey = 0 AND IsUniqueConstraint = 0))
						OR (IncludedColumnList IS NULL)),
        CONSTRAINT FK_IndexesRowStore_Tables
            FOREIGN KEY (DatabaseName, SchemaName, TableName)
                REFERENCES DDI.Tables(DatabaseName, SchemaName, TableName)

)

    WITH (MEMORY_OPTIMIZED = ON)

	PRINT 'Created table DDI.IndexesRowStore.'
END
GO

--EXEC Utility.spForeignKeysDrop 
--    @ForMetadataTablesOnly = 1,
--    @ReferencedSchemaName = 'Utility',
--	@ReferencedTableName	= 'IndexesColumnStore'
--GO

DROP TABLE IF EXISTS DDI.IndexesColumnStore
GO

IF OBJECT_ID('DDI.IndexesColumnStore') IS NULL
BEGIN
	CREATE TABLE DDI.IndexesColumnStore (
        DatabaseName			NVARCHAR(128) NOT NULL,
		SchemaName				NVARCHAR(128) NOT NULL,
		TableName				NVARCHAR(128) NOT NULL,
		IndexName				NVARCHAR(128) NOT NULL,
		IsClustered				BIT NOT NULL,
		ColumnList				NVARCHAR(MAX) NULL,
		IsFiltered				BIT NOT NULL,
		FilterPredicate			VARCHAR(MAX) NULL,
		OptionDataCompression	VARCHAR(30) NOT NULL --solves collation conflict with sys.partitions column.
			CONSTRAINT Chk_IndexesColumnStore_OptionDataCompression
				CHECK (OptionDataCompression IN ('COLUMNSTORE', 'COLUMNSTORE_ARCHIVE'))
			CONSTRAINT Def_IndexesColumnStore_OptionDataCompression
				DEFAULT ('COLUMNSTORE'),
		OptionCompressionDelay	INT NOT NULL,
		NewStorage				NVARCHAR(128) NULL,
		PartitionColumn			NVARCHAR(128) NULL--,

		CONSTRAINT PK_IndexesColumnStore
			PRIMARY KEY NONCLUSTERED (DatabaseName, SchemaName, TableName, IndexName),
		CONSTRAINT Chk_IndexesColumnStore_ColumnList
			CHECK ((IsClustered = 1 AND ColumnList IS NULL)
						OR (IsClustered = 0 AND ColumnList IS NOT NULL)),
		CONSTRAINT Chk_IndexesColumnStore_Filter
			CHECK ((IsFiltered = 1 AND FilterPredicate IS NOT NULL AND IsClustered = 0)
						OR (IsFiltered = 0 AND FilterPredicate IS NULL)),
        CONSTRAINT FK_IndexesColumnStore_Tables
            FOREIGN KEY (DatabaseName, SchemaName, TableName)
                REFERENCES DDI.Tables(DatabaseName, SchemaName, TableName))

    WITH (MEMORY_OPTIMIZED = ON)

	PRINT 'Created table DDI.IndexesColumnStore.'
END
GO


--CREATE TRIGGER DDI.trIndexesRowStore_PreDeployValidations
--ON DDI.IndexesRowStore
--WITH NATIVE_COMPILATION, SCHEMABINDING
--AFTER INSERT, UPDATE, DELETE 
--AS

--BEGIN
--	IF EXISTS(	SELECT 'True'
--				FROM DDI.IndexesRowStore IRS 
--				WHERE IRS.IncludedColumnList LIKE '%' + IRS.PartitionColumn + '%')
--	BEGIN
--		RAISERROR('The partitioning column of an index cannot also be an INCLUDED column.  Remove the INCLUDED column.', 16, 1)
--	END

--	DECLARE @IndexList												VARCHAR(MAX) = '',
--			@TablesWithMoreThan1PKList								VARCHAR(MAX) = '',
--			@TablesWithMoreThan1ClusteredIndexList					VARCHAR(MAX) = '',
--			@ErrorText												VARCHAR(MAX) = '',
--			@NonPartitionedIndexesWithIncrementalStatistics			VARCHAR(MAX) = '',
--			@AlignedIndexesWithoutIncrementalStatistics				VARCHAR(MAX) = '',
--			@FilteredIndexesWithIncrementalStatistics				VARCHAR(MAX) = '',
--			@IntendToPartitionWithPartitionColumnNotInKeyColumnList VARCHAR(MAX) = '',
--			@PartitionEnabledWithBadSettings						VARCHAR(MAX) = '',
--			@NoUpdatedUtcDtColumnInTable							VARCHAR(MAX) = '',
--			@TableAndIndexStorageMismatch							VARCHAR(MAX) = '',
--			@IndexAndPartitionCompressionMismatch					VARCHAR(MAX) = '',
--			@ColumnListsWithSpacesAfterCommas						VARCHAR(MAX) = '',
--			@InvalidPartitionColumnNamesList						VARCHAR(MAX) = ''

--	SELECT @IndexList += x.IndexName + ','
--	FROM (	SELECT	irs.SchemaName, 
--					irs.TableName, 
--					irs.IndexName, 
--					LTRIM(RTRIM(REPLACE(REPLACE(kc.item, 'asc', ''), 'desc', ''))) AS KeyColumn, 
--					ic.Item AS IncludedColumn
--			FROM Inserted irs
--				CROSS APPLY dbo.fn_ListToTable(irs.KeyColumnList) kc
--				CROSS APPLY dbo.fn_ListToTable(irs.IncludedColumnList) ic
--			WHERE irs.IncludedColumnList IS NOT NULL) x
--	WHERE x.KeyColumn = x.IncludedColumn

--	IF @IndexList <> ''
--	BEGIN
--		SET @ErrorText = 'The Index(es) ' + STUFF(@IndexList, LEN(@IndexList), 1,'') + ' have an INCLUDED column that is also a key column.  Remove the INCLUDED column(s).'

--		RAISERROR(@ErrorText, 16, 1)
--	END

--	--aligned indexes on partitioned tables must have statistics incremental = on
--	SELECT @AlignedIndexesWithoutIncrementalStatistics += IRS.IndexName + ','
--	FROM inserted IRS
--		INNER JOIN sys.schemas s ON s.name = IRS.SchemaName
--		INNER JOIN sys.tables t ON IRS.TableName = t.name
--			AND s.schema_id = t.schema_id
--		INNER JOIN sys.indexes i ON i.object_id = t.object_id
--			AND i.Name = IRS.IndexName
--		INNER JOIN (SELECT name AS ExistingStorage, data_space_id, type_desc AS ExistingStorageType
--					FROM sys.data_spaces) ExistingDS 
--			ON ExistingDS.data_space_id = i.data_space_id
--	WHERE IRS.IsUnique = 1
--		AND ISNULL(ExistingDS.ExistingStorage,'NONE') <> 'NONE' --are the indexes partitioned?
--		AND IRS.KeyColumnList LIKE '%' + IRS.PartitionColumn + '%' --are the indexes aligned?
--		AND IRS.OptionStatisticsIncremental = 0

--	IF @AlignedIndexesWithoutIncrementalStatistics <> ''
--	BEGIN
--		SET @ErrorText = 'The Unique Index(es) ' + STUFF(@AlignedIndexesWithoutIncrementalStatistics, LEN(@AlignedIndexesWithoutIncrementalStatistics), 1,'') + ' are partition-aligned but do not have incremental statistics.  Set OptionStatisticsIncremental to 1 for these indexes.'
		
--		RAISERROR(@ErrorText, 10, 1)
--	END

--	--non-aligned indexes on partitioned tables cannot have statistics incremental = on
--	DECLARE @NonAlignedIndexesWithIncrementalStatistics VARCHAR(MAX) = ''

--	SELECT @AlignedIndexesWithoutIncrementalStatistics += IRS.IndexName + ','
--	FROM Inserted IRS
--		INNER JOIN sys.schemas s ON s.name = IRS.SchemaName
--		INNER JOIN sys.tables t ON IRS.TableName = t.name
--			AND s.schema_id = t.schema_id
--		INNER JOIN sys.indexes i ON i.object_id = t.object_id
--			AND i.Name = IRS.IndexName
--		INNER JOIN (SELECT name AS ExistingStorage, data_space_id, type_desc AS ExistingStorageType
--					FROM sys.data_spaces) ExistingDS 
--			ON ExistingDS.data_space_id = i.data_space_id
--	WHERE IRS.IsUnique = 1
--		AND ISNULL(ExistingDS.ExistingStorage,'NONE') <> 'NONE' --are the indexes partitioned?
--		AND IRS.KeyColumnList LIKE '%' + IRS.PartitionColumn + '%' --are the indexes aligned?
--		AND IRS.OptionStatisticsIncremental = 0

--	IF @NonAlignedIndexesWithIncrementalStatistics <> ''
--	BEGIN
--		SET @ErrorText = 'The Unique Index(es) ' + STUFF(@NonAlignedIndexesWithIncrementalStatistics, LEN(@NonAlignedIndexesWithIncrementalStatistics), 1,'') + ' are NOT partition-aligned but have incremental statistics.  Set OptionStatisticsIncremental to 0 for these indexes.'
		
--		RAISERROR(@ErrorText, 10, 1)
--	END

--	--tables with more than 1 PK
--	SELECT @TablesWithMoreThan1PKList += SchemaName + '.' + TableName + ','
--	FROM Inserted
--	WHERE IsPrimaryKey = 1 
--	GROUP BY SchemaName, TableName 
--	HAVING COUNT(*) > 1

--	IF LTRIM(RTRIM(@TablesWithMoreThan1PKList)) <> ''
--	BEGIN
--		SET @ErrorText = 'The Following Table(s) have more than 1 Primary Key defined.  Delete or convert one of the Primary Keys to a Unique index:' + STUFF(@TablesWithMoreThan1PKList, LEN(@TablesWithMoreThan1PKList), 1,'')
		
--		RAISERROR(@ErrorText, 16, 1)
--	END

--	--tables with more than 1 Clustered Index
--	SELECT @TablesWithMoreThan1ClusteredIndexList += SchemaName + '.' + TableName + ','
--	FROM (	SELECT i.SchemaName, i.TableName 
--			FROM Inserted i
--				INNER JOIN DDI.IndexesRowStore IRS ON IRS.SchemaName = i.SchemaName
--					AND IRS.TableName = i.TableName
--					AND IRS.IndexName = i.IndexName
--			WHERE IRS.IsClustered = 1) AllIdx
--	GROUP BY SchemaName, TableName 
--	HAVING COUNT(*) > 1

--	IF LTRIM(RTRIM(@TablesWithMoreThan1ClusteredIndexList)) <> ''
--	BEGIN
--		SET @ErrorText = 'The Following Table(s) have more than 1 Clustered Index defined.  Delete or convert one of the Clustered Indexes to IsClustered = 0:' + STUFF(@TablesWithMoreThan1ClusteredIndexList, LEN(@TablesWithMoreThan1ClusteredIndexList), 1,'')
		
--		RAISERROR(@ErrorText, 16, 1)
--	END


--	--@PartitionEnabledWithBadSettings
--	SELECT @PartitionEnabledWithBadSettings += AllIdx.SchemaName + '.' + AllIdx.TableName + '.' + AllIdx.IndexName + ','
--	--SELECT AllIdx.IndexName, T.IntendToPartition, AllIdx.PartitionColumn, AllIdx.NewPartitionFunction
--	FROM DDI.Tables T
--		INNER JOIN (SELECT	SchemaName AS SchemaName, 
--							TableName  AS TableName, 
--							IndexName, 
--							PartitionColumn, 
--							NewStorage
--					FROM Inserted) AllIdx
--			ON AllIdx.SchemaName = T.SchemaName
--				AND AllIdx.TableName = T.TableName
--		LEFT JOIN sys.partition_schemes ps ON AllIdx.NewStorage = ps.name
--	WHERE T.ReadyToQueue = 1
--        AND (T.IntendToPartition = 1
--			AND (AllIdx.PartitionColumn = 'NONE'
--					OR ps.name IS NULL))
--		OR (T.IntendToPartition = 0
--			AND (AllIdx.PartitionColumn <> 'NONE'
--					OR ps.name IS NOT NULL))

--	IF LTRIM(RTRIM(@PartitionEnabledWithBadSettings)) <> ''
--	BEGIN
--		SET @ErrorText = 'The Following Table(s) have a bad PartitionColumn/PartitionScheme combination:  ' + STUFF(@PartitionEnabledWithBadSettings, LEN(@PartitionEnabledWithBadSettings), 1,'')
		
--		RAISERROR(@ErrorText, 16, 1)
--	END   


--	--NEED TO VALIDATE THAT THE PARTITION SCHEME NAMES ACTUALLY EXIST IN DB.

--	SELECT @IntendToPartitionWithPartitionColumnNotInKeyColumnList += I.SchemaName + '.' + I.TableName + '.' + I.IndexName + ','
--	FROM DDI.Tables T
--		INNER JOIN Inserted I ON I.SchemaName = T.SchemaName
--			AND I.TableName = T.TableName
--	WHERE T.IntendToPartition = 1
--		--AND I.IsUnique = 1
--		AND I.KeyColumnList NOT LIKE '%' + I.PartitionColumn + '%'--partitioning column is NOT in the indexkey column.

--	IF LTRIM(RTRIM(@IntendToPartitionWithPartitionColumnNotInKeyColumnList)) <> ''
--	BEGIN
--		SET @ErrorText = 'The Following Indexe(s) are intended to be partitioned but do not have the Partition Column in their Key Column List:  ' + STUFF(@IntendToPartitionWithPartitionColumnNotInKeyColumnList, LEN(@IntendToPartitionWithPartitionColumnNotInKeyColumnList), 1,'')
		
--		RAISERROR(@ErrorText, 16, 1)
--	END   

--	IF LTRIM(RTRIM(@NonPartitionedIndexesWithIncrementalStatistics)) <> ''
--	BEGIN
--		SET @ErrorText = 'The Following Index(es) are NOT partitioned and have Incremental Statistics:  ' + STUFF(@NonPartitionedIndexesWithIncrementalStatistics, LEN(@NonPartitionedIndexesWithIncrementalStatistics), 1,'')
		
--		RAISERROR(@ErrorText, 10, 1)
--	END  

--	SELECT @TableAndIndexStorageMismatch += I.SchemaName + '.' + I.TableName + '.' + I.IndexName + ','
--	FROM DDI.Tables T
--		INNER JOIN Inserted I ON I.SchemaName = T.SchemaName 
--			AND I.TableName = T.TableName 
--	WHERE I.NewStorage <> t.NewStorage

--	IF LTRIM(RTRIM(@TableAndIndexStorageMismatch)) <> ''
--	BEGIN
--		SET @ErrorText = 'The Following Indexe(s) do not match the storage of their parent table:  ' + STUFF(@TableAndIndexStorageMismatch, LEN(@TableAndIndexStorageMismatch), 1,'')
		
--		RAISERROR(@ErrorText, 10, 1)
--	END   

--	SELECT @IndexAndPartitionCompressionMismatch += I.SchemaName + '.' + I.TableName + '.' + I.IndexName + '__' + CAST(IP.PartitionNumber AS VARCHAR(5)) + ','
--	FROM Inserted I 
--		INNER JOIN DDI.IndexRowStorePartitions IP ON I.SchemaName = IP.SchemaName 
--			AND I.TableName = IP.TableName 
--			AND I.IndexName = IP.IndexName 
--	WHERE I.OptionDataCompression <> IP.OptionDataCompression

--	IF LTRIM(RTRIM(@IndexAndPartitionCompressionMismatch)) <> ''
--	BEGIN
--		SET @ErrorText = 'The Following Index Partition(s) do not match the compression setting of their parent index:  ' + STUFF(@IndexAndPartitionCompressionMismatch, LEN(@IndexAndPartitionCompressionMismatch), 1,'')
		
--		RAISERROR(@ErrorText, 10, 1)
--	END  

--	SELECT @ColumnListsWithSpacesAfterCommas += IndexName + ','
--	FROM Inserted I
--	WHERE I.KeyColumnList LIKE '%, %' 
--		OR I.IncludedColumnList LIKE '%, %'

--	IF LTRIM(RTRIM(@ColumnListsWithSpacesAfterCommas)) <> ''
--	BEGIN
--		SET @ErrorText = 'The Following Index(es) have spaces after commas in their Column Lists.  Remove the spaces:  ' + STUFF(@ColumnListsWithSpacesAfterCommas, LEN(@ColumnListsWithSpacesAfterCommas), 1,'')
		
--		RAISERROR(@ErrorText, 10, 1)
--	END  

--	SELECT @NonPartitionedIndexesWithIncrementalStatistics += IRS.IndexName + ','
--	FROM Inserted IRS
--		INNER JOIN DDI.Tables T ON T.SchemaName = IRS.SchemaName
--			AND T.TableName = IRS.TableName
--	WHERE T.IntendToPartition = 0
--		AND IRS.OptionStatisticsIncremental = 1
--END

--GO

--add trigger for ICS.
--CREATE TRIGGER trIndexesColumnStore_PreDeployValidations
--ON DDI.IndexesColumnStore
--AFTER INSERT, UPDATE, DELETE 

--AS

--BEGIN
--	DECLARE @TablesWithMoreThan1ClusteredIndexList					VARCHAR(MAX) = '',
--			@ErrorText												VARCHAR(MAX) = '',
--			@IntendToPartitionWithPartitionColumnNotInKeyColumnList VARCHAR(MAX) = '',
--			@PartitionEnabledWithBadSettings						VARCHAR(MAX) = '',
--			@NoUpdatedUtcDtColumnInTable							VARCHAR(MAX) = '',
--			@TableAndIndexStorageMismatch							VARCHAR(MAX) = '',
--			@IndexAndPartitionCompressionMismatch					VARCHAR(MAX) = '',
--			@ColumnListsWithSpacesAfterCommas						VARCHAR(MAX) = '',
--			@InvalidPartitionColumnNamesList						VARCHAR(MAX) = ''

--	--tables with more than 1 Clustered Index
--	SELECT @TablesWithMoreThan1ClusteredIndexList += SchemaName + '.' + TableName + ','
--	FROM (	SELECT i.SchemaName, i.TableName 
--			FROM Inserted i
--				INNER JOIN DDI.IndexesColumnStore ICS ON ICS.SchemaName = i.SchemaName
--					AND ICS.TableName = i.TableName
--					AND ICS.IndexName = i.IndexName
--			WHERE ICS.IsClustered = 1 ) AllIdx
--	GROUP BY SchemaName, TableName 
--	HAVING COUNT(*) > 1

--	IF LTRIM(RTRIM(@TablesWithMoreThan1ClusteredIndexList)) <> ''
--	BEGIN
--		SET @ErrorText = 'The Following Table(s) have more than 1 Clustered Index defined.  Delete or convert one of the Clustered Indexes to IsClustered = 0:' + STUFF(@TablesWithMoreThan1ClusteredIndexList, LEN(@TablesWithMoreThan1ClusteredIndexList), 1,'')
		
--		RAISERROR(@ErrorText, 16, 1)
--	END


--	--@PartitionEnabledWithBadSettings
--	SELECT @PartitionEnabledWithBadSettings += AllIdx.SchemaName + '.' + AllIdx.TableName + '.' + AllIdx.IndexName + ','
--	--SELECT AllIdx.IndexName, T.IntendToPartition, AllIdx.PartitionColumn, AllIdx.NewPartitionFunction
--	FROM DDI.Tables T
--		INNER JOIN (SELECT	SchemaName, 
--							TableName, 
--							IndexName, 
--							PartitionColumn, 
--							NewStorage
--					FROM Inserted) AllIdx
--			ON AllIdx.SchemaName = T.SchemaName
--				AND AllIdx.TableName = T.TableName
--		LEFT JOIN sys.partition_schemes ps ON AllIdx.NewStorage = ps.name
--	WHERE T.ReadyToQueue = 1
--        AND (T.IntendToPartition = 1
--			AND (AllIdx.PartitionColumn = 'NONE'
--					OR ps.name IS NULL))
--		OR (T.IntendToPartition = 0
--			AND (AllIdx.PartitionColumn <> 'NONE'
--					OR ps.name IS NOT NULL))

--	IF LTRIM(RTRIM(@PartitionEnabledWithBadSettings)) <> ''
--	BEGIN
--		SET @ErrorText = 'The Following Table(s) have a bad PartitionColumn/PartitionScheme combination:  ' + STUFF(@PartitionEnabledWithBadSettings, LEN(@PartitionEnabledWithBadSettings), 1,'')
		
--		RAISERROR(@ErrorText, 16, 1)
--	END   


--	--NEED TO VALIDATE THAT THE PARTITION SCHEME NAMES ACTUALLY EXIST IN DB.

--	SELECT @IntendToPartitionWithPartitionColumnNotInKeyColumnList += I.SchemaName + '.' + I.TableName + '.' + I.IndexName + ','
--	FROM DDI.Tables T
--		INNER JOIN Inserted I ON I.SchemaName = T.SchemaName
--			AND I.TableName = T.TableName
--	WHERE T.IntendToPartition = 1
--		--AND I.IsUnique = 1
--		AND I.ColumnList NOT LIKE '%' + I.PartitionColumn + '%'--partitioning column is NOT in the indexkey column.

--	IF LTRIM(RTRIM(@IntendToPartitionWithPartitionColumnNotInKeyColumnList)) <> ''
--	BEGIN
--		SET @ErrorText = 'The Following Indexe(s) are intended to be partitioned but do not have the Partition Column in their Key Column List:  ' + STUFF(@IntendToPartitionWithPartitionColumnNotInKeyColumnList, LEN(@IntendToPartitionWithPartitionColumnNotInKeyColumnList), 1,'')
		
--		RAISERROR(@ErrorText, 16, 1)
--	END   

--	SELECT @TableAndIndexStorageMismatch += I.SchemaName + '.' + I.TableName + '.' + I.IndexName + ','
--	FROM DDI.Tables T
--		INNER JOIN Inserted I ON I.SchemaName = T.SchemaName 
--			AND I.TableName = T.TableName 
--	WHERE I.NewStorage <> t.NewStorage

--	IF LTRIM(RTRIM(@TableAndIndexStorageMismatch)) <> ''
--	BEGIN
--		SET @ErrorText = 'The Following Indexe(s) do not match the storage of their parent table:  ' + STUFF(@TableAndIndexStorageMismatch, LEN(@TableAndIndexStorageMismatch), 1,'')
		
--		RAISERROR(@ErrorText, 10, 1)
--	END   

--	SELECT @IndexAndPartitionCompressionMismatch += I.SchemaName + '.' + I.TableName + '.' + I.IndexName + '__' + CAST(IP.PartitionNumber AS VARCHAR(5)) + ','
--	FROM Inserted I 
--		INNER JOIN DDI.IndexColumnStorePartitions IP ON I.SchemaName = IP.SchemaName 
--			AND I.TableName = IP.TableName 
--			AND I.IndexName = IP.IndexName 
--	WHERE I.OptionDataCompression <> IP.OptionDataCompression

--	IF LTRIM(RTRIM(@IndexAndPartitionCompressionMismatch)) <> ''
--	BEGIN
--		SET @ErrorText = 'The Following Index Partition(s) do not match the compression setting of their parent index:  ' + STUFF(@IndexAndPartitionCompressionMismatch, LEN(@IndexAndPartitionCompressionMismatch), 1,'')
		
--		RAISERROR(@ErrorText, 10, 1)
--	END  

--	SELECT @ColumnListsWithSpacesAfterCommas += IndexName + ','
--	FROM Inserted I
--	WHERE I.ColumnList LIKE '%, %' 

--	IF LTRIM(RTRIM(@ColumnListsWithSpacesAfterCommas)) <> ''
--	BEGIN
--		SET @ErrorText = 'The Following Index(es) have spaces after commas in their Column Lists.  Remove the spaces:  ' + STUFF(@ColumnListsWithSpacesAfterCommas, LEN(@ColumnListsWithSpacesAfterCommas), 1,'')
		
--		RAISERROR(@ErrorText, 10, 1)
--	END  

--END

--GO

DELETE DDI.IndexesRowStore
GO

INSERT INTO DDI.IndexesRowStore 
		(	DatabaseName        , SchemaName	,TableName										,IndexName															,IsUnique	,IsPrimaryKey	, IsUniqueConstraint, IsClustered	,KeyColumnList																											,IncludedColumnList																																													,IsFiltered ,FilterPredicate													,[Fillfactor]	,OptionPadIndex ,OptionStatisticsNoRecompute	,OptionStatisticsIncremental	,OptionIgnoreDupKey ,OptionResumable	,OptionMaxDuration	,OptionAllowRowLocks	,OptionAllowPageLocks	,OptionDataCompression	, NewStorage						, PartitionColumn			)
VALUES	 (	N'PaymentReporting' , N'DataMart'	, N'AgencyLocalityTypeDim'						, N'PK_AgencyLocalityTypeDim'										, 1			, 1				, 0					, 1				, N'AgencyLocalityTypeKey ASC'																							, NULL																																																, 0			, NULL																, 0				, 1				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'AgencyLocalityTypeDim'						, N'UQ_AgencyLocalityTypeDim'										, 1			, 0				, 0					, 0				, N'AgencyLocalityTypeDesc ASC'																							, NULL																																																, 0			, NULL																, 0				, 1				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'Bai2BankTransactionTypeDim'					, N'PK_Bai2BankTransactionTypeDim'									, 1			, 1				, 0					, 1				, N'Bai2BankTransactionTypeKey ASC'																						, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'Bai2BankTransactionTypeDim'					, N'UQ_Bai2BankTransactionTypeDim'									, 1			, 0				, 0					, 0				, N'Bai2BankTransactionTypeDesc ASC'																					, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'BankAccountPurposeDim'						, N'PK_BankAccountPurposeDim'										, 1			, 1				, 0					, 1				, N'BankAccountPurposeKey ASC'																							, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'BankAccountStatusDim'						, N'PK_BankAccountStatusDim'										, 1			, 1				, 0					, 1				, N'BankAccountStatusKey ASC'																							, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'BankAccountStatusDim'						, N'UQ_BankAccountStatusDim'										, 1			, 0				, 0					, 0				, N'BankAccountStatusDesc ASC'																							, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'BankAccountTypeDim'							, N'PK_BankAccountTypeDim'											, 1			, 1				, 0					, 1				, N'BankAccountTypeKey ASC'																								, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'BankAccountTypeDim'							, N'UQ_BankAccountTypeDim'											, 1			, 0				, 0					, 0				, N'BankAccountTypeDesc ASC'																							, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'BankTransactionTypeDim'						, N'PK_BankTransactionTypeDim'										, 1			, 1				, 0					, 1				, N'BankTransactionTypeKey ASC'																							, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'CheckAddModeDim'							, N'PK_CheckAddModeDim'												, 1			, 1				, 0					, 1				, N'checkAddModeKey ASC'																								, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'CheckAddModeDim'							, N'UQ_CheckAddModeDim'												, 1			, 0				, 0					, 0				, N'checkAddModeDesc ASC'																								, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'CheckStatusDim'								, N'PK_CheckStatusDim'												, 1			, 1				, 0					, 1				, N'CheckStatusKey ASC'																									, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'CheckStatusDim'								, N'UQ_CheckStatusDim'												, 1			, 0				, 0					, 0				, N'CheckStatusDesc ASC'																								, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'Company_TaxStatusDim'						, N'PK_Company_TaxStatusDim'										, 1			, 1				, 0					, 1				, N'Company_TaxStatusKey ASC'																							, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'Company_TaxStatusDim'						, N'UDX_Company_TaxStatusDim'										, 1			, 0				, 0					, 0				, N'Company_TaxStatusDesc ASC'																							, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'CompanyTaxAgencyStatusDim'					, N'PK_CompanyTaxAgencyStatusDim'									, 1			, 1				, 0					, 1				, N'CompanyTaxAgencyStatusKey ASC'																						, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'CompanyTaxAgencyStatusDim'					, N'UDX_CompanyTaxAgencyStatusDim'									, 1			, 0				, 0					, 0				, N'CompanyTaxAgencyStatusDesc ASC'																						, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'CompanyStatusDim'							, N'PK_CompanyStatusDim'											, 1			, 1				, 0					, 1				, N'CompanyStatusKey ASC'																								, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'CompanyStatusDim'							, N'UQ_CompanyStatusDim'											, 1			, 0				, 0					, 0				, N'CompanyStatusDesc ASC'																								, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'CompanyTypeDim'								, N'PK_CompanyTypeDim'												, 1			, 1				, 0					, 1				, N'CompanyTypeKey ASC'																									, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'CompanyTypeDim'								, N'UQ_CompanyTypeDim'												, 1			, 0				, 0					, 0				, N'CompanyTypeDesc ASC'																								, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'CreditEffectOnLiabilityDim'					, N'PK_CreditEffectOnLiabilityDim'									, 1			, 1				, 0					, 1				, N'CreditEffectOnLiabilityKey ASC'																						, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'CreditEffectOnLiabilityDim'					, N'UQ_CreditEffectOnLiabilityDim'									, 1			, 0				, 0					, 0				, N'CreditEffectOnLiabilityDesc ASC'																					, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'FileRequestProcessingStatusDim'				, N'PK_FileRequestProcessingStatusDim'								, 1			, 1				, 0					, 1				, N'FileRequestProcessingStatusKey ASC'																					, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'GarnishmentActionTypeDim'					, N'PK_GarnishmentActionDim'										, 1			, 1				, 0					, 1				, N'GarnishmentActionTypeKey ASC'																						, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'GarnishmentActionTypeDim'					, N'UQ_GarnishmentActionDim'										, 1			, 0				, 0					, 0				, N'GarnishmentActionTypeDesc ASC'																						, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'GarnishmentExceptionDim'					, N'PK_GarnishmentExceptionDim'										, 1			, 1				, 0					, 1				, N'GarnishmentExceptionKey ASC'																						, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'GarnishmentExceptionDim'					, N'UQ_GarnishmentExceptionDim'										, 1			, 0				, 0					, 0				, N'GarnishmentExceptionDesc ASC'																						, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'GarnishmentIsInArrearsDim'					, N'PK_GarnishmentIsInArrearsDim'									, 1			, 1				, 0					, 1				, N'IsInArrearsKey ASC'																									, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'GarnishmentIsInArrearsDim'					, N'UQ_GarnishmentIsInArrearsDim'									, 1			, 0				, 0					, 0				, N'IsInArrearsDesc ASC'																								, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'GarnishmentLiabilityStatusDim'				, N'PK_GarnishmentLiabilityStatusDim'								, 1			, 1				, 0					, 1				, N'GarnishmentLiabilityStatusKey ASC'																					, NULL																																																, 0			, NULL																, 0				, 1				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'GarnishmentLiabilityStatusDim'				, N'UQ_GarnishmentLiabilityStatusDim'								, 1			, 0				, 0					, 0				, N'GarnishmentLiabilityStatusDesc ASC'																					, NULL																																																, 0			, NULL																, 0				, 1				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'GarnishmentLiabilityTypeDim'				, N'PK_GarnishmentLiabilityTypeDim'									, 1			, 1				, 0					, 1				, N'GarnishmentLiabilityTypeKey ASC'																					, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'GarnishmentMedIndicatorDim'					, N'PK_GarnishmentMedIndicatorDim'									, 1			, 1				, 0					, 1				, N'MedIndicatorKey ASC'																								, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'GarnishmentMedIndicatorDim'					, N'UQ_GarnishmentMedIndicatorDim'									, 1			, 0				, 0					, 0				, N'MedIndicatorDesc ASC'																								, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'GarnishmentPayableStatusDim'				, N'PK_GarnishmentPayableStatusDim'									, 1			, 1				, 0					, 1				, N'GarnishmentPayableStatusKey ASC'																					, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'GarnishmentPayableStatusDim'				, N'UQ_GarnishmentPayableStatusDim'									, 1			, 0				, 0					, 0				, N'GarnishmentPayableStatusDesc ASC'																					, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'GarnishmentPaymentTypeDim'					, N'PK_GarnishmentPaymentTypeDim'									, 1			, 1				, 0					, 1				, N'GarnishmentPaymentTypeKey ASC'																						, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'GarnishmentPaymentTypeDim'					, N'UQ_GarnishmentPaymentTypeDim'									, 1			, 0				, 0					, 0				, N'GarnishmentPaymentTypeDesc ASC'																						, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'GarnishmentPayrollInstanceReconStatusDim'	, N'PK_GarnishmentPayrollInstanceReconStatusDim'					, 1			, 1				, 0					, 1				, N'GarnishmentPayrollInstanceReconStatusKey ASC'																		, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'GarnishmentPayrollInstanceReconStatusDim'	, N'UQ_GarnishmentPayrollInstanceReconStatusDim'					, 1			, 0				, 0					, 0				, N'GarnishmentPayrollInstanceReconStatusDesc ASC'																		, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'GarnishmentsSupportsOthersDim'				, N'PK_GarnishmentsSupportsOthersDim'								, 1			, 1				, 0					, 1				, N'SupportsOthersKey ASC'																								, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'GarnishmentsSupportsOthersDim'				, N'UQ_GarnishmentsSupportsOthersCode'								, 1			, 0				, 0					, 0				, N'SupportsOthersDesc ASC'																								, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'GarnishmentStatusDim'						, N'PK_GarnishmentStatusDim'										, 1			, 1				, 0					, 1				, N'GarnishmentStatusKey ASC'																							, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'GarnishmentStatusDim'						, N'UQ_GarnishmentsStatusDim'										, 1			, 0				, 0					, 0				, N'GarnishmentStatusDesc ASC'																							, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'GarnishmentTypeDim'							, N'PK_GarnishmentTypeDim'											, 1			, 1				, 0					, 1				, N'GarnishmentTypeKey ASC'																								, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'GarnishmentTypeDim'							, N'UQ_GarnishmentTypeDim'											, 1			, 0				, 0					, 0				, N'GarnishmentTypeDesc ASC'																							, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'GLAccountClassificationDim'					, N'PK_GLAccountClassificationDim'									, 1			, 1				, 0					, 1				, N'GLAccountClassificationKey ASC'																						, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'GLAccountClassificationDim'					, N'UQ_GLAccountClassificationDim'									, 1			, 0				, 0					, 0				, N'GLAccountClassificationDesc ASC'																					, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'GLAccountStatusDim'							, N'PK_GLAccountStatusDim'											, 1			, 1				, 0					, 1				, N'GLAccountStatusKey ASC'																								, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'GLAccountStatusDim'							, N'UQ_GLAccountStatusDim'											, 1			, 0				, 0					, 0				, N'GLAccountStatusDesc ASC'																							, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'GLAccountTypeDim'							, N'PK_GLAccountTypeDim'											, 1			, 1				, 0					, 1				, N'GLAccountTypeKey ASC'																								, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'GLAccountTypeDim'							, N'UQ_GLAccountTypeDim'											, 1			, 0				, 0					, 0				, N'GLAccountTypeDesc ASC'																								, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'InboundFileTypeDim'							, N'PK_InboundFileTypeDim'											, 1			, 1				, 0					, 1				, N'InboundFileTypeKey ASC'																								, NULL																																																, 0			, NULL																, 0				, 1				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'InboundFileTypeDim'							, N'UQ_InboundFileTypeDim'											, 1			, 0				, 0					, 0				, N'InboundFileTypeDesc ASC'																							, NULL																																																, 0			, NULL																, 0				, 1				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'JournalEntryTransactionTypeDim'				, N'PK_JournalEntryTransactionTypeDim'								, 1			, 1				, 0					, 1				, N'JournalEntryTransactionTypeDimKey ASC'																				, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'JournalEntryTransactionTypeDim'				, N'UQ_JournalEntryTransactionTypeDim'								, 1			, 0				, 0					, 0				, N'JournalEntryTransactionTypeDimDescription ASC'																		, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'LiabilityCollectionPaymentMethodDim'		, N'PK_LiabilityCollectionPaymentMethodDim'							, 1			, 1				, 0					, 1				, N'LiabilityCollectionPaymentMethodKey ASC'																			, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'LiabilityCollectionPaymentMethodDim'		, N'UQ_LiabilityCollectionPaymentMethodDim'							, 1			, 0				, 0					, 0				, N'LiabilityCollectionPaymentMethodDesc ASC'																			, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'LiabilityCollectionStatusDim'				, N'PK_LiabilityCollectionStatusDim'								, 1			, 1				, 0					, 1				, N'LiabilityCollectionStatusKey ASC'																					, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'LiabilityCollectionStatusDim'				, N'UQ_LiabilityCollectionStatusDim'								, 1			, 0				, 0					, 0				, N'LiabilityCollectionStatusDesc ASC'																					, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'LiabilityCollectionTypeDim'					, N'PK_LiabilityCollectionTypeDim'									, 1			, 1				, 0					, 1				, N'LiabilityCollectionTypeKey ASC'																						, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'LiabilityStatusDim'							, N'PK_LiabilityStatusDim'											, 1			, 1				, 0					, 1				, N'LiabilityStatusKey ASC'																								, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'LiabilityStatusDim'							, N'UQ_LiabilityStatusDim'											, 1			, 0				, 0					, 0				, N'LiabilityStatusDesc ASC'																							, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'LiabilityTypeDim'							, N'PK_LiabilityTypeDim'											, 1			, 1				, 0					, 1				, N'LiabilityTypeKey ASC'																								, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'NettedCollectionStatusDim'					, N'PK_NettedCollectionStatusDim'									, 1			, 1				, 0					, 1				, N'NettedCollectionStatusKey ASC'																						, NULL																																																, 0			, NULL																, 0				, 0				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'PayExceptionTypeDim'						, N'PK_PayExceptionTypeDim'											, 1			, 1				, 0					, 1				, N'PayExceptionTypeKey ASC'																							, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'PayExceptionTypeDim'						, N'UQ_PayExceptionTypeDim'											, 1			, 0				, 0					, 0				, N'PayExceptionTypeDesc ASC'																							, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'PayPortionStateDim'							, N'PK_PayPortionStateDim'											, 1			, 1				, 0					, 1				, N'PayPortionStateKey ASC'																								, NULL																																																, 0			, NULL																, 0				, 1				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'PayPortionStateDim'							, N'UQ_PayPortionStateDim'											, 1			, 0				, 0					, 0				, N'PayPortionStateDesc ASC'																							, NULL																																																, 0			, NULL																, 0				, 1				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'PayProcessingStatusDim'						, N'PK_PayProcessingStatusDim'										, 1			, 1				, 0					, 1				, N'PayProcessingStatusKey ASC'																							, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'PayProcessingStatusDim'						, N'UQ_PayProcessingStatusDim'										, 1			, 0				, 0					, 0				, N'PayProcessingStatusDesc ASC'																						, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'PayrollPaymentStatusDim'					, N'PK_PayrollPaymentStatusDim'										, 1			, 1				, 0					, 1				, N'PayrollPaymentStatusKey ASC'																						, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'PayrollPaymentTypeDim'						, N'PK_PayrollPaymentTypeDim'										, 1			, 1				, 0					, 1				, N'PayrollPaymentTypeKey ASC'																							, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'PayrollTypeDim'								, N'PK_PayrollTypeDim'												, 1			, 1				, 0					, 1				, N'PayrollTypeKey ASC'																									, NULL																																																, 0			, NULL																, 0				, 0				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'PayrollTypeDim'								, N'UQ_PayrollTypeDim'												, 1			, 0				, 0					, 0				, N'PayrollTypeDesc ASC'																								, NULL																																																, 0			, NULL																, 0				, 1				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'ProductActivationStatus'					, N'PK_TenantProductActivationStatus'								, 1			, 1				, 0					, 1				, N'ProductActivationStatusKey ASC'																						, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'ProductActivationStatus'					, N'UQ_TenantProductActivationStatus'								, 1			, 0				, 0					, 0				, N'ProductActivationStatusDesc ASC'																					, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'ProductCodeDim'								, N'PK_ProductCodeDim'												, 1			, 1				, 0					, 1				, N'ProductCodeKey ASC'																									, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'ProductCodeDim'								, N'UQ_ProductCodeDim'												, 1			, 0				, 0					, 0				, N'ProductCodeDesc ASC'																								, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'ProductStatus'								, N'PK_TenantProductStatus'											, 1			, 1				, 0					, 1				, N'ProductStatusKey ASC'																								, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'ProductStatus'								, N'UQ_TenantProductStatus'											, 1			, 0				, 0					, 0				, N'ProductStatusDesc ASC'																								, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
        ,(  N'PaymentReporting' , N'DataMart'   , N'QEADJFilterOptions'                         , N'PK_QEADJFilterOptions'                                          , 1         , 1             , 0                 , 1             , N'QEADJFilterOptionKey ASC'                                                                                           , NULL                                                                                                                                                                                              , 0         , NULL                                                              , 0             , 0             , 0                             , 0                             , 0                 , DEFAULT           , 0                 , 1                     , 1                     , DEFAULT               , 'PRIMARY'                         , NULL                      )
        ,(  N'PaymentReporting' , N'DataMart'   , N'QEADJFilterOptions'                         , N'UDX_QEADJFilterOption'                                          , 1         , 0             , 0                 , 0             , N'QEADJFilterOptionDesc ASC'                                                                                          , NULL                                                                                                                                                                                              , 0         , NULL                                                              , 0             , 0             , 0                             , 0                             , 0                 , DEFAULT           , 0                 , 1                     , 1                     , DEFAULT               , 'PRIMARY'                         , NULL                      )
		,(	N'PaymentReporting' , N'DataMart'	, N'RefundPortionDim'							, N'PK_RefundPortionDim'											, 1			, 1				, 0					, 1				, N'RefundPortionKey ASC'																								, NULL																																																, 0			, NULL																, 0				, 1				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'RefundPortionDim'							, N'UQ_RefundPortionDim'											, 1			, 0				, 0					, 0				, N'RefundPortionDesc ASC'																								, NULL																																																, 0			, NULL																, 0				, 1				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'ReportRequestorTypeDim'						, N'PK_ReportSourceSystemDim'										, 1			, 1				, 0					, 1				, N'ReportSourceSystemName ASC'																							, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'ReportRequestStatusDim'						, N'PK_ReportRequestStatusDim'										, 1			, 1				, 0					, 1				, N'ReportRequestStatusKey ASC'																							, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'TaxAgencyTransactionStatusDim'				, N'PK_TaxAgencyTransactionStatusDim'								, 1			, 1				, 0					, 1				, N'TaxAgencyTransactionStatusKey ASC'																					, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'TaxAgencyTransactionStatusDim'				, N'UQ_TaxAgencyTransactionStatusDim'								, 1			, 0				, 0					, 0				, N'TaxAgencyTransactionStatusDesc ASC'																					, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'TaxCodeActiveStatus'						, N'PK_TaxCodeActiveStatus'											, 1			, 1				, 0					, 1				, N'TaxCodeActiveStatusKey ASC'																							, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'TaxCodeActiveStatus'						, N'UQ_TaxCodeActiveStatus'											, 1			, 0				, 0					, 0				, N'TaxCodeActiveStatusDesc ASC'																						, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'TaxCodeProcessingFrequencyDim'				, N'PK_TaxCodeProcessingFrequencyDim'								, 1			, 1				, 0					, 1				, N'TaxCodeProcessingFrequencyKey ASC'																					, NULL																																																, 0			, NULL																, 0				, 0				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'TaxCodeProcessingFrequencyDim'				, N'UQ_TaxCodeProcessingFrequencyDim'								, 1			, 0				, 0					, 0				, N'TaxCodeProcessingFrequencyDesc ASC'																					, NULL																																																, 0			, NULL																, 0				, 1				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'TaxPaymentCreditStatusDim'					, N'PK_TaxPaymentCreditStatusDim'									, 1			, 1				, 0					, 1				, N'TaxPaymentCreditStatusKey ASC'																						, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'TaxPaymentCreditStatusDim'					, N'UQ_TaxPaymentCreditStatusDim'									, 1			, 0				, 0					, 0				, N'TaxPaymentCreditStatusDesc ASC'																						, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'TaxPaymentStatusDim'						, N'PK_TaxPaymentStatusDim'											, 1			, 1				, 0					, 1				, N'TaxPaymentStatusKey ASC'																							, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'TaxPaymentStatusDim'						, N'UQ_TaxPaymentStatusDim'											, 1			, 0				, 0					, 0				, N'TaxPaymentStatusDesc ASC'																							, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'TaxPaymentTypeDim'							, N'PK_TaxPaymentTypeDim'											, 1			, 1				, 0					, 1				, N'TaxPaymentTypeKey ASC'																								, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'TaxPaymentTypeDim'							, N'UQ_TaxPaymentTypeDim'											, 1			, 0				, 0					, 0				, N'TaxPaymentTypeDesc ASC'																								, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'TenantStatusDim'							, N'PK_TenantStatusDim'												, 1			, 1				, 0					, 1				, N'TenantStatusCode ASC'																								, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'TenantStatusDim'							, N'UQ_TenantStatusDim'												, 1			, 0				, 0					, 0				, N'TenantStatusDesc ASC'																								, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'UTETaxDataSourceTableSetDim'				, N'PkUTETaxDataSourceTableSetDim'									, 1			, 1				, 0					, 1				, N'UTETaxDataSourceTableSetKey ASC'																					, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'GarnishmentActionReasonDim'					, N'PK_GarnishmentActionReasonDim'									, 1			, 1				, 0					, 1				, N'GarnishmentActionReasonKey ASC'																						, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'GarnishmentActionReasonDim'					, N'UQ_GarnishmentActionReasonDim'									, 1			, 0				, 0					, 0				, N'GarnishmentActionReasonDesc ASC'																					, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'TaxLiabilityOriginTypeDim'					, N'PK_TaxLiabilityOriginTypeDim'									, 1			, 1				, 0					, 1				, N'TaxLiabilityOriginTypeKey ASC'																						, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'TaxLiabilityOriginTypeDim'					, N'UQ_TaxLiabilityOriginTypeDim'									, 1			, 0				, 0					, 0				, N'TaxLiabilityOriginTypeDesc ASC'																						, NULL																																																, 0			, NULL																, 0				, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'YEFileStatusDim'							, N'PK_YEFileStatusDim'												, 1			, 1				, 0					, 1				, N'YEFileStatusKey ASC'																								, NULL																																																, 0			, NULL																, 0				, 1				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'YEFileStatusDim'							, N'UQ_YEFileStatusDim'												, 1			, 0				, 0					, 0				, N'YEFileStatusDesc ASC'																								, NULL																																																, 0			, NULL																, 0				, 1				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'YEIngestionTypeDim'							, N'PK_YEIngestionTypeDim'											, 1			, 1				, 0					, 1				, N'YEIngestionTypeKey ASC'																								, NULL																																																, 0			, NULL																, 0				, 1				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'YEIngestionTypeDim'							, N'UQ_YEIngestionTypeDim'											, 1			, 0				, 0					, 0				, N'YEIngestionTypeDesc ASC'																							, NULL																																																, 0			, NULL																, 0				, 1				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'YEProcessingStatusDim'						, N'PK_YEProcessingStatusDim'										, 1			, 1				, 0					, 1				, N'YEProcessingStatusKey ASC'																							, NULL																																																, 0			, NULL																, 0				, 1				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'DataMart'	, N'YEProcessingStatusDim'						, N'UQ_YEProcessingStatusDim'										, 1			, 0				, 0					, 0				, N'YEProcessingStatusDesc ASC'																							, NULL																																																, 0			, NULL																, 0				, 1				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)
    --	(	DatabaseName        , SchemaName	,TableName									    ,IndexName												            ,IsUnique	 ,IsPrimaryKey	, IsUniqueConstraint, IsClustered	,KeyColumnList				                                                                                            ,IncludedColumnList	                                                                                                                                                                                ,IsFiltered ,FilterPredicate                                                    ,[Fillfactor]	,OptionPadIndex ,OptionStatisticsNoRecompute	,OptionStatisticsIncremental	,OptionIgnoreDupKey	,OptionResumable	,OptionMaxDuration	,OptionAllowRowLocks	,OptionAllowPageLocks	,OptionDataCompression	, NewStorage						, PartitionColumn			)		
		,(	N'PaymentReporting' , N'dbo'		, N'Bai2BankTransactions'						, N'CDX_Bai2BankTransactions'										, 0			, 0				, 0					, 1				, N'TransactionSysUtcDt ASC'																							, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 1     						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearly'						, 'TransactionSysUtcDt'		)
		,(	N'PaymentReporting' , N'dbo'		, N'Bai2BankTransactions'						, N'PK_Bai2BankTransactions'										, 1			, 1				, 0					, 0				, N'TransactionSysUtcDt ASC,BankTransactionId ASC'																		, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 0								, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearly'						, 'TransactionSysUtcDt'		)
		,(	N'PaymentReporting' , N'dbo'		, N'BankAccountDays'							, N'PK_BankAccountDays'												, 1			, 1				, 0					, 0				, N'BankAccountDayId ASC'																								, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'BankTransactions'							, N'CDX_BankTransactions'											, 0			, 0				, 0					, 1				, N'TransactionUtcDateTime ASC'																							, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 1     						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearlyNoSlidingWindow'			, 'TransactionUtcDateTime'	)
		,(	N'PaymentReporting' , N'dbo'		, N'BankTransactions'							, N'IDX_BankTransactions_BankAcctCover'								, 0			, 0				, 0					, 0				, N'CollectionId ASC,UpdatedUtcDt ASC,TransactionUtcDateTime ASC'														, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 1     						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearlyNoSlidingWindow'			, 'TransactionUtcDateTime'	)
		,(	N'PaymentReporting' , N'dbo'		, N'BankTransactions'							, N'IDX_BankTransactions_GarnishmentPDCover'						, 0			, 0				, 0					, 0				, N'TenantId ASC,GarnishmentId ASC,TransactionUtcDateTime ASC'															, N'CbaRoutingNumber4,CbaAccountNumber4,CheckNumber,FileRequestId'																																	, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 1     						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearlyNoSlidingWindow'			, 'TransactionUtcDateTime'	)
		,(	N'PaymentReporting' , N'dbo'		, N'BankTransactions'							, N'PK_BankTransactions'											, 1			, 1				, 0					, 0				, N'TransactionUtcDateTime ASC,Id ASC,TenantId ASC'																		, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 1								, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearlyNoSlidingWindow'			, 'TransactionUtcDateTime'	)
		--,(	N'dbo'		, N'changelog'									, N'PK_changelog'																													, 1, 1, 0, 1, N'ID ASC'																								, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT)																					
		,(	N'PaymentReporting' , N'dbo'		, N'Companies'									, N'IX_Companies'													, 0			, 0				, 0					, 0				, N'TenantId ASC,COID ASC'																								, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'Companies'									, N'PK_Companies'													, 1			, 1				, 0					, 1				, N'CompanyId ASC,TenantId ASC'																							, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'Companies'									, N'UQ_Companies'													, 1			, 0				, 0					, 0				, N'CompanyId ASC'																										, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'Companies'									, N'UQ_Companies_UTEClientId'										, 1			, 0				, 0					, 0				, N'UTEClientId ASC'																									, NULL																																																, 1			, N'([UTEClientId] IS NOT NULL)'									, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'Company_Tax'								, N'PK_Company_Tax'													, 1			, 1				, 0					, 0				, N'Company_TaxGUID'																									, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'Company_Tax'								, N'UDX_Company_TaxCompanyId'										, 1			, 0				, 0					, 1				, N'CompanyId ASC,TenantId ASC'																							, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'Company_Tax'								, N'UDX_Company_TaxId'												, 1			, 0				, 0					, 0				, N'Company_TaxId ASC'																							    	, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'CompanyTaxAgency'							, N'PK_CompanyTaxAgency'											, 1			, 1				, 0					, 0				, N'CompanyTaxAgencyId ASC'																								, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'CompanyTaxAgency'							, N'UDX_CompanyTaxAgency_Company_TaxGUID_TaxAgencyId'				, 1			, 0				, 0					, 1				, N'Company_TaxGUID ASC,TaxAgencyId ASC'																				, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'CompanyProduct'								, N'PK_CompanyProduct'												, 1			, 1				, 0					, 1				, N'CompanyId ASC,ProductCodeKey ASC,EffectiveUtcDateFrom ASC'															, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'CustomerBankAccounts'						, N'PK_CustomerBankAccounts'										, 1			, 1				, 0					, 1				, N'TenantId ASC,BankAccountId ASC'																						, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'DBDefragLog'								, N'PK_DBDefragLog'													, 1			, 1				, 0					, 1				, N'SchemaName ASC,RunDateTime ASC,TableName ASC,IndexName ASC'															, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'EFilingAcknowledgmentAlerts'				, N'PK_EFilingAcknowledgmentAlerts'									, 1			, 1				, 0					, 1				, N'EFilingAcknowledgmentAlertId ASC'																					, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'EFilingAcknowledgments'						, N'PK_EFilingAcknowledgments'										, 1			, 1				, 0					, 1				, N'SubmissionId ASC'																									, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'EFilingAcknowledgments'						, N'UQ_EFilingAcknowledgments'										, 1			, 0				, 0					, 0				, N'EFilingAcknowledgmentId ASC'																						, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'FileRequestPayments'						, N'PK_FileRequestPayments'											, 1			, 1				, 0					, 1				, N'PaymentId ASC,PaymentFileRequestId ASC'																				, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'FileRequests'								, N'PK_FileRequests'												, 1			, 1				, 0					, 1				, N'FileRequestId ASC'																									, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'GarnishmentLiabilities'						, N'IDX_GarnishmentLiabilities_TenantId'							, 0			, 0				, 0					, 0				, N'TenantId ASC'																										, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'GarnishmentLiabilities'						, N'PK_GarnishmentLiabilities'										, 1			, 1				, 0					, 1				, N'GarnishmentLiabilityId ASC,TenantId ASC'																			, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'GarnishmentLiabilities'						, N'IDX_GarnishmentLiabilities_PayrollInstanceId'					, 0			, 0				, 0					, 0				, N'PayrollInstanceId ASC'																								, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'GarnishmentLiabilities'						, N'UDX_GarnishmentLiabilities'                  					, 1			, 0				, 0					, 0				, N'LiabilityId ASC,GarnishmentLiabilityId ASC'																			, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'GarnishmentPayrollInstances'				, N'PK_GarnishmentPayrollInstances'									, 1			, 1				, 0					, 0				, N'GarnishmentPayrollInstanceId ASC,TenantId ASC'																		, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'GeneralLedgerAccounts'						, N'IDX_GeneralLedgerAccounts_GLSegment'							, 0			, 0				, 0					, 0				, N'GlSegment ASC'																										, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'GeneralLedgerAccounts'						, N'PK_GeneralLedgerAccounts'										, 1			, 1				, 0					, 1				, N'AccountId ASC'																										, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'JournalEntries'								, N'CDX_JournalEntries'												, 0			, 0				, 0					, 1				, N'TransactionUtcDt ASC'																								, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 1     						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psMonthly'						, 'TransactionUtcDt'		)
		,(	N'PaymentReporting' , N'dbo'		, N'JournalEntries'								, N'IDX_JournalEntries_AgencyCode'									, 0			, 0				, 0					, 0				, N'AgencyCode ASC,TenantId ASC,TransactionUtcDt ASC'																	, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 1     						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psMonthly'						, 'TransactionUtcDt'		)
		,(	N'PaymentReporting' , N'dbo'		, N'JournalEntries'								, N'PK_JournalEntries'												, 1			, 1				, 0					, 0				, N'JournalEntryId ASC,TransactionUtcDt ASC'																			, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 1								, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psMonthly'						, 'TransactionUtcDt'		)
		,(	N'PaymentReporting' , N'dbo'		, N'Liabilities'								, N'IDX_Liabilities_WACDCover'										, 0			, 0				, 0					, 0				, N'TenantId ASC,CollectionId ASC,PayrollId ASC,PayUtcDt ASC'															, N'LiabilityId,Type,SourceCreatedUtcDt'																																							, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 1     						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearly'            			, 'PayUtcDt'				)
		,(	N'PaymentReporting' , N'dbo'		, N'Liabilities'								, N'CDX_Liabilities'												, 0			, 0				, 0					, 1				, N'PayDate ASC'																										, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 1     						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearly'						, 'PayDate'					)
		,(	N'PaymentReporting' , N'dbo'		, N'Liabilities'								, N'IDX_Liabilities_CollectionProductListCover'						, 0			, 0				, 0					, 0				, N'CollectionId ASC,ProductCode ASC,PayDate ASC'																		, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 1     						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearly'						, 'PayDate'					)
		,(	N'PaymentReporting' , N'dbo'		, N'Liabilities'								, N'IDX_Liabilities_CompanyAggregateCover'							, 0			, 0				, 0					, 0				, N'CollectionId ASC,TenantId ASC,LegalEntityCompanyId ASC,PayDate ASC'													, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 1     						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearly'						, 'PayDate'					)
		,(	N'PaymentReporting' , N'dbo'		, N'Liabilities'								, N'IDX_Liabilities_PayrollAggregateCover'							, 0			, 0				, 0					, 0				, N'CollectionId ASC,TenantId ASC,PayrollId ASC,PayDate ASC'															, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 1     						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearly'						, 'PayDate'					)
		,(	N'PaymentReporting' , N'dbo'		, N'Liabilities'								, N'PK_Liabilities'													, 1			, 1				, 0					, 0				, N'PayDate ASC,LiabilityId ASC,TenantId ASC'																			, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 0								, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearly'						, 'PayDate'					)
		,(	N'PaymentReporting' , N'dbo'		, N'LiabilityCollections'						, N'CDX_LiabilityCollections'										, 0			, 0				, 0					, 1				, N'PayUtcDt ASC'																										, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 1	        					, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearly'						, 'PayUtcDt'				)
		,(	N'PaymentReporting' , N'dbo'		, N'LiabilityCollections'						, N'IDX_LiabilityCollections_CDCover'								, 0			, 0				, 0					, 0				, N'CollectionId ASC,PayUtcDt ASC'																						, 'CollectedUtcDateTime,Status,Type,ConfirmationNumber,DueDate,PaymentMethod,TenantId'																												, 0			, NULL																, 90			, 1				, 0								, 1								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'psYearly'						, 'PayUtcDt'				)
		,(	N'PaymentReporting' , N'dbo'		, N'LiabilityCollections'						, N'IDX_LiabilityCollections_WACD_ExternalCover'					, 0			, 0				, 0					, 0				, N'TenantId ASC,PayUtcDt ASC'																							, N'CollectionId,PaymentMethod,DueDate,CollectedUtcDateTime,ConfirmationNumber,Status,UsgBankAccountId,CustomerBankAccountId'																		, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 1		        				, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearly'						, 'PayUtcDt'				)
		,(	N'PaymentReporting' , N'dbo'		, N'LiabilityCollections'						, N'PK_LiabilityCollections'										, 1			, 1				, 0					, 0				, N'PayUtcDt ASC,CollectionId ASC'																						, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 1     						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearly'						, 'PayUtcDt'				)
		,(	N'PaymentReporting' , N'dbo'		, N'LiabilityCollections'						, N'IDX_LiabilityCollections_NetCollections'						, 0			, 0				, 0					, 0				, N'NettedCollectionId ASC,PayUtcDt ASC'																				, N'CollectionId,ConfirmationNumber,ProcessUtcDate'																																					, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearly'            			, 'PayUtcDt'				)
		,(	N'PaymentReporting' , N'dbo'		, N'LiabilityCollections'						, N'IDX_LiabilityCollections_NetCollectionsLatestConfNumberCover'	, 0			, 0				, 0					, 0				, N'NettedCollectionId ASC,ProcessUtcDate DESC,PayUtcDt ASC'															, N'ConfirmationNumber'																																												, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearly'            			, 'PayUtcDt'				)
		,(	N'PaymentReporting' , N'dbo'		, N'LiabilityCollections'						, N'IDX_LiabilityCollections_CheckDateCover'	                    , 0			, 0				, 0					, 0				, N'CollectedUtcDateTime ASC,PayUtcDt ASC'															                    , NULL																																												                , 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearly'            			, 'PayUtcDt'				)
		,(	N'PaymentReporting' , N'dbo'		, N'LiabilityCollections'						, N'IDX_LiabilityCollections_CheckDateCover2'	                    , 0			, 0				, 0					, 0				, N'TotalAmount ASC,CollectedUtcDateTime ASC,Type,PayUtcDt ASC'															, NULL      																																												        , 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 1     						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearly'            			, 'PayUtcDt'				)
		,(	N'PaymentReporting' , N'dbo'		, N'LiabilityCollectionConfirmationInfos'		, N'PK_LiabilityCollectionConfirmationInfos'						, 1			, 1				, 0					, 1				, N'LiabilityCollectionId ASC,ConfirmationInfoId ASC'																	, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'LiabilityCollectionComments'				, N'PK_LiabilityCollectionComments'									, 1			, 1				, 0					, 1				, N'CommentId ASC,LiabilityCollectionId ASC'																			, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'LiabilityPayments'							, N'PK_LiabilityPayments'											, 1			, 1				, 0					, 0				, N'LiabilityId ASC,PaymentId ASC,PaymentLiabilityId ASC'																, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'LiabilityPayments'							, N'IDX_LiabilityPayments_PaymentLiabilityId'						, 0			, 0				, 0					, 0				, N'PaymentLiabilityId ASC'																								, N'PaymentId'																																														, 1			, N'([PaymentLiabilityId]<>''00000000-0000-0000-0000-000000000000'')', 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'NettedCollections'							, N'PK_NettedCollections'											, 1			, 1				, 0					, 1				, N'NettedCollectionId ASC'																								, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'NettedCollectionsLiabilityCollections'		, N'PK_NettedCollectionsLiabilityCollections'						, 1			, 1				, 0					, 1				, N'NettedCollectionId ASC,CollectionId ASC'																			, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'PayActions'									, N'CDX_PayActions'													, 0			, 0				, 0					, 1				, N'PayUtcDate ASC'																										, NULL																																																, 0			, NULL																, 90			, 1				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'PayActions'									, N'PK_PayActions'													, 1			, 1				, 0					, 0				, N'ActionId ASC'																										, NULL																																																, 0			, NULL																, 90			, 1				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'PayGarnishment_Deductions'					, N'PK_PayGarnishment_Deductions'									, 1			, 1				, 0					, 1				, N'PayUtcDate ASC,GarnishmentId ASC'																					, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 1								, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearly'						, 'PayUtcDate'				)
		,(	N'PaymentReporting' , N'dbo'		, N'PayGarnishment_Employees'					, N'PK_PayGarnishment_Employees'									, 1			, 1				, 0					, 1				, N'PayUtcDate ASC,GarnishmentId ASC'																					, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 1								, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearly'						, 'PayUtcDate'				)
		,(	N'PaymentReporting' , N'dbo'		, N'PayGarnishment_Employees'					, N'IDX_PayGarnishment_Employees_WAPDCover'							, 0			, 0				, 0					, 0				, N'EmployeeNumber ASC,PayUtcDate ASC'																					, N'GarnishmentId,FirstName,LastName'																																								, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 1								, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearly'						, 'PayUtcDate'				)
		,(	N'PaymentReporting' , N'dbo'		, N'PayGarnishment_Payees'						, N'PK_PayGarnishment_Payees'										, 1			, 1				, 0					, 1				, N'PayUtcDate ASC,GarnishmentId ASC'																					, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 1								, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearly'						, 'PayUtcDate'				)
		,(	N'PaymentReporting' , N'dbo'		, N'PayGarnishmentActions'						, N'PK_PayGarnishmentActions'										, 1			, 1				, 0					, 1				, N'PayUtcDate ASC,GarnishmentId ASC,ActionId ASC'																		, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 1								, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearlyNoSlidingWindow'			, 'PayUtcDate'				)
		,(	N'PaymentReporting' , N'dbo'		, N'PayGarnishmentActions'						, N'UQ_PayGarnishmentActions'										, 1			, 0				, 0					, 0				, N'PayUtcDate ASC,GarnishmentId ASC,ActionId ASC,ActionUtcDateTime ASC'												, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 0								, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearlyNoSlidingWindow'			, 'PayUtcDate'				)
		,(	N'PaymentReporting' , N'dbo'		, N'PayGarnishmentExceptions'					, N'PK_PayGarnishmentExceptions'									, 1			, 1				, 0					, 1				, N'PayUtcDate ASC,GarnishmentId ASC,DateCleared ASC,GarnishmentExceptionKey ASC'										, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 1								, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearly'						, 'PayUtcDate'				)
		,(	N'PaymentReporting' , N'dbo'		, N'PayGarnishmentLiabilities'					, N'PK_PayGarnishmentLiabilities'									, 1			, 1				, 0					, 1				, N'PayUtcDate ASC,GarnishmentId ASC,GarnishmentLiabilityId ASC,TenantId ASC'											, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 1								, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearlyNoSlidingWindow'			, 'PayUtcDate'				)
		,(	N'PaymentReporting' , N'dbo'		, N'PayGarnishmentLiabilities'					, N'IDX_PayGarnishmentLiabilities_WACDCover'						, 0			, 0				, 0					, 0				, N'GarnishmentLiabilityId ASC,PayUtcDate ASC'																			, N'GarnishmentId,Refunded,Removed'																																									, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 0     						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearlyNoSlidingWindow'			, 'PayUtcDate'				)
		,(	N'PaymentReporting' , N'dbo'		, N'PayGarnishments'							, N'IDX_PayGarnishments_CollDetailsCover'							, 0			, 0				, 0					, 0				, N'PayUtcDate ASC'																										, N'TenantId,PayId,GarnishmentId,GarnishmentTypeKey,GarnishmentAmount,GarnishmentLiabilityId'																										, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 1     						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearlyNoSlidingWindow'			, 'PayUtcDate'				)
		,(	N'PaymentReporting' , N'dbo'		, N'PayGarnishments'							, N'IDX_PayGarnishments_CollDetailsCover2'							, 0			, 0				, 0					, 0				, N'GarnishmentTypeKey ASC,PayUtcDate ASC'																				, N'TenantId,PayId,GarnishmentId,GarnishmentLiabilityId'																																			, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 1     						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearlyNoSlidingWindow'			, 'PayUtcDate'				)
		,(	N'PaymentReporting' , N'dbo'		, N'PayGarnishments'							, N'IDX_Paygarnishments_IngestionCover'								, 0			, 0				, 0					, 0				, N'GarnishmentId ASC,PayUtcDate ASC'																					, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 1     						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearlyNoSlidingWindow'			, 'PayUtcDate'				)
		,(	N'PaymentReporting' , N'dbo'		, N'PayGarnishments'							, N'IDX_PayGarnishments_WACD_ExternalCover'							, 0			, 0				, 0					, 0				, N'TenantId ASC,PayUtcDate ASC'																						, N'PayId,GarnishmentId,GarnishmentTypeKey,GarnishmentAmount,GarnishmentLiabilityId'																												, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 1     						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearlyNoSlidingWindow'			, 'PayUtcDate'				)
		,(	N'PaymentReporting' , N'dbo'		, N'PayGarnishments'							, N'IDX_PayGarnishments_PayrollInstanceId'							, 0			, 0				, 0					, 0				, N'PayrollInstanceId ASC,PayUtcDate ASC'																				, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearlyNoSlidingWindow'			, 'PayUtcDate'				)
		,(	N'PaymentReporting' , N'dbo'		, N'PayGarnishments'							, N'PK_PayGarnishments'												, 1			, 1				, 0					, 1				, N'PayUtcDate ASC,GarnishmentId ASC'																					, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 1								, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearlyNoSlidingWindow'			, 'PayUtcDate'				)
		,(	N'PaymentReporting' , N'dbo'		, N'PayLiabilities'								, N'CDX_PayLiabilities'												, 0			, 0				, 0					, 1				, N'PayUtcDate ASC'																										, NULL																																																, 0			, NULL																, 80			, DEFAULT		, DEFAULT						, 1								, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psMonthly'						, 'PayUtcDate'				)
		,(	N'PaymentReporting' , N'dbo'		, N'PayLiabilities'								, N'PK_PayLiabilities'												, 1			, 1				, 0					, 0				, N'PayUtcDate ASC,PayId ASC,LiabilityId ASC,ActionId ASC'																, NULL																																																, 0			, NULL																, 80			, DEFAULT		, DEFAULT						, 1								, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psMonthly'						, 'PayUtcDate'				)
		,(	N'PaymentReporting' , N'dbo'		, N'PayLiabilities'								, N'IDX_PayLiabilities_LiabilityId'									, 0			, 0				, 0					, 0				, N'LiabilityId ASC,IsActive ASC,PayUtcDate ASC'																        , NULL																																																, 0			, NULL																, 80			, DEFAULT		, DEFAULT						, 1								, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psMonthly'						, 'PayUtcDate'				)
		,(	N'PaymentReporting' , N'dbo'		, N'PayrollInstances'							, N'PK_PayrollInstances'											, 1			, 1				, 0					, 1				, N'PayrollInstanceId ASC,TenantId ASC'																					, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'PayrollPayments'							, N'PK_PayrollPayments'												, 1			, 1				, 0					, 1				, N'PayrollPaymentId ASC'																								, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'PayrollUnits'								, N'IDX_PayrollUnits_PayGroup'										, 0			, 0				, 0					, 0				, N'PayGroup ASC,TenantId ASC'																							, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'PayrollUnits'								, N'IDX_PayrollUnits_PayrollCode'									, 0			, 0				, 0					, 0				, N'PayrollCode ASC'																									, N'PayrollId,TenantId'																																												, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'PayrollUnits'								, N'IDX_PayrollUnits_TenantId_PayrollCode'							, 0			, 0				, 0					, 0				, N'TenantId ASC,PayrollCode ASC'																						, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'PayrollUnits'								, N'PK_PayrollUnits'												, 1			, 1				, 0					, 1				, N'PayrollId ASC,TenantId ASC'																							, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'PayrollUnits'								, N'UQ_PayrollUnits'												, 1			, 0				, 0					, 0				, N'PayrollCode ASC,LegalEntityCompanyId ASC,TenantId ASC'																, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'Pays'										, N'CDX_Pays'														, 0			, 0				, 0					, 1				, N'PayUtcDate ASC'																										, NULL																																																, 0			, NULL																, 80			, DEFAULT		, DEFAULT						, 1								, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psMonthly'						, 'PayUtcDate'				)
		,(	N'PaymentReporting' , N'dbo'		, N'Pays'										, N'IDX_Pays_CheckSummaryReportCover'								, 0			, 0				, 0					, 0				, N'CompanyId ASC,TenantId ASC,PayId ASC,PayUtcDate ASC'																, N'EmployeeNumber'																																													, 0			, NULL																, 80			, DEFAULT		, DEFAULT						, 1								, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psMonthly'						, 'PayUtcDate'				)
		,(	N'PaymentReporting' , N'dbo'		, N'Pays'										, N'IDX_Pays_CDCover'												, 0			, 0				, 0					, 0				, N'NetPayLiabilityId ASC,PayUtcDate ASC'																				, N'EmployeeLastName,EmployeeFirstName,EmployeeNumber,CheckNumber,CheckAmount,ddAmount,PayrollId,PayrollInstanceId'																					, 0			, NULL																, 80			, DEFAULT		, DEFAULT						, 1								, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psMonthly'						, 'PayUtcDate'				)
		,(	N'PaymentReporting' , N'dbo'		, N'Pays'										, N'PK_Pays'														, 1			, 1				, 0					, 0				, N'PayId ASC,PayUtcDate ASC'																							, NULL																																																, 0			, NULL																, 80			, DEFAULT		, DEFAULT						, 1								, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psMonthly'						, 'PayUtcDate'				)
    --	(	DatabaseName        , SchemaName	,TableName									    ,IndexName												            ,IsUnique	 ,IsPrimaryKey	, IsUniqueConstraint, IsClustered	,KeyColumnList				                                                                                            ,IncludedColumnList	                                                                                                                                                                                ,IsFiltered ,FilterPredicate                                                    ,[Fillfactor]	,OptionPadIndex ,OptionStatisticsNoRecompute	,OptionStatisticsIncremental	,OptionIgnoreDupKey	,OptionResumable	,OptionMaxDuration	,OptionAllowRowLocks	,OptionAllowPageLocks	,OptionDataCompression	, NewStorage						, PartitionColumn			)		
		,(	N'PaymentReporting' , N'dbo'		, N'PayTaxes'									, N'CDX_PayTaxes'													, 0			, 0				, 0					, 1				, N'PayUtcDate ASC'																										, NULL																																																, 0			, NULL																, 80			, DEFAULT		, DEFAULT						, 1     						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psMonthly'						, 'PayUtcDate'				)
		,(	N'PaymentReporting' , N'dbo'		, N'PayTaxes'									, N'IDX_PayTaxes_IngestionCoverWithoutTenantId'						, 0			, 0				, 0					, 0				, N'PayId ASC,PayUtcDate ASC'																							, N'UltiTaxCode,DuplicatedLineNumber,ItemNo,TaxAmount,TaxYTDAmount,TaxableWages,TaxableGross,ExemptWages,GrossWages,TaxableTips,SuppTaxAmount,Version,CreatedUtcDt,UpdatedUtcDt'					, 0			, NULL																, 80			, DEFAULT		, DEFAULT						, 1     						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psMonthly'						, 'PayUtcDate'				)
		,(	N'PaymentReporting' , N'dbo'		, N'PayTaxes'									, N'PK_PayTaxes'													, 1			, 1				, 0					, 0				, N'PayUtcDate ASC,PayId ASC,UltiTaxCode ASC,DuplicatedLineNumber ASC'													, NULL																																																, 0			, NULL																, 80			, DEFAULT		, DEFAULT						, 1								, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psMonthly'						, 'PayUtcDate'				)
		,(	N'PaymentReporting' , N'dbo'		, N'States'										, N'PK_States'														, 1			, 1				, 0					, 1				, N'CountryCode ASC,StateCode ASC'																						, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'SystemSettings'								, N'PK_SystemSettings'												, 1			, 1				, 0					, 1				, N'SettingName ASC'																									, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'TaxAgency'									, N'PK_TaxAgency'													, 1			, 1				, 0					, 1				, N'TaxAgencyId ASC'																									, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'TaxAgency'									, N'UQ_TaxAgency'													, 1			, 0				, 0					, 0				, N'TaxAgencyCode ASC'																									, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'TaxAgencyTransactionAmounts'				, N'CDX_TaxAgencyTransactionAmounts'								, 0			, 0				, 0					, 1				, N'CheckDate ASC'																										, NULL																																																, 0			, NULL																, 90			, 1				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'TaxAgencyTransactionAmounts'				, N'PK_TaxAgencyTransactionAmounts'									, 1			, 1				, 0					, 0				, N'TransactionGUID ASC,TaxId ASC'																						, NULL																																																, 0			, NULL																, 90			, 1				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'TaxAgencyTransactions'						, N'IDX_TaxAgencyTransactions_CollectionDetailsCover'				, 0			, 0				, 0					, 0				, N'TaxAgencyId ASC,PostPayrollGUID ASC'																				, N'TransactionAmount,TransactionGUID,TransactionType'																																				, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'TaxAgencyTransactions'						, N'IDX_TaxAgencyTransactions_IngestionCover'						, 0			, 0				, 0					, 0				, N'TransactionGUID ASC,Version ASC'																					, N'TenantId'																																														, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'TaxAgencyTransactions'						, N'PK_TaxAgencyTransactions'										, 1			, 1				, 0					, 0				, N'TransactionGUID ASC'																					, NULL																																																			, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'TaxAgencyTransactions'						, N'IDX_TaxAgencyTransactions_CDVoidPaymentCover'					, 0			, 0				, 0					, 0				, N'TransactionType ASC,PaymentVoidLiabilityId ASC'																		, 'TaxAgencyId,TransactionAmount,PostPayrollId'																																						, 0			, NULL																, 90			, 1				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'TaxAgencyTransactions'						, N'IDX_TaxAgencyTransactions_TransactionType_CD'					, 0			, 0				, 0					, 0				, N'TransactionType ASC'																								, 'TenantId,TaxAgencyId,TransactionGUID,PostPayrollId'																																				, 0			, NULL																, 90			, 1				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'TaxAmounts'									, N'IDX_TaxAmounts_UltiTaxCode'										, 0			, 0				, 0					, 0				, N'UltiTaxCode ASC'																									, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'TaxAmounts'									, N'PK_TaxAmounts'													, 1			, 1				, 0					, 1				, N'TaxPayrollGUID ASC,UTETaxDataSourceTableSetKey ASC,TaxId ASC,TenantId ASC'											, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'TaxAmountsUltiTaxCodes'						, N'PK_TaxAmountsUltiTaxCodes'										, 1			, 1				, 0					, 1				, N'TaxPayrollGUID ASC,UTETaxDataSourceTableSetKey ASC,TaxId ASC,UltiTaxCode ASC'										, NULL																																																, 0			, NULL																, 90			, 0				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, N'PAGE'				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'TaxCodes'									, N'IDX_TaxCodes_CollectionDetailsCover'							, 0			, 0				, 0					, 0				, N'TaxAgencyId ASC'																									, N'TaxId,Description,UTETaxCode,TaxGUID,UltiproTaxCodeList,SortId'																																	, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'TaxCodes'									, N'PK_TaxCodes'													, 1			, 1				, 0					, 1				, N'TaxId ASC'																											, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'TaxCodes'									, N'UQ_TaxCodes'													, 1			, 0				, 0					, 0				, N'TaxGUID ASC'																										, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'TaxLiabilities'								, N'PK_TaxLiabilities'												, 1			, 1				, 0					, 1				, N'PayUtcDate ASC,TaxLiabilityId ASC'																					, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 1								, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearlyNoSlidingWindow'	        , 'PayUtcDate'				)
		,(	N'PaymentReporting' , N'dbo'		, N'TaxLiabilities'								, N'IDX_TaxLiabilities_CheckDateCover'								, 0			, 0				, 0					, 0				, N'TaxLiabilityOriginTypeKey ASC,LiabilityId ASC,PayUtcDate ASC'														, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, 1								, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'psYearlyNoSlidingWindow'	        , 'PayUtcDate'				)
		,(	N'PaymentReporting' , N'dbo'		, N'TaxPaymentCredits'							, N'IDX_TaxPaymentCredits_CollectionDetailsCover'					, 0			, 0				, 0					, 0				, N'LiabilityId ASC,TenantId ASC,CreditEffectOnLiabilityKey ASC,CreditAmountApplied ASC,TaxCreditId ASC'				, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'TaxPaymentCredits'							, N'IX_TaxPaymentCredits_ReducedQeAdjLiabilityPaymentId'			, 0			, 0				, 0					, 0				, N'ReducedQeAdjLiabilityPaymentId ASC'																					, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'TaxPaymentCredits'							, N'IX_TaxPaymentCredits_TaxCreditId'								, 0			, 0				, 0					, 0				, N'TaxCreditId ASC'																									, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'TaxPaymentCredits'							, N'IX_TaxPaymentCredits_TaxPaymentId'								, 0			, 0				, 0					, 0				, N'TaxPaymentId ASC'																									, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'TaxPaymentCredits'							, N'PK_TaxPaymentCredits'											, 1			, 1				, 0					, 1				, N'TaxPaymentCreditId ASC'																								, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'TaxPaymentCredits'							, N'UQ_TaxPaymentCredits'											, 1			, 0				, 0					, 0				, N'TenantId ASC,SessionId ASC,TaxPaymentId ASC,TaxCreditId ASC,ReducedQeAdjLiabilityPaymentId ASC'						, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)		
		,(	N'PaymentReporting' , N'dbo'		, N'TaxPayrolls'								, N'IDX_TaxPayrolls_CollectionDetailsCover'							, 0			, 0				, 0					, 0				, N'TenantId ASC,PostPayrollGUID ASC'																					, N'UTETaxDataSourceTableSetKey,ImportUtcDateTime,TaxPayrollGUID,PayrollId'																															, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'TaxPayrolls'								, N'IDX_TaxPayrolls_CollectionDetailsCover2'						, 0			, 0				, 0					, 0				, N'TenantId ASC,PostPayrollId ASC'																						, N'UTETaxDataSourceTableSetKey,ImportUtcDateTime,TaxPayrollGUID,PayrollId,PayUtcDate'																												, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'TaxPayrolls'								, N'PK_TaxPayrolls'													, 1			, 1				, 0					, 1				, N'TaxPayrollGUID ASC,UTETaxDataSourceTableSetKey ASC,TenantId ASC'													, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'TaxPayrolls'								, N'UQ_TaxPayrolls_PostPayrollGUID'									, 1			, 0				, 0					, 0				, N'PostPayrollGUID ASC'																								, NULL																																																, 1			, N'([PostPayrollGUID]<>''00000000-0000-0000-0000-000000000000'')'	, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'TaxPayrolls'								, N'UQ_TaxPayrolls_PostPayrollId'									, 1			, 0				, 0					, 0				, N'PostPayrollId ASC'																									, NULL																																																, 1			, N'([PostPayrollId]<>(0))'											, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'TaxPayrolls'								, N'UDX_TaxPayrolls_CollectionDetailsCover'							, 1			, 0				, 0					, 0				, N'PostPayrollGUID ASC'																								, N'UTETaxDataSourceTableSetKey,ImportUtcDateTime,TaxPayrollGUID,PayrollId,LiabilityId'																												, 1			, N'([PostPayrollGUID]<>''00000000-0000-0000-0000-000000000000'')'	, 90			, 1				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)

    --	(	DatabaseName        , SchemaName	,TableName									    ,IndexName												            ,IsUnique	 ,IsPrimaryKey	, IsUniqueConstraint, IsClustered	,KeyColumnList				                                                                                            ,IncludedColumnList	                                                                                                                                                                                ,IsFiltered ,FilterPredicate                                                    ,[Fillfactor]	,OptionPadIndex ,OptionStatisticsNoRecompute	,OptionStatisticsIncremental	,OptionIgnoreDupKey	,OptionResumable	,OptionMaxDuration	,OptionAllowRowLocks	,OptionAllowPageLocks	,OptionDataCompression	, NewStorage						, PartitionColumn			)		
		,(	N'PaymentReporting' , N'dbo'		, N'TaxSchedules'								, N'PK_TaxSchedules'										        , 1			 ,1 			, 0					, 1				, N'TaxScheduleGUID ASC'		                                                                                        ,NULL				                                                                                                                                                                                , 0			, NULL		  	                                                    , 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'TaxSchedules'								, N'UDX_TaxSchedules_TaxScheduleId'							        , 1			 ,0 			, 0					, 0				, N'TaxScheduleId ASC'			                                                                                        ,NULL				                                                                                                                                                                                , 0			, NULL		  	                                                    , 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)
		
		,(	N'PaymentReporting' , N'dbo'		, N'TenantProduct'								, N'PK_TenantProduct'												, 1			, 1				, 0					, 1				, N'TenantId ASC,ProductCodeKey ASC'																					, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'Tenants'									, N'PK_Tenants'														, 1			, 1				, 0					, 1				, N'TenantId ASC'																										, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'TenantStatus'								, N'PK_TenantStatus'												, 1			, 1				, 0					, 1				, N'TenantId ASC,TenantStatusCode ASC,EffectiveUtcDateFrom ASC,EffectiveUtcDateTo ASC'									, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'UltiProTaxCodeMapping'						, N'PK__UltiProTaxCodeMapping'										, 1			, 1				, 0					, 1				, N'UltiProTaxCodeMapId ASC'																							, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'UsgBankAccounts'							, N'PK_UsgBankAccounts'												, 1			, 1				, 0					, 1				, N'BankAccountId ASC'																									, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'ReportRequests'								, N'PK_ReportRequests'												, 1			, 1				, 0					, 1				, N'ReportRequestId ASC'																								, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'ReportParameters'							, N'PK_ReportParameters'											, 1			, 1				, 0					, 1				, N'ReportRequestId ASC,ParameterName ASC'																				, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'ReportFileInformation'						, N'PK_ReportFileInformation'										, 1			, 1				, 0					, 1				, N'ReportRequestId ASC'																								, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'ReportStatistics'							, N'PK_ReportStatistics'											, 1			, 1				, 0					, 1				, N'ReportRequestId ASC'																								, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'ReportObjectStoreInfo'						, N'PK_ReportObjectStoreInfo'										, 1			, 1				, 0					, 1				, N'ReportRequestId ASC'																								, NULL																																																, 0			, NULL																, 90			, DEFAULT		, DEFAULT						, DEFAULT						, DEFAULT			, DEFAULT			, DEFAULT			, DEFAULT				, DEFAULT				, DEFAULT				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'YEProcessing'								, N'PK_YEProcessing'												, 1			, 1				, 0					, 1				, N'YEProcessingId ASC'																									, NULL																																																, 0			, NULL																, 90			, 1				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'YEProcessing'								, N'UQ_YEProcessing'												, 1			, 0				, 0					, 0				, N'ClientId ASC,TaxYear ASC,TenantId ASC'																				, NULL																																																, 0			, NULL																, 90			, 1				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'YEProcessingFiles'							, N'PK_YEProcessingFiles'											, 1			, 1				, 0					, 1				, N'YEProcessingId ASC,InboundFileTypeKey ASC,UltiProAgency ASC'														, NULL																																																, 0			, NULL																, 90			, 1				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)
		,(	N'PaymentReporting' , N'dbo'		, N'YEProcessingFiles'							, N'UDX_YEProcessingFiles'											, 1			, 0				, 0					, 0				, N'YEProcessingId ASC,FileName ASC'																					, NULL																																																, 1			, N'([FileName]<>'''')'												, 90			, 1				, 0								, 0								, 0					, DEFAULT			, 0					, 1						, 1						, 'PAGE'				, 'PRIMARY'							, NULL						)	
    --	(	DatabaseName        , SchemaName	,TableName									    ,IndexName												            ,IsUnique	 ,IsPrimaryKey	, IsUniqueConstraint, IsClustered	,KeyColumnList				                                                                                            ,IncludedColumnList	                                                                                                                                                                                ,IsFiltered ,FilterPredicate                                                    ,[Fillfactor]	,OptionPadIndex ,OptionStatisticsNoRecompute	,OptionStatisticsIncremental	,OptionIgnoreDupKey	,OptionResumable	,OptionMaxDuration	,OptionAllowRowLocks	,OptionAllowPageLocks	,OptionDataCompression	, NewStorage						, PartitionColumn			)		
GO

DELETE DDI.IndexesColumnStore

INSERT DDI.[IndexesColumnStore] (
		DatabaseName        , [SchemaName]	, [TableName]				, [IndexName]									, [IsClustered]	, [ColumnList]																																																, [IsFiltered]	, [FilterPredicate]	, [OptionDataCompression]	, [OptionCompressionDelay]	, NewStorage				, PartitionColumn		) 
VALUES	
		(N'PaymentReporting', N'dbo'		, N'JournalEntries'			, N'NCCI_JournalEntries_LedgerBalanceReport'	, 0				, N'JournalEntryId,LiabilityId,TransactionType,Amount,TenantId,AccountId,AccountNumber,TransactionUtcDt,GLSegment,TenantAlias,CompanyId,CompanyCode,PayrollId,PayGroup,ProductCode,StateCode,AgencyCode'	, 0				, NULL				, N'COLUMNSTORE'			, 0							, 'psMonthly'				, 'TransactionUtcDt'	),
        (N'PaymentReporting', N'dbo'		, N'Liabilities'			, N'NCCI_Liabilities_CheckDateCover'	        , 0				, N'CollectionId,PayDate'	                                                                                                                                                                                , 0				, NULL				, N'COLUMNSTORE'			, 0							, 'psYearly'			    , 'PayDate'             ),
        (N'PaymentReporting', N'dbo'		, N'TaxAgencyTransactions'	, N'NCCI_TaxAgencyTransactions_PaymentsCount'	, 0				, N'TaxAgencyId,PostPayrollGUID'																																											, 0				, NULL				, N'COLUMNSTORE'			, 0							, 'PRIMARY'					, NULL					),
		(N'PaymentReporting', N'dbo'		, N'TaxAmounts'				, N'NCCI_TaxAmounts_SumByPayroll'				, 0				, N'TenantId,TaxPayrollGUID,UTETaxDataSourceTableSetKey,CurrentAmount'																																		, 0				, NULL				, N'COLUMNSTORE'			, 0							, 'PRIMARY'					, NULL					),
		(N'PaymentReporting', N'dbo'		, N'TaxPayrolls'			, N'NCCI_TaxPayrolls_CheckDateCover'	        , 0				, N'LiabilityId,PayUtcDate'	                                                                                                                                                                                , 0				, NULL				, N'COLUMNSTORE'			, 0							, 'PRIMARY'				    , NULL	                )

GO

--EXEC Utility.spForeignKeysAdd
--    @ForMetadataTablesOnly = 1,
--	@ParentSchemaName	= 'Utility',
--	@ParentTableName	= 'IndexesRowStore',
--    @UseExistenceCheck  = 1
--GO

--EXEC Utility.spForeignKeysAdd
--    @ForMetadataTablesOnly = 1,
--	@ParentSchemaName	= 'Utility',
--	@ParentTableName	= 'IndexesColumnStore',
--    @UseExistenceCheck  = 1
--GO

--EXEC Utility.spForeignKeysAdd
--    @ForMetadataTablesOnly = 1,
--    @ReferencedSchemaName = 'Utility',
--    @ReferencedTableName = 'IndexesRowStore',
--    @UseExistenceCheck  = 1

--GO
--EXEC Utility.spForeignKeysAdd
--    @ForMetadataTablesOnly = 1,
--    @ReferencedSchemaName = 'Utility',
--    @ReferencedTableName = 'IndexesColumnStore',
--    @UseExistenceCheck  = 1

GO

--TRY NOT TO USE THESE PARTITIONS TABLES...USE THE FANOUT INSTEAD TO GET THE PARTITION NUMBERS....
--DROP TABLE IF EXISTS DDI.IndexRowStorePartitions
--GO

--CREATE TABLE DDI.IndexRowStorePartitions (
--        DatabaseName    			NVARCHAR(128) NOT NULL,
--		SchemaName					NVARCHAR(128) NOT NULL,
--		TableName					NVARCHAR(128) NOT NULL,
--		IndexName					NVARCHAR(128) NOT NULL,
--		PartitionNumber				SMALLINT NOT NULL,
--		OptionResumable				BIT NOT NULL
--			CONSTRAINT Def_IndexRowStorePartitions_OptionResumable
--				DEFAULT(0),
--		OptionMaxDuration			SMALLINT NOT NULL
--			CONSTRAINT Def_IndexRowStorePartitions_OptionMaxDuration
--				DEFAULT(0),
--		OptionDataCompression		NVARCHAR(60) NOT NULL
--			CONSTRAINT Chk_IndexRowStorePartitions_OptionDataCompression
--				CHECK (OptionDataCompression IN ('NONE', 'ROW', 'PAGE'))
--			CONSTRAINT Def_IndexRowStorePartitions_OptionDataCompression
--				DEFAULT('PAGE'),

--		CONSTRAINT PK_IndexRowStorePartitions
--			PRIMARY KEY NONCLUSTERED (DatabaseName, SchemaName, TableName, IndexName, PartitionNumber))

--    WITH (MEMORY_OPTIMIZED = ON)
--GO

--DROP TABLE IF EXISTS DDI.IndexColumnStorePartitions
--GO

--CREATE TABLE DDI.IndexColumnStorePartitions (
--        DatabaseName    			NVARCHAR(128) NOT NULL,
--		SchemaName					NVARCHAR(128) NOT NULL,
--		TableName					NVARCHAR(128) NOT NULL,
--		IndexName					NVARCHAR(128) NOT NULL,
--		PartitionNumber				SMALLINT NOT NULL,
--		OptionDataCompression		NVARCHAR(60) NOT NULL --solves collation conflict with sys.partitions column.
--			CONSTRAINT Chk_IndexColumnStorePartitions_OptionDataCompression
--				CHECK (OptionDataCompression IN ('COLUMNSTORE', 'COLUMNSTORE_ARCHIVE'))
--			CONSTRAINT Def_IndexColumnStorePartitions_OptionDataCompression
--				DEFAULT('COLUMNSTORE'),

--		CONSTRAINT PK_IndexColumnStorePartitions
--			PRIMARY KEY NONCLUSTERED (DatabaseName, SchemaName, TableName, IndexName, PartitionNumber))

--    WITH (MEMORY_OPTIMIZED = ON)
--GO
