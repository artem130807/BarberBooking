using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BarberBooking.API.Migrations
{
    /// <inheritdoc />
    public partial class AddMasterServices : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // WeeklyTemplates: таблицы может не быть (дроп вручную) — тогда CREATE; если есть старая схема — миграция без MasterProfileId1 (как в текущей модели).
            migrationBuilder.Sql(@"
IF OBJECT_ID(N'dbo.WeeklyTemplates', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[WeeklyTemplates] (
        [Id] UNIQUEIDENTIFIER NOT NULL,
        [MasterProfileId] UNIQUEIDENTIFIER NOT NULL,
        [Name] NVARCHAR(200) NOT NULL,
        [IsActive] BIT NOT NULL,
        [CreatedAt] DATETIME2 NOT NULL,
        CONSTRAINT [PK_WeeklyTemplates] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_WeeklyTemplates_MasterProfiles_MasterProfileId] FOREIGN KEY ([MasterProfileId]) REFERENCES [dbo].[MasterProfiles]([Id]) ON DELETE CASCADE
    );
    CREATE INDEX [IX_WeeklyTemplates_MasterProfileId] ON [dbo].[WeeklyTemplates]([MasterProfileId]);
END
ELSE IF COL_LENGTH(N'dbo.WeeklyTemplates', N'MasterId') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_WeeklyTemplates_MasterProfiles_MasterId' AND parent_object_id = OBJECT_ID(N'dbo.WeeklyTemplates'))
        ALTER TABLE [dbo].[WeeklyTemplates] DROP CONSTRAINT [FK_WeeklyTemplates_MasterProfiles_MasterId];
    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_WeeklyTemplates_MasterProfiles_MasterProfileId' AND parent_object_id = OBJECT_ID(N'dbo.WeeklyTemplates'))
        ALTER TABLE [dbo].[WeeklyTemplates] DROP CONSTRAINT [FK_WeeklyTemplates_MasterProfiles_MasterProfileId];
    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_WeeklyTemplates_MasterProfiles_MasterProfileId1' AND parent_object_id = OBJECT_ID(N'dbo.WeeklyTemplates'))
        ALTER TABLE [dbo].[WeeklyTemplates] DROP CONSTRAINT [FK_WeeklyTemplates_MasterProfiles_MasterProfileId1];
    IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_WeeklyTemplates_MasterId' AND object_id = OBJECT_ID(N'dbo.WeeklyTemplates'))
        DROP INDEX [IX_WeeklyTemplates_MasterId] ON [dbo].[WeeklyTemplates];
    IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_WeeklyTemplates_MasterProfileId1' AND object_id = OBJECT_ID(N'dbo.WeeklyTemplates'))
        DROP INDEX [IX_WeeklyTemplates_MasterProfileId1] ON [dbo].[WeeklyTemplates];
    ALTER TABLE [dbo].[WeeklyTemplates] DROP COLUMN [MasterId];
    IF COL_LENGTH(N'dbo.WeeklyTemplates', N'MasterProfileId1') IS NOT NULL
        ALTER TABLE [dbo].[WeeklyTemplates] DROP COLUMN [MasterProfileId1];
    ALTER TABLE [dbo].[WeeklyTemplates] ALTER COLUMN [MasterProfileId] UNIQUEIDENTIFIER NOT NULL;
    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_WeeklyTemplates_MasterProfiles_MasterProfileId' AND parent_object_id = OBJECT_ID(N'dbo.WeeklyTemplates'))
        ALTER TABLE [dbo].[WeeklyTemplates] ADD CONSTRAINT [FK_WeeklyTemplates_MasterProfiles_MasterProfileId] FOREIGN KEY ([MasterProfileId]) REFERENCES [dbo].[MasterProfiles]([Id]) ON DELETE CASCADE;
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_WeeklyTemplates_MasterProfileId' AND object_id = OBJECT_ID(N'dbo.WeeklyTemplates'))
        CREATE INDEX [IX_WeeklyTemplates_MasterProfileId] ON [dbo].[WeeklyTemplates]([MasterProfileId]);
END
");

            // TemplateDays: если WeeklyTemplates уже есть, а дочерняя таблица отсутствует — создаём (как в RecreateWeeklyTemplateTables.sql).
            migrationBuilder.Sql(@"
IF OBJECT_ID(N'dbo.TemplateDays', N'U') IS NULL AND OBJECT_ID(N'dbo.WeeklyTemplates', N'U') IS NOT NULL
BEGIN
    CREATE TABLE [dbo].[TemplateDays] (
        [Id] UNIQUEIDENTIFIER NOT NULL,
        [TemplateId] UNIQUEIDENTIFIER NOT NULL,
        [DayOfWeek] INT NOT NULL,
        [WorkStartTime] TIME NOT NULL,
        [WorkEndTime] TIME NOT NULL,
        CONSTRAINT [PK_TemplateDays] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_TemplateDays_WeeklyTemplates_TemplateId] FOREIGN KEY ([TemplateId]) REFERENCES [dbo].[WeeklyTemplates]([Id]) ON DELETE CASCADE
    );
    CREATE UNIQUE INDEX [IX_TemplateDays_TemplateId_DayOfWeek] ON [dbo].[TemplateDays]([TemplateId], [DayOfWeek]);
END
");

            migrationBuilder.Sql(@"
IF OBJECT_ID(N'dbo.MasterServices', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[MasterServices] (
        [Id] UNIQUEIDENTIFIER NOT NULL,
        [MasterProfileId] UNIQUEIDENTIFIER NOT NULL,
        [ServiceId] UNIQUEIDENTIFIER NOT NULL,
        CONSTRAINT [PK_MasterServices] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_MasterServices_MasterProfiles_MasterProfileId] FOREIGN KEY ([MasterProfileId]) REFERENCES [dbo].[MasterProfiles]([Id]) ON DELETE CASCADE,
        CONSTRAINT [FK_MasterServices_Services_ServiceId] FOREIGN KEY ([ServiceId]) REFERENCES [dbo].[Services]([Id]) ON DELETE CASCADE
    );
    CREATE INDEX [IX_MasterServices_MasterProfileId] ON [dbo].[MasterServices]([MasterProfileId]);
    CREATE INDEX [IX_MasterServices_ServiceId] ON [dbo].[MasterServices]([ServiceId]);
END
");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"
IF OBJECT_ID(N'dbo.MasterServices', N'U') IS NOT NULL
    DROP TABLE [dbo].[MasterServices];
");

            migrationBuilder.Sql(@"
IF OBJECT_ID(N'dbo.TemplateDays', N'U') IS NOT NULL
    DROP TABLE [dbo].[TemplateDays];
");

            migrationBuilder.Sql(@"
IF OBJECT_ID(N'dbo.WeeklyTemplates', N'U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_WeeklyTemplates_MasterProfiles_MasterProfileId' AND parent_object_id = OBJECT_ID(N'dbo.WeeklyTemplates'))
        ALTER TABLE [dbo].[WeeklyTemplates] DROP CONSTRAINT [FK_WeeklyTemplates_MasterProfiles_MasterProfileId];
    IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_WeeklyTemplates_MasterProfileId' AND object_id = OBJECT_ID(N'dbo.WeeklyTemplates'))
        DROP INDEX [IX_WeeklyTemplates_MasterProfileId] ON [dbo].[WeeklyTemplates];
    ALTER TABLE [dbo].[WeeklyTemplates] ADD [MasterId] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_WeeklyTemplates_MasterId] DEFAULT ('00000000-0000-0000-0000-000000000000');
    ALTER TABLE [dbo].[WeeklyTemplates] ALTER COLUMN [MasterProfileId] UNIQUEIDENTIFIER NULL;
    CREATE INDEX [IX_WeeklyTemplates_MasterId] ON [dbo].[WeeklyTemplates]([MasterId]);
    ALTER TABLE [dbo].[WeeklyTemplates] ADD CONSTRAINT [FK_WeeklyTemplates_MasterProfiles_MasterId] FOREIGN KEY ([MasterId]) REFERENCES [dbo].[MasterProfiles]([Id]) ON DELETE CASCADE;
    ALTER TABLE [dbo].[WeeklyTemplates] ADD CONSTRAINT [FK_WeeklyTemplates_MasterProfiles_MasterProfileId] FOREIGN KEY ([MasterProfileId]) REFERENCES [dbo].[MasterProfiles]([Id]);
END
");
        }
    }
}
