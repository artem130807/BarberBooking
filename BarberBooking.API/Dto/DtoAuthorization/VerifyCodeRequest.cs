using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoAuthorization
{
    public class VerifyCodeRequest
    {
        public string Code { get; set; } = string.Empty;
    }
}