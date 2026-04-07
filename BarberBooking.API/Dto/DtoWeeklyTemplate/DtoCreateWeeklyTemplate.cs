using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoWeeklyTemplate
{
    public class DtoCreateWeeklyTemplate
    {
        public string Name {get; set;}
        public bool IsActive {get; set;} = true;
    }
}