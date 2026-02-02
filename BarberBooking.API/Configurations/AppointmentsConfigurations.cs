using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberBooking.API.Configurations
{
    public class AppointmentsConfigurations : IEntityTypeConfiguration<Appointments>
    {
        public void Configure(EntityTypeBuilder<Appointments> builder)
        {
            builder.ToTable("Appointments");
            
            builder.HasKey(x => x.Id);
            
            builder.Property(x => x.Status)
                .HasConversion<string>()
                .HasMaxLength(20);
                
            builder.Property(x => x.ClientNotes)
                .HasMaxLength(500);

            builder.HasOne(x => x.Salon)
                .WithMany(x => x.Appointments)
                .HasForeignKey(x => x.SalonId)
                .OnDelete(DeleteBehavior.Restrict);
                
            
            builder.HasOne(x => x.Client)
                .WithMany()
                .HasForeignKey(x => x.ClientId)
                .OnDelete(DeleteBehavior.Restrict);
                
            builder.HasOne(x => x.Master)
                .WithMany(x => x.Appointments)
                .HasForeignKey(x => x.MasterId)
                .OnDelete(DeleteBehavior.Restrict);
                
            builder.HasOne(x => x.Service)
                .WithMany(x => x.Appointments)
                .HasForeignKey(x => x.ServiceId)
                .OnDelete(DeleteBehavior.Restrict);
                
            builder.HasOne(x => x.TimeSlot)
                .WithMany(x => x.Appointments)
                .HasForeignKey(x => x.TimeSlotId)
                .OnDelete(DeleteBehavior.Restrict);
                
            builder.Property(x => x.CreatedAt)
                .IsRequired();
                
            builder.Property(x => x.UpdatedAt)
                .IsRequired();
        }
    }
}