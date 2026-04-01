using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberBooking.API.Infrastructure.Persistence.Configurations
{
    public class MasterStatisticConfigurations : IEntityTypeConfiguration<MasterStatistic>
    {
        public void Configure(EntityTypeBuilder<MasterStatistic> builder)
        {
             builder.ToTable("MasterStatistic");
            builder.HasKey(x => x.Id);
            builder.Property(x => x.Rating);
            builder.Property(x => x.RatingCount);
            builder.Property(x => x.CompletedAppointmentsCount);
            builder.Property(x => x.CancelledAppointmentsCount);
            builder.Property(x => x.SumPrice);
            builder.Property(x => x.CreatedAt);
            builder.HasOne(x => x.MasterProfile).WithMany(x => x.MasterStatistics)
            .HasForeignKey(x => x.MasterProfileId);
        }
    }
}