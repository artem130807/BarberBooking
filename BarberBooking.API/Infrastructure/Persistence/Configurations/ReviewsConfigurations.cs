using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberBooking.API.Configurations
{
    public class ReviewsConfigurations : IEntityTypeConfiguration<Review>
    {
        public void Configure(EntityTypeBuilder<Review> builder)
        {
            builder.ToTable("Reviews");
        
            builder.HasKey(x => x.Id);
            
            builder.Property(x => x.Comment)
                .HasMaxLength(1000);
                
            builder.Property(x => x.SalonRating)
                .IsRequired();
                
            builder.HasOne(x => x.Appointment)
                .WithMany()
                .HasForeignKey(x => x.AppointmentId)
                .OnDelete(DeleteBehavior.Restrict);
                
            builder.HasOne(x => x.Client)
                .WithMany()
                .HasForeignKey(x => x.ClientId)
                .OnDelete(DeleteBehavior.Restrict);
                
            builder.HasOne(x => x.Salon)
                .WithMany(x => x.Reviews)
                .HasForeignKey(x => x.SalonId)
                .OnDelete(DeleteBehavior.Restrict);
                
            builder.HasOne(x => x.MasterProfile)
                .WithMany(x => x.Reviews)
                .HasForeignKey(x => x.MasterProfileId)
                .OnDelete(DeleteBehavior.Restrict);
                
            builder.Property(x => x.CreatedAt)
                .IsRequired();
                
            builder.HasIndex(x => x.AppointmentId)
                .IsUnique();
        }
    }
}