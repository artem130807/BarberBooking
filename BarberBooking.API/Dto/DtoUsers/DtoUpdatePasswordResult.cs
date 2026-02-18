using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoUsers
{
    public class DtoUpdatePasswordResult
    {
        public string Message {get; set;}
        public bool IsSuccess {get; set;} = false;
    }
}