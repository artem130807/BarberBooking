using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoServices;
using MediatR;

namespace BarberBooking.API.CQRS.ServicesCommands
{
    public record ServicesCreateAsyncCommand(DtoCreateServices dtoCreateServices):IRequest<DtoServicesShortInfo>;
   
}