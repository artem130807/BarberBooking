using System;
using BarberBooking.API.Dto.DtoMasterServices;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterServices.MasterServicesQueries
{
    public record GetMasterServiceByIdQuery(Guid Id) : IRequest<Result<DtoMasterServiceInfo>>;
}
