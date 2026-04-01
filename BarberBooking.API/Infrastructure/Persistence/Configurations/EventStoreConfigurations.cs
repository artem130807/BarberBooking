using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberBooking.API.Configurations
{
    public class EventStoreConfigurations : IEntityTypeConfiguration<EventStore>
    {
        public void Configure(EntityTypeBuilder<EventStore> builder)
        {
            builder.ToTable("EventStore");
            builder.HasKey(x => x.Id);
            builder.Property(x => x.AggregateId).IsRequired();
            builder.Property(x => x.EventType).IsRequired().HasMaxLength(100)
            .HasColumnType("nvarchar(100)");
            builder.Property(x => x.EventData).IsRequired().HasColumnType("nvarchar(max)");;
            builder.Property(x => x.Version).IsRequired();
            builder.Property(x => x.OccurredAt).IsRequired();
            builder.HasIndex(x => new { x.AggregateId, x.Version })
            .IsUnique()
            .HasDatabaseName("IX_EventStore_AggregateId_Version");
            builder.HasIndex(x => x.AggregateId)
            .HasDatabaseName("IX_EventStore_AggregateId");
            builder.HasIndex(x => x.EventType)
            .HasDatabaseName("IX_EventStore_EventType");
            builder.HasIndex(x => x.OccurredAt)
            .HasDatabaseName("IX_EventStore_OccurredAt");
        }
    }
}