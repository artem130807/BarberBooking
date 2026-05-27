using System;

namespace BarberBooking.API.Dto.DtoConversationMessages
{
    public class DtoConversationMessageShortInfo
    {
        public Guid Id { get; set; }
        public Guid SenderId { get; set; }
        public string SenderName { get; set; }
        public string Content { get; set; }
        public bool IsRead { get; set; }
        public DateTime SendTime { get; set; }
    }
}
