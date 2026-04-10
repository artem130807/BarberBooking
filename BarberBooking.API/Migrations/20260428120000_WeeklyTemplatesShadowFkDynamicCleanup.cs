using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BarberBooking.API.Migrations
{
    /// <summary>
    /// Дополняет 20260420120000: удаляет теневой столбец MasterProfileId1 даже если имя FK/индекса
    /// не совпало с шаблоном FK_WeeklyTemplates_MasterProfiles_MasterProfileId1 (на части серверов SQL
    /// давал другие имена при дублирующей связи).
    /// </summary>
    public partial class WeeklyTemplatesShadowFkDynamicCleanup : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"
IF OBJECT_ID(N'dbo.WeeklyTemplates', N'U') IS NULL RETURN;
IF COL_LENGTH(N'dbo.WeeklyTemplates', N'MasterProfileId1') IS NULL RETURN;

DECLARE @dropFk nvarchar(max) = N'';
SELECT @dropFk += N'ALTER TABLE dbo.WeeklyTemplates DROP CONSTRAINT ' + QUOTENAME(fk.name) + N';'
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
INNER JOIN sys.columns c ON fkc.parent_object_id = c.object_id AND fkc.parent_column_id = c.column_id
WHERE fk.parent_object_id = OBJECT_ID(N'dbo.WeeklyTemplates')
  AND c.name = N'MasterProfileId1';
IF @dropFk <> N'' EXEC sp_executesql @dropFk;

DECLARE @dropIx nvarchar(max) = N'';
SELECT @dropIx += N'DROP INDEX ' + QUOTENAME(i.name) + N' ON dbo.WeeklyTemplates;'
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID(N'dbo.WeeklyTemplates')
  AND c.name = N'MasterProfileId1'
  AND i.is_hypothetical = 0
  AND i.is_primary_key = 0;
IF @dropIx <> N'' EXEC sp_executesql @dropIx;

ALTER TABLE dbo.WeeklyTemplates DROP COLUMN MasterProfileId1;
");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
        }
    }
}
