using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberBooking.API.Configurations
{
    public class MasterTimeSlotConfigurations : IEntityTypeConfiguration<MasterTimeSlot>
    {
        public void Configure(EntityTypeBuilder<MasterTimeSlot> builder)
        {
            builder.ToTable("MasterTimeSlots");
        
            builder.HasKey(x => x.Id);
            
            builder.Property(x => x.Status)
                .HasConversion<string>()
                .HasMaxLength(20);
                
            builder.Property(x => x.ScheduleDate)
                .IsRequired();

            builder.Property(x => x.ScheduleDate)
            .HasColumnType("date");
                
            builder.HasOne(x => x.Master)
                .WithMany(x => x.TimeSlots)
                .HasForeignKey(x => x.MasterId)
                .OnDelete(DeleteBehavior.Cascade);
                
            builder.HasMany(x => x.Appointments)
                .WithOne(x => x.TimeSlot)
                .HasForeignKey(x => x.TimeSlotId)
                .OnDelete(DeleteBehavior.Restrict);
                
            builder.HasIndex(x => new { x.MasterId, x.ScheduleDate, x.StartTime })
                .IsUnique();
        }
    }
}