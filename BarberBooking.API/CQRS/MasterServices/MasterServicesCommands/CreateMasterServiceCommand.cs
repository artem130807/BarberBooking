using BarberBooking.API.Dto.DtoMasterServices;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterServices.MasterServicesCommands
{
    public record CreateMasterServiceCommand(DtoCreateMasterService Dto) : IRequest<Result<DtoMasterServiceInfo>>;
}
