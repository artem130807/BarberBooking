using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Models
{
    public class WeeklyTemplate
    {
        public Guid Id { get; private set; }
        public Guid MasterProfileId { get; private set; }
        public string Name { get; private set; }
        public bool IsActive { get; private set; } = true;
        public DateTime CreatedAt { get; private set; } = DateTime.UtcNow;
        public MasterProfile MasterProfile {get; private set;}
        public ICollection<TemplateDay> TemplateDays {get; private set;}
        private WeeklyTemplate()
        {
            TemplateDays = new List<TemplateDay>();
        }
        public static WeeklyTemplate Create(Guid masterId, string name, bool isActive)
        {
            var weekly = new WeeklyTemplate
            {
                Id = Guid.NewGuid(),
                MasterProfileId = masterId,
                Name = name,
                IsActive = isActive,
                CreatedAt = DateTime.UtcNow
            };
            return weekly;
        }
        public void UpdateName(string name) => Name = name;
        public void UpdateIsActive(bool isActive) => IsActive = isActive;
    }
}