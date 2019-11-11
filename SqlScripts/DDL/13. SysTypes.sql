USE DDI
GO

DROP TABLE IF EXISTS DDI.SysTypes
GO

CREATE TABLE DDI.SysTypes(
    name	sysname,
    system_type_id	tinyint NOT NULL,
    user_type_id	int NOT NULL,
    schema_id	int NOT NULL,
    principal_id	int NULL,
    max_length	smallint NOT NULL,
    precision	tinyint NOT NULL,
    scale	tinyint NOT NULL,
    collation_name	NVARCHAR(128) NULL,
    is_nullable	bit NULL,
    is_user_defined	bit NOT NULL,
    is_assembly_type	bit NOT NULL,
    default_object_id	int NOT NULL,
    rule_object_id	int NOT NULL,
    is_table_type	bit NOT NULL

    CONSTRAINT PK_SysTypes
        PRIMARY KEY NONCLUSTERED (user_type_id)
)
WITH (MEMORY_OPTIMIZED = ON)

SELECT *
INTO #SysTypes
FROM PaymentReporting.sys.types

INSERT INTO DDI.SysTypes
SELECT * FROM #SysTypes

DROP TABLE #SysTypes
GO
