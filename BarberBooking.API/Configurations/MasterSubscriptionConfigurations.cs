using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberBooking.API.Configurations
{
    public class MasterSubscriptionConfigurations : IEntityTypeConfiguration<MasterSubscription>
    {
        public void Configure(EntityTypeBuilder<MasterSubscription> builder)
        {
            builder.ToTable("MasterSubscriptions");
        
            builder.HasKey(x => x.Id);
            
            builder.HasOne(x => x.Client)
                .WithMany()
                .HasForeignKey(x => x.ClientId)
                .OnDelete(DeleteBehavior.Restrict);
                
            builder.HasOne(x => x.MasterProfile)
                .WithMany(x => x.Subscriptions)
                .HasForeignKey(x => x.MasterId)
                .OnDelete(DeleteBehavior.Cascade);
                
            builder.Property(x => x.SubscribedAt)
                .IsRequired();
        }
    }
}