using System;

namespace BarberBooking.API.Dto.DtoTemplateDay
{
    public class DtoUpdateTemplateDay
    {
        public TimeOnly WorkStartTime { get; set; }
        public TimeOnly WorkEndTime { get; set; }
        public DayOfWeek? DayOfWeek { get; set; }
    }
}
