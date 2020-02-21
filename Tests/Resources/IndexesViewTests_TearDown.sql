USE DDI


DELETE DDI.DefaultConstraints			WHERE DatabaseName = 'PaymentReporting' AND TableName				IN ('TempA','TempB','AAA_SpaceError')
DELETE DDI.[Statistics]					WHERE DatabaseName = 'PaymentReporting' AND TableName				IN ('TempA','TempB','AAA_SpaceError')
DELETE DDI.IndexesColumnStore			WHERE DatabaseName = 'PaymentReporting' AND TableName				IN ('TempA','TempB','AAA_SpaceError')
DELETE DDI.IndexesRowStore				WHERE DatabaseName = 'PaymentReporting' AND TableName				IN ('TempA','TempB','AAA_SpaceError')
DELETE DDI.ForeignKeys					WHERE DatabaseName = 'PaymentReporting' AND ReferencedTableName		IN ('TempA','TempB','AAA_SpaceError')
DELETE DDI.Tables						WHERE DatabaseName = 'PaymentReporting' AND TableName				IN ('TempA','TempB','AAA_SpaceError')
DELETE DDI.Log							WHERE DatabaseName = 'PaymentReporting' AND TableName				IN ('TempA','TempB','AAA_SpaceError')


USE PaymentReporting


DROP TABLE IF EXISTS dbo.TempB
DROP TABLE IF EXISTS dbo.TempA
DROP TABLE IF EXISTS dbo.AAA_SpaceError

