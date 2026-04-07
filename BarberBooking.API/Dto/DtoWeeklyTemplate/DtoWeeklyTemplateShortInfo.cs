using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoWeeklyTemplate
{
    public class DtoWeeklyTemplateShortInfo
    {
        public Guid Id {get; set;}
        public string Name {get; set;}
        public bool IsActive {get; set;} = true;
        public int TemplateDayCount {get; set;}
    }
}