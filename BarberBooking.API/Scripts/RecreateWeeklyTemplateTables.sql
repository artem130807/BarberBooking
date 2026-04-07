/*
  Пересоздание только таблиц WeeklyTemplates и TemplateDays (данные в них теряются).
  Остальные таблицы не трогаются. Выполнять в SQL Server Management Studio / Azure Data Studio
  против нужной базы.

  Порядок: сначала дочерняя TemplateDays, потом WeeklyTemplates.
*/

SET NOCOUNT ON;

/* 1. Дочерняя таблица */
IF OBJECT_ID(N'dbo.TemplateDays', N'U') IS NOT NULL
BEGIN
    PRINT N'DROP dbo.TemplateDays';
    DROP TABLE dbo.TemplateDays;
END;

/* 2. Родительская */
IF OBJECT_ID(N'dbo.WeeklyTemplates', N'U') IS NOT NULL
BEGIN
    PRINT N'DROP dbo.WeeklyTemplates';
    DROP TABLE dbo.WeeklyTemplates;
END;

/* 3. WeeklyTemplates — одна связь с MasterProfiles (MasterProfileId), без дублирующей колонки */
CREATE TABLE dbo.WeeklyTemplates (
    [Id]              UNIQUEIDENTIFIER NOT NULL,
    [MasterProfileId] UNIQUEIDENTIFIER NOT NULL,
    [Name]            NVARCHAR(200)    NOT NULL,
    [IsActive]        BIT              NOT NULL,
    [CreatedAt]       DATETIME2        NOT NULL,
    CONSTRAINT [PK_WeeklyTemplates] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_WeeklyTemplates_MasterProfiles_MasterProfileId]
        FOREIGN KEY ([MasterProfileId]) REFERENCES dbo.[MasterProfiles]([Id]) ON DELETE CASCADE
);

CREATE NONCLUSTERED INDEX [IX_WeeklyTemplates_MasterProfileId]
    ON dbo.[WeeklyTemplates]([MasterProfileId]);

/* 4. TemplateDays */
CREATE TABLE dbo.TemplateDays (
    [Id]            UNIQUEIDENTIFIER NOT NULL,
    [TemplateId]    UNIQUEIDENTIFIER NOT NULL,
    [DayOfWeek]     INT              NOT NULL,
    [WorkStartTime] TIME             NOT NULL,
    [WorkEndTime]   TIME             NOT NULL,
    CONSTRAINT [PK_TemplateDays] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_TemplateDays_WeeklyTemplates_TemplateId]
        FOREIGN KEY ([TemplateId]) REFERENCES dbo.[WeeklyTemplates]([Id]) ON DELETE CASCADE
);

CREATE UNIQUE NONCLUSTERED INDEX [IX_TemplateDays_TemplateId_DayOfWeek]
    ON dbo.[TemplateDays]([TemplateId], [DayOfWeek]);

PRINT N'WeeklyTemplates и TemplateDays созданы заново.';
