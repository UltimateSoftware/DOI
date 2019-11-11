IF OBJECT_ID('[DDI].[spRun_GetApplicationLock]') IS NOT NULL
	DROP PROCEDURE [DDI].[spRun_GetApplicationLock];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [DDI].[spRun_GetApplicationLock]

AS

/*
	EXEC DDI.spRun_GetApplicationLock
*/

DECLARE @RC INT

EXEC @RC = sp_getapplock 
	@DbPrincipal	= 'dbo',
	@Resource		= 'DDI', 
	@LockMode		= 'Exclusive', 
	@LockOwner		= 'Session', 
	@LockTimeout	= 15000

IF @RC < 0 
BEGIN
	RAISERROR('Could not obtain the Application lock', 16, 1)
END


GO
