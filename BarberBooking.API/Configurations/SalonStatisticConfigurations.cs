using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberBooking.API.Configurations
{
    public class SalonStatisticConfigurations : IEntityTypeConfiguration<SalonStatistic>
    {
        public void Configure(EntityTypeBuilder<SalonStatistic> builder)
        {
            builder.ToTable("SalonStatistic");
            builder.HasKey(x => x.Id);
            builder.Property(x => x.Rating);
            builder.Property(x => x.RatingCount);
            builder.Property(x => x.CompletedAppointmentsCount);
            builder.Property(x => x.CancelledAppointmentsCount);
            builder.Property(x => x.CreatedAt);
            builder.HasOne(x => x.Salon).WithMany(x => x.SalonStatistics)
            .HasForeignKey(x => x.SalonId);
        }
    }
}