IF (SELECT is_query_store_on FROM SYS.databases WHERE NAME = 'DOI') <> 1
BEGIN
	ALTER DATABASE [$(DatabaseName)] SET QUERY_STORE = ON;

	PRINT 'Set DOI QUERY_STORE to ON.'
END
GO


IF EXISTS(	SELECT 'True'
			FROM sys.database_query_store_options 
			WHERE actual_state_desc <> 'READ_WRITE'
				OR max_storage_size_mb <> 10000
				OR query_capture_mode_desc <> 'ALL'
				OR size_based_cleanup_mode_desc <> 'AUTO'
				OR STALE_QUERY_THRESHOLD_DAYS <> 120)
BEGIN
	ALTER DATABASE [$(DatabaseName)] SET QUERY_STORE
		(
			OPERATION_MODE = READ_WRITE,
			MAX_STORAGE_SIZE_MB = 10000,
			QUERY_CAPTURE_MODE = ALL,
			SIZE_BASED_CLEANUP_MODE = AUTO,
			CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 120)
		);

	PRINT 'Fixed QUERY_STORE settings.'
END		
GO