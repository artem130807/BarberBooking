using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.DtoModels.AuthorizationDto
{
    public class AuthorizationAudit
    {
        public bool Allowed {get ;set;}
        public string Reason {get; set;}
    }
}