using BarberBooking.API.Dto;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.RefreshTokens.Commands
{
    public record RefreshAccessTokenCommand(string RefreshTokenBase64, string Devices) : IRequest<Result<AuthDto>>;
}
