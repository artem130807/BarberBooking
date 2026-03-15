using BarberBooking.API.Dto.DtoUsers;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Commands
{
    public record UpdateCityCommand(string City) : IRequest<Result<DtoUpdateCityResponse>>;
}