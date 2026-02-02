using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Models
{
    public class TemplateDay
    {
        public Guid Id { get; private set; }
        public Guid TemplateId { get; private set; }
        public DayOfWeek DayOfWeek { get; private set; }
        public TimeSpan WorkStartTime { get; private set; }
        public TimeSpan WorkEndTime { get; private set; }
        public WeeklyTemplate WeeklyTemplate {get; private set;}
        private TemplateDay(){}
        public static TemplateDay Create(Guid templateId, DayOfWeek dayOfWeek,TimeSpan workStartTime, TimeSpan workEndTime)
        {
            var templateDay = new TemplateDay
            {
                Id = Guid.NewGuid(),
                TemplateId = templateId,
                DayOfWeek = dayOfWeek,                
                WorkStartTime = workStartTime,
                WorkEndTime = workEndTime
            };
            return templateDay;
        }
        public void UpdateWorkStartTime(TimeSpan workStartTime) => WorkStartTime = workStartTime;
        public void UpdateWorkEndTime(TimeSpan workEndTime) => WorkEndTime = workEndTime;
    }
}