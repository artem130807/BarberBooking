using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberBooking.API.Infrastructure.Persistence.Configurations
{
    public class SalonPhotosConfigurations : IEntityTypeConfiguration<SalonPhotos>
    {
        public void Configure(EntityTypeBuilder<SalonPhotos> builder)
        {
            builder.ToTable("SalonPhotos");
            builder.HasKey(x => x.Id);
            builder.Property(x => x.PhotoUrl);
            builder.HasOne(x => x.Salon)
            .WithMany(x => x.SalonPhotos)
            .HasForeignKey(x => x.SalonId);
        }
    }
}