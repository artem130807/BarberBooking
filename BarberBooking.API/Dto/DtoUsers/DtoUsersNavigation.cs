using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoUsers
{
    public class DtoUsersNavigation
    {
        public Guid Id {get; set;}
        public string Name {get; set;}
        public DtoPhone dtoPhone {get; set;}
    }
}