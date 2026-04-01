using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberBooking.API.Configurations
{
    public class MasterProfileConfigurations : IEntityTypeConfiguration<MasterProfile>
    {

        public void Configure(EntityTypeBuilder<MasterProfile> builder)
        {
            builder.ToTable("MasterProfiles");
        
            builder.HasKey(x => x.Id);
            
            builder.Property(x => x.Bio)
                .HasMaxLength(1000);
                
            builder.Property(x => x.Specialization)
                .HasMaxLength(200);
                
            builder.Property(x => x.AvatarUrl)
                .HasMaxLength(500);
                
            builder.Property(x => x.Rating)
                .HasPrecision(3, 2);
                
            builder.HasOne(x => x.Salon)
                .WithMany(x => x.SalonUsers)
                .HasForeignKey(x => x.SalonId)
                .OnDelete(DeleteBehavior.Restrict);
                
            builder.HasOne(x => x.User)
                .WithMany()
                .HasForeignKey(x => x.UserId)
                .OnDelete(DeleteBehavior.Restrict);
                
            builder.HasMany(x => x.TimeSlots)
                .WithOne(x => x.Master)
                .HasForeignKey(x => x.MasterId)
                .OnDelete(DeleteBehavior.Cascade);
                
            builder.HasMany(x => x.Appointments)
                .WithOne(x => x.Master)
                .HasForeignKey(x => x.MasterId)
                .OnDelete(DeleteBehavior.Restrict);
                
            builder.HasMany(x => x.Subscriptions)
                .WithOne(x => x.MasterProfile)
                .HasForeignKey(x => x.MasterId)
                .OnDelete(DeleteBehavior.Cascade);
                
            builder.HasMany(x => x.Reviews)
                .WithOne(x => x.MasterProfile)
                .HasForeignKey(x => x.MasterProfileId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasMany(x => x.WeeklyTemplates)
                .WithOne(x => x.MasterProfile)
                .HasForeignKey(x => x.MasterId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.Property(x => x.CreatedAt)
                .IsRequired();
            
            builder.HasMany(x => x.MasterStatistics)
            .WithOne(x => x.MasterProfile)
            .HasForeignKey(x => x.MasterProfileId)
            .OnDelete(DeleteBehavior.Cascade);
        }
    }
}