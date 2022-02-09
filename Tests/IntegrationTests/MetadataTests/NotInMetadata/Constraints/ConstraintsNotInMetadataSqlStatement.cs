
namespace DOI.Tests.IntegrationTests.MetadataTests.NotInMetadata.Constraints
{
    public static class ConstraintsNotInMetadataSqlStatement
    {
        private const string DatabaseName = "DOIUnitTests";

        public static string DoesCheckConstraintExistInNotInMetadataTableSql =
            $@"IF EXISTS(SELECT 'True' FROM DOI.CheckConstraintsNotInMetadata WHERE DatabaseName = '{DatabaseName}' AND SchemaName = 'dbo' AND TableName = 'TempA' AND CheckConstraintName = 'Chk_TempA_TransactionUtcDt')
                BEGIN
                    SELECT CAST(1 AS BIT)
                END
                ELSE
                BEGIN
                    SELECT CAST(0 AS BIT)
                END";

        public static string DoesDefaultConstraintExistInNotInMetadataTableSql =
            $@"IF EXISTS(SELECT 'True' FROM DOI.DefaultConstraintsNotInMetadata WHERE DatabaseName = '{DatabaseName}' AND SchemaName = 'dbo' AND TableName = 'TempA' AND DefaultConstraintName = 'Def_TempA_UpdatedUtcDt')
                BEGIN
                    SELECT CAST(1 AS BIT)
                END
                ELSE
                BEGIN
                    SELECT CAST(0 AS BIT)
                END";


        public static string DropCheckConstraint =
            @"ALTER TABLE dbo.TempA DROP CONSTRAINT Chk_TempA_TransactionUtcDt";

        public static string DropDefaultConstraint =
            @"ALTER TABLE dbo.TempA DROP CONSTRAINT Def_TempA_UpdatedUtcDt";
    }
}
