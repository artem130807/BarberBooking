using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace NotifyService.Application.Dto.DtoEmail
{
    public class DtoVerificateRequest
    {
        public string Code {get; set;}
        public string Email {get; set;}
    }
}