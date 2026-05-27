using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace NotifyService.Application.Dto.DtoEmail
{
    public class DtoVerificateResultResponse
    {
        public string Message { get; set; } = string.Empty;
        public bool IsSuccess { get; set; }
    }
}