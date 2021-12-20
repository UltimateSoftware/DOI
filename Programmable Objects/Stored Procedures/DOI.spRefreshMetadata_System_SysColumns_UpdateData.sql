-- <Migration ID="b101365d-8c13-44f3-9d8d-9ee521ec152e" />
GO
-- WARNING: this script could not be parsed using the Microsoft.TrasactSql.ScriptDOM parser and could not be made rerunnable. You may be able to make this change manually by editing the script by surrounding it in the following sql and applying it or marking it as applied!


IF OBJECT_ID('[DOI].[spRefreshMetadata_System_SysColumns_UpdateData]') IS NOT NULL
	DROP PROCEDURE [DOI].[spRefreshMetadata_System_SysColumns_UpdateData];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [DOI].[spRefreshMetadata_System_SysColumns_UpdateData]
    @DatabaseName NVARCHAR(128) = NULL

AS

/*
    EXEC [DOI].[spRefreshMetadata_System_SysColumns_UpdateData]
        @DatabaseName = 'DOIUnitTests'
*/


UPDATE C
SET is_identity = CASE WHEN ic.column_id IS NULL THEN 0 ELSE 1 END,
    identity_seed_value = CASE WHEN ic.column_id IS NULL THEN NULL ELSE ic.seed_value end,
    identity_incr_value = CASE WHEN ic.column_id IS NULL THEN NULL ELSE ic.increment_value end
from DOI.SysColumns C 
	INNER JOIN DOI.SysDatabases d ON d.database_id = c.database_id
    LEFT JOIN DOI.SysIdentityColumns IC ON C.database_id = IC.database_id
        AND C.object_id = IC.object_id
        AND C.column_id = IC.column_id
WHERE d.name = CASE WHEN @DatabaseName IS NULL THEN D.name ELSE @DatabaseName END


GO