using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BarberBooking.API.Migrations
{
    public partial class WeeklyTemplatesCleanupShadowFk : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"
IF OBJECT_ID(N'dbo.WeeklyTemplates', N'U') IS NULL RETURN;

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_WeeklyTemplates_MasterProfiles_MasterProfileId1' AND parent_object_id = OBJECT_ID(N'dbo.WeeklyTemplates'))
    ALTER TABLE [dbo].[WeeklyTemplates] DROP CONSTRAINT [FK_WeeklyTemplates_MasterProfiles_MasterProfileId1];

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_WeeklyTemplates_MasterProfiles_MasterProfileId2' AND parent_object_id = OBJECT_ID(N'dbo.WeeklyTemplates'))
    ALTER TABLE [dbo].[WeeklyTemplates] DROP CONSTRAINT [FK_WeeklyTemplates_MasterProfiles_MasterProfileId2];

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_WeeklyTemplates_MasterProfileId1' AND object_id = OBJECT_ID(N'dbo.WeeklyTemplates'))
    DROP INDEX [IX_WeeklyTemplates_MasterProfileId1] ON [dbo].[WeeklyTemplates];

IF COL_LENGTH(N'dbo.WeeklyTemplates', N'MasterProfileId1') IS NOT NULL
    ALTER TABLE [dbo].[WeeklyTemplates] DROP COLUMN [MasterProfileId1];
");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
        }
    }
}
