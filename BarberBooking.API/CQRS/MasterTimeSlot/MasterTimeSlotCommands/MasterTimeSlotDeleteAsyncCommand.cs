using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoMasterTimeSlot;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterTimeSlotCommands.Handler
{
    public record MasterTimeSlotDeleteAsyncCommand(Guid Id):IRequest<Result<DtoMasterTimeSlotInfo>>;
    
}