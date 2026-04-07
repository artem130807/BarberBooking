using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BarberBooking.API.Migrations
{
    /// <inheritdoc />
    public partial class MasterStatstic : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "MasterStatistic",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    MasterProfileId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Rating = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    RatingCount = table.Column<int>(type: "int", nullable: false),
                    CompletedAppointmentsCount = table.Column<int>(type: "int", nullable: false),
                    CancelledAppointmentsCount = table.Column<int>(type: "int", nullable: false),
                    SumPrice = table.Column<double>(type: "float", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MasterStatistic", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MasterStatistic_MasterProfiles_MasterProfileId",
                        column: x => x.MasterProfileId,
                        principalTable: "MasterProfiles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_MasterStatistic_MasterProfileId",
                table: "MasterStatistic",
                column: "MasterProfileId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "MasterStatistic");
        }
    }
}
