using IdentityService.Domain.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace IdentityService.Infrastructure.Persistence.Configurations;

public class OutboxMessageConfigurations : IEntityTypeConfiguration<OutboxMessage>
{
    public void Configure(EntityTypeBuilder<OutboxMessage> builder)
    {
        builder.HasKey(x => x.Id);
        builder.Property(x => x.AggregateType);
        builder.Property(x => x.EventType);
        builder.Property(x => x.AggregateId);
        builder.Property(x => x.OccurredOn);
        builder.Property(x => x.ProcessedOn);
        builder.Property(x => x.Status);
        builder.Property(x => x.Error);
        builder.Property(x => x.RetryCount);
    }
}
