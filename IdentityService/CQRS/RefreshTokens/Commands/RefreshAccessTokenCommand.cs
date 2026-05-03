using IdentityService.Dto;
using CSharpFunctionalExtensions;
using MediatR;

namespace IdentityService.CQRS.RefreshTokens.Commands;

public record RefreshAccessTokenCommand(string RefreshTokenBase64, string Devices) : IRequest<Result<AuthDto>>;
