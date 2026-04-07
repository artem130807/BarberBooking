using System;
using System.Collections.Generic;
using BarberBooking.API.Dto.DtoServices;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterServices.MasterServicesQueries
{
    public record GetMasterServicesForBookingQuery(Guid MasterProfileId)
        : IRequest<Result<List<DtoServicesInfo>>>;
}
