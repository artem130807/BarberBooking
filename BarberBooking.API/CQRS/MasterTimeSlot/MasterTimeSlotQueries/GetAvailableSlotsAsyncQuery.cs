using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoMasterTimeSlot;
using MediatR;

namespace BarberBooking.API.CQRS.MasterTimeSlotQueries
{
    public record GetAvailableSlotsAsyncQuery(Guid masterId, DateOnly date, TimeSpan serviceDuration):IRequest<List<DtoMasterTimeSlotInfo>>;
    
}