IF OBJECT_ID('[DDI].[spRun_ReleaseApplicationLock]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRun_ReleaseApplicationLock];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DDI].[spRun_ReleaseApplicationLock]

AS

/*
	EXEC DDI.spRun_ReleaseApplicationLock
*/

IF EXISTS(	SELECT 'True'
			FROM   sys.dm_tran_locks
			WHERE  resource_type = 'APPLICATION'
				AND request_mode = 'X'
				AND request_status = 'GRANT'
				AND resource_description LIKE '%:\[DDI\]:%' ESCAPE '\')
BEGIN
	DECLARE @RC INT 

	EXEC @RC = sp_releaseapplock 
		@DbPrincipal= 'dbo',
		@Resource	= 'DDI', 
		@LockOwner	= 'Session'

	IF @RC < 0
	BEGIN
		RAISERROR('Unable to release Application Lock', 16, 1)
	END
END


GO
