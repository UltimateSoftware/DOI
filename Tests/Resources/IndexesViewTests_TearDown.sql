DROP TABLE IF EXISTS dbo.TempB
DROP TABLE IF EXISTS dbo.TempA
DROP TABLE IF EXISTS dbo.AAA_SpaceError

DELETE Utility.DefaultConstraints			WHERE TableName				IN ('TempA','TempB','AAA_SpaceError')
DELETE Utility.[Statistics]					WHERE TableName				IN ('TempA','TempB','AAA_SpaceError')
DELETE Utility.IndexesColumnStore			WHERE TableName				IN ('TempA','TempB','AAA_SpaceError')
DELETE Utility.IndexesRowStore				WHERE TableName				IN ('TempA','TempB','AAA_SpaceError')
DELETE Utility.ForeignKeys					WHERE ReferencedTableName	IN ('TempA','TempB','AAA_SpaceError')
DELETE Utility.Tables						WHERE TableName				IN ('TempA','TempB','AAA_SpaceError')
DELETE Utility.RefreshIndexStructuresLog	WHERE TableName				IN ('TempA','TempB','AAA_SpaceError')
