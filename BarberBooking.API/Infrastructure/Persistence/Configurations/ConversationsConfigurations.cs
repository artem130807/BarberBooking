using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberBooking.API.Infrastructure.Persistence.Configurations
{
    public class ConversationsConfigurations : IEntityTypeConfiguration<Conversations>
    {
        public void Configure(EntityTypeBuilder<Conversations> builder)
        {
            builder.ToTable("Conversations");
            builder.HasKey(x => x.Id);
            builder.Property(x => x.LastMessageAt).IsRequired();
            builder.Property(x => x.CreatedAt).IsRequired();
            builder.HasOne(x => x.Participant1)
                .WithMany(x => x.ConversationsAsParticipant1)
                .HasForeignKey(x => x.Participant1Id)
                .OnDelete(DeleteBehavior.Restrict);
            builder.HasOne(x => x.Participant2)
                .WithMany(x => x.ConversationsAsParticipant2)
                .HasForeignKey(x => x.Participant2Id)
                .OnDelete(DeleteBehavior.Restrict);
        }
    }
}
