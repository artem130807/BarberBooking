using System;

namespace BarberBooking.API.Dto.DtoTemplateDay
{
    public class DtoTemplateDayInfo
    {
        public Guid Id { get; set; }
        public Guid WeeklyTemplateId { get; set; }
        public DayOfWeek DayOfWeek { get; set; }
        public TimeOnly WorkStartTime { get; set; }
        public TimeOnly WorkEndTime { get; set; }
    }
}
