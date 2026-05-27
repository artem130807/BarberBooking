using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace IdentityService.Application.Contracts
{
    public interface IRabbitMqService
    {
        Task SendMessage(object obj);
    }
}