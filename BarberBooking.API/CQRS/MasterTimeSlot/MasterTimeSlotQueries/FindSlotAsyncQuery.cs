using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoMasterTimeSlot;
using MediatR;

namespace BarberBooking.API.CQRS.MasterTimeSlotQueries
{
    public record FindSlotAsyncQuery(Guid masterId, DateOnly date, TimeOnly startTime):IRequest<DtoMasterTimeSlotInfo>;
   
}