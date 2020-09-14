USE DOI


DELETE DOI.DefaultConstraints			WHERE DatabaseName = 'DOIUnitTests' AND TableName				IN ('TempA','TempB','AAA_SpaceError')
DELETE DOI.[Statistics]					WHERE DatabaseName = 'DOIUnitTests' AND TableName				IN ('TempA','TempB','AAA_SpaceError')
DELETE DOI.IndexesColumnStore			WHERE DatabaseName = 'DOIUnitTests' AND TableName				IN ('TempA','TempB','AAA_SpaceError')
DELETE DOI.IndexesRowStore				WHERE DatabaseName = 'DOIUnitTests' AND TableName				IN ('TempA','TempB','AAA_SpaceError')
DELETE DOI.ForeignKeys					WHERE DatabaseName = 'DOIUnitTests' AND ReferencedTableName		IN ('TempA','TempB','AAA_SpaceError')
DELETE DOI.Tables						WHERE DatabaseName = 'DOIUnitTests' AND TableName				IN ('TempA','TempB','AAA_SpaceError')
DELETE DOI.Log							WHERE DatabaseName = 'DOIUnitTests' AND TableName				IN ('TempA','TempB','AAA_SpaceError')
DELETE DOI.Databases					WHERE DatabaseName = 'DOIUnitTests' 

USE DOIUnitTests

DROP TABLE IF EXISTS dbo.TempA
DROP TABLE IF EXISTS dbo.TempB
DROP TABLE IF EXISTS dbo.AAA_SpaceError
