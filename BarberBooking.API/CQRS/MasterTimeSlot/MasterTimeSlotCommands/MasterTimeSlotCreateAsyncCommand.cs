using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoMasterTimeSlot;
using MediatR;

namespace BarberBooking.API.CQRS.MasterTimeSlotCommands
{
    public record MasterTimeSlotCreateAsyncCommand(DtoCreateMasterTimeSlot dtoCreateMasterTimeSlot):IRequest<DtoMasterTimeSlotInfo>;
   
}