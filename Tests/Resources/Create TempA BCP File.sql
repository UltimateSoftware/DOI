USE DOIUnitTests
GO

DROP TABLE IF EXISTS dbo.TempA

CREATE TABLE dbo.TempA(
	TempAId uniqueidentifier NOT NULL,
	TransactionUtcDt datetime2(7) NOT NULL,
	IncludedColumn VARCHAR(100) NULL,
	TextCol VARCHAR(8000) NULL,
    UpdatedUtcDt DATETIME2 NOT NULL 
)

INSERT INTO dbo.TempA(    TempAId,    TransactionUtcDt,    IncludedColumn,    TextCol, UpdatedUtcDt)
SELECT TOP 150000 NEWID(), SYSDATETIME(), o1.name, o2.name, SYSDATETIME()
FROM sys.objects o1
    CROSS JOIN sys.objects o2
    CROSS JOIN sys.objects o3


/*
AFTER RUNNING ABOVE SCRIPT, RUN THIS BCP COMMAND:

bcp DOIUnitTests.dbo.TempA out c:\Projects\DOI\Tests\Resources\dbo.TempA.bcp -n -T
bcp DOIUnitTests.dbo.TempA format nul -f c:\Projects\DOI\Tests\Resources\dbo.TempA_format.fmt -c -T 


*/