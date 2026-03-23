using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BarberBooking.API.Migrations
{
    /// <inheritdoc />
    public partial class UpdateStatisticSalon : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "AppointmentsCount",
                table: "SalonStatistic",
                newName: "CompletedAppointmentsCount");

            migrationBuilder.AddColumn<int>(
                name: "CancelledAppointmentsCount",
                table: "SalonStatistic",
                type: "int",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CancelledAppointmentsCount",
                table: "SalonStatistic");

            migrationBuilder.RenameColumn(
                name: "CompletedAppointmentsCount",
                table: "SalonStatistic",
                newName: "AppointmentsCount");
        }
    }
}
