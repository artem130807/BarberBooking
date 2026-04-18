using System;
using System.Collections.Generic;
using CSharpFunctionalExtensions;

namespace BarberBooking.API.Models
{
    public class Conversations
    {
        public Guid Id { get; private set; }
        public Guid Participant1Id { get; private set; }
        public Guid Participant2Id { get; private set; }
        public Users Participant1 { get; private set; }
        public Users Participant2 { get; private set; }
        public DateTime LastMessageAt { get; private set; }
        public DateTime CreatedAt { get; private set; }
        public ICollection<ConversationMessages> ConversationMessages { get; private set; }

        private Conversations()
        {
            ConversationMessages = new List<ConversationMessages>();
        }

        public static Result<Conversations> Create(Guid participant1Id, Guid participant2Id, DateTime lastMessageAt)
        {
            if (participant1Id == participant2Id)
                return Result.Failure<Conversations>("Участники диалога должны различаться");
            var conversation = new Conversations
            {
                Id = Guid.NewGuid(),
                Participant1Id = participant1Id,
                Participant2Id = participant2Id,
                LastMessageAt = lastMessageAt,
                CreatedAt = DateTime.UtcNow,
                ConversationMessages = new List<ConversationMessages>(),
            };
            return Result.Success(conversation);
        }
    }
}
