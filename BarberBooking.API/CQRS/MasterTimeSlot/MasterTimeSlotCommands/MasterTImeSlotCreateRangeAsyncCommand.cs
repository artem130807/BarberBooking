using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoMasterTimeSlot;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterTimeSlotCommands
{
    public record MasterTimeSlotCreateRangeAsyncCommand(List<DtoCreateMasterTimeSlot> dtoCreateMasterTimeSlot):IRequest<Result<List<DtoMasterTimeSlotInfo>>>;
    
}