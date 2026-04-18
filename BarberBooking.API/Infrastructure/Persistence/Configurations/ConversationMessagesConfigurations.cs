using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberBooking.API.Infrastructure.Persistence.Configurations
{
    public class ConversationMessagesConfigurations : IEntityTypeConfiguration<ConversationMessages>
    {
        public void Configure(EntityTypeBuilder<ConversationMessages> builder)
        {
            builder.ToTable("ConversationMessages");
            builder.HasKey(x => x.Id);
            builder.Property(x => x.Content).IsRequired().HasMaxLength(8000);
            builder.Property(x => x.IsRead).IsRequired();
            builder.Property(x => x.ReadAt);
            builder.Property(x => x.CreatedAt).IsRequired();
            builder.HasOne(x => x.Conversation)
                .WithMany(x => x.ConversationMessages)
                .HasForeignKey(x => x.ConversationsId)
                .OnDelete(DeleteBehavior.Cascade);
            builder.HasOne(x => x.Sender)
                .WithMany()
                .HasForeignKey(x => x.SenderId)
                .OnDelete(DeleteBehavior.Restrict);
            builder.HasOne(x => x.Receiver)
                .WithMany()
                .HasForeignKey(x => x.ReceiverId)
                .OnDelete(DeleteBehavior.Restrict);
            builder.HasIndex(x => x.ConversationsId);
            builder.HasIndex(x => x.CreatedAt);
        }
    }
}
