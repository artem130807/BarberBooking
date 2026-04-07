using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BarberBooking.API.Migrations
{
    public partial class CreateMasterStatisticIfMissing : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                IF OBJECT_ID(N'[dbo].[MasterStatistic]', N'U') IS NULL
                BEGIN
                    CREATE TABLE [dbo].[MasterStatistic] (
                        [Id] uniqueidentifier NOT NULL,
                        [MasterProfileId] uniqueidentifier NOT NULL,
                        [Rating] decimal(18,2) NOT NULL,
                        [RatingCount] int NOT NULL,
                        [CompletedAppointmentsCount] int NOT NULL,
                        [CancelledAppointmentsCount] int NOT NULL,
                        [SumPrice] float NOT NULL,
                        [CreatedAt] datetime2 NOT NULL,
                        CONSTRAINT [PK_MasterStatistic] PRIMARY KEY ([Id]),
                        CONSTRAINT [FK_MasterStatistic_MasterProfiles_MasterProfileId] FOREIGN KEY ([MasterProfileId]) REFERENCES [dbo].[MasterProfiles] ([Id]) ON DELETE CASCADE
                    );
                    CREATE INDEX [IX_MasterStatistic_MasterProfileId] ON [dbo].[MasterStatistic] ([MasterProfileId]);
                END
                """);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                IF OBJECT_ID(N'[dbo].[MasterStatistic]', N'U') IS NOT NULL
                    DROP TABLE [dbo].[MasterStatistic];
                """);
        }
    }
}
