using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberBooking.API.Configurations
{
    public class SalonsConfigurations : IEntityTypeConfiguration<Salons>
    {
        public void Configure(EntityTypeBuilder<Salons> builder)
        {
            builder.ToTable("Salons"); 
            builder.HasKey(x => x.Id);  
            builder.Property(x => x.Name)
            .IsRequired()
            .HasMaxLength(200); 
            builder.Property(x => x.Description)
            .HasMaxLength(2000);
            builder.ComplexProperty(c => c.Address, c =>
            {
               c.IsRequired();
               c.Property(c => c.City).HasColumnName("City").HasMaxLength(100);
               c.Property(x => x.Street).HasColumnName("Street").HasMaxLength(200);
               c.Property(x => x.HouseNumber).HasColumnName("HouseNumber").HasMaxLength(10);
               c.Property(x => x.Apartment).HasColumnName("Apartment").HasMaxLength(20);
            });
            builder.ComplexProperty(c => c.PhoneNumber, c =>
            {
               c.IsRequired();
               c.Property(c => c.Number).HasColumnName("Phone").HasMaxLength(100);
            });
            
            builder.Property(x => x.Rating)
                .HasPrecision(3, 2);
                
            builder.HasMany(x => x.SalonUsers)
                .WithOne(x => x.Salon)
                .HasForeignKey(x => x.SalonId)
                .OnDelete(DeleteBehavior.Restrict);
                
            builder.HasMany(x => x.Appointments)
                .WithOne(x => x.Salon)
                .HasForeignKey(x => x.SalonId)
                .OnDelete(DeleteBehavior.Restrict);
                
            builder.HasMany(x => x.Services)
                .WithOne(x => x.Salon)
                .HasForeignKey(x => x.SalonId)
                .OnDelete(DeleteBehavior.Cascade);
                
            builder.HasMany(x => x.Reviews)
                .WithOne(x => x.Salon)
                .HasForeignKey(x => x.SalonId)
                .OnDelete(DeleteBehavior.Restrict);
                
            builder.Property(x => x.CreatedAt)
                .IsRequired();

              builder.HasMany(x => x.SalonStatistics)
                .WithOne(x => x.Salon)
                .HasForeignKey(x => x.SalonId)
                .OnDelete(DeleteBehavior.Cascade);
            
            builder.HasMany(x => x.SalonsAdmins)
                .WithOne(x => x.Salon)
                .HasForeignKey(x => x.SalonId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.HasMany(x => x.SalonPhotos)
                .WithOne(x => x.Salon)
                .HasForeignKey(x => x.SalonId)
                .OnDelete(DeleteBehavior.Cascade);

        }
    }
}