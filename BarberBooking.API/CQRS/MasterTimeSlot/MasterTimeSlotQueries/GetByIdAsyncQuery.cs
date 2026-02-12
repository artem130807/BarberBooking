using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoMasterTimeSlot;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterTimeSlotQueries
{
    public record GetByIdAsyncQuery(Guid Id):IRequest<Result<DtoMasterTimeSlotInfo>>;
  
}