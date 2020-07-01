USE DOI


DELETE DOI.DefaultConstraints			WHERE DatabaseName = 'PaymentReporting' AND TableName				IN ('TempA','TempB','AAA_SpaceError')
DELETE DOI.[Statistics]					WHERE DatabaseName = 'PaymentReporting' AND TableName				IN ('TempA','TempB','AAA_SpaceError')
DELETE DOI.IndexesColumnStore			WHERE DatabaseName = 'PaymentReporting' AND TableName				IN ('TempA','TempB','AAA_SpaceError')
DELETE DOI.IndexesRowStore				WHERE DatabaseName = 'PaymentReporting' AND TableName				IN ('TempA','TempB','AAA_SpaceError')
DELETE DOI.ForeignKeys					WHERE DatabaseName = 'PaymentReporting' AND ReferencedTableName		IN ('TempA','TempB','AAA_SpaceError')
DELETE DOI.Tables						WHERE DatabaseName = 'PaymentReporting' AND TableName				IN ('TempA','TempB','AAA_SpaceError')
DELETE DOI.Log							WHERE DatabaseName = 'PaymentReporting' AND TableName				IN ('TempA','TempB','AAA_SpaceError')


USE PaymentReporting


DROP TABLE IF EXISTS dbo.TempB
DROP TABLE IF EXISTS dbo.TempA
DROP TABLE IF EXISTS dbo.AAA_SpaceError

