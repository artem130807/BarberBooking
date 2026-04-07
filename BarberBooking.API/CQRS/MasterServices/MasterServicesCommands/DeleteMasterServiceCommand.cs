using System;
using BarberBooking.API.Dto.DtoMasterServices;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterServices.MasterServicesCommands
{
    public record DeleteMasterServiceCommand(Guid Id) : IRequest<Result<DtoMasterServiceInfo>>;
}
