using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberBooking.API.Configurations
{
    public class ServicesConfigurations : IEntityTypeConfiguration<Services>
    {
        public void Configure(EntityTypeBuilder<Services> builder)
        {
            builder.ToTable("Services");
            
            builder.HasKey(x => x.Id);
            
            builder.Property(x => x.Name)
                .IsRequired()
                .HasMaxLength(200);
                
            builder.Property(x => x.Description)
                .HasMaxLength(1000);

            builder.ComplexProperty(c => c.Price, b =>
            {
               b.IsRequired();   
               b.Property(c => c.Value).HasColumnName("Price")
               .HasColumnType("decimal(10,2)") ;
            });

            builder.Property(x => x.PhotoUrl)
            .HasMaxLength(500);
            
            builder.Property(x => x.DurationMinutes)
                .IsRequired();
                
            builder.HasOne(x => x.Salon)
                .WithMany(x => x.Services)
                .HasForeignKey(x => x.SalonId)
                .OnDelete(DeleteBehavior.Cascade);
                
            builder.HasMany(x => x.Appointments)
                .WithOne(x => x.Service)
                .HasForeignKey(x => x.ServiceId)
                .OnDelete(DeleteBehavior.Restrict);
                
            builder.Property(x => x.CreatedAt)
                .IsRequired();
                
            builder.HasIndex(x => new { x.SalonId, x.Name })
                .IsUnique();

            builder.HasMany(x => x.MasterServices)
            .WithOne(x => x.Service)
            .HasForeignKey(x => x.ServiceId)
            .OnDelete(DeleteBehavior.Cascade);
        }
    }
}