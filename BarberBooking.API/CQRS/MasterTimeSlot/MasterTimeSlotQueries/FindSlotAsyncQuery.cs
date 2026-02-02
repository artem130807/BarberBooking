using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoMasterTimeSlot;
using MediatR;

namespace BarberBooking.API.CQRS.MasterTimeSlotQueries
{
    public record FindSlotAsyncQuery(Guid masterId, DateTime date, TimeSpan startTime):IRequest<DtoMasterTimeSlotInfo>;
   
}