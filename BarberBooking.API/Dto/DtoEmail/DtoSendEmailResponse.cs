using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoEmail
{
    public class DtoSendEmailResponse
    {
        public string Message {get; set;} = string.Empty;
        public bool IsSuccess {get; set;} = false;
    }
}