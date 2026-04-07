using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BarberBooking.API.Migrations
{
    /// <summary>
    /// Идемпотентно создаёт TemplateDays, если таблицы нет, а WeeklyTemplates есть
    /// (например, после ручного дропа или когда Add MasterServices уже в истории, но SQL не выполнялся).
    /// </summary>
    public partial class EnsureTemplateDaysTable : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                IF OBJECT_ID(N'[dbo].[TemplateDays]', N'U') IS NULL
                   AND OBJECT_ID(N'[dbo].[WeeklyTemplates]', N'U') IS NOT NULL
                BEGIN
                    CREATE TABLE [dbo].[TemplateDays] (
                        [Id] UNIQUEIDENTIFIER NOT NULL,
                        [TemplateId] UNIQUEIDENTIFIER NOT NULL,
                        [DayOfWeek] INT NOT NULL,
                        [WorkStartTime] TIME NOT NULL,
                        [WorkEndTime] TIME NOT NULL,
                        CONSTRAINT [PK_TemplateDays] PRIMARY KEY ([Id]),
                        CONSTRAINT [FK_TemplateDays_WeeklyTemplates_TemplateId]
                            FOREIGN KEY ([TemplateId]) REFERENCES [dbo].[WeeklyTemplates]([Id]) ON DELETE CASCADE
                    );
                    CREATE UNIQUE INDEX [IX_TemplateDays_TemplateId_DayOfWeek]
                        ON [dbo].[TemplateDays]([TemplateId], [DayOfWeek]);
                END
                """);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                IF OBJECT_ID(N'[dbo].[TemplateDays]', N'U') IS NOT NULL
                    DROP TABLE [dbo].[TemplateDays];
                """);
        }
    }
}
