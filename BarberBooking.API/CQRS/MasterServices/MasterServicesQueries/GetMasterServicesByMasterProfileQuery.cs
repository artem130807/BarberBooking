using System;
using System.Collections.Generic;
using BarberBooking.API.Dto.DtoMasterServices;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterServices.MasterServicesQueries
{
    public record GetMasterServicesByMasterProfileQuery(Guid MasterProfileId)
        : IRequest<Result<List<DtoMasterServiceInfo>>>;
}
