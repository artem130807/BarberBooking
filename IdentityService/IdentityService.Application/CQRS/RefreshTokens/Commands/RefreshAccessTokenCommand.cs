using CSharpFunctionalExtensions;
using IdentityService.Application.Dto;
using MediatR;

namespace IdentityService.Application.CQRS.RefreshTokens.Commands;

public record RefreshAccessTokenCommand(string RefreshTokenBase64, string Devices) : IRequest<Result<AuthDto>>;
