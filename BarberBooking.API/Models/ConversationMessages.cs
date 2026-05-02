using System;
using CSharpFunctionalExtensions;

namespace BarberBooking.API.Models
{
    public class ConversationMessages
    {
        public Guid Id { get; private set; }
        public Guid ConversationsId { get; private set; }
        public Conversations Conversation { get; private set; }
        public Guid SenderId { get; private set; }
        public Guid ReceiverId { get; private set; }
        public Users Sender { get; private set; }
        public Users Receiver { get; private set; }
        public string Content { get; private set; }
        public bool IsRead { get; private set; }
        public DateTime? ReadAt { get; private set; }
        public DateTime CreatedAt { get; private set; }

        public static Result<ConversationMessages> Create(
            Guid conversationId,
            Guid senderId,
            Guid receiverId,
            string content,
            bool isRead,
            DateTime? readAt)
        {
            if (string.IsNullOrWhiteSpace(content))
                return Result.Failure<ConversationMessages>("Текст сообщения обязателен");
            var message = new ConversationMessages
            {
                Id = Guid.NewGuid(),
                ConversationsId = conversationId,
                SenderId = senderId,
                ReceiverId = receiverId,
                Content = content.Trim(),
                IsRead = isRead,
                ReadAt = readAt,
                CreatedAt = DateTime.UtcNow,
            };
            return Result.Success(message);
        }
        public void UpdateContent(string content) => Content = content;
        public void UpdateIsRead() => IsRead = true;
    }
}
