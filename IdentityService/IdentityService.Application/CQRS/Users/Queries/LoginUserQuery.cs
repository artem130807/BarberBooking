using CSharpFunctionalExtensions;
using IdentityService.Application.Dto;
using MediatR;

namespace IdentityService.Application.CQRS.Users.Queries;

public record LoginUserQuery(string Email, string PasswordHash, string devices) : IRequest<Result<AuthDto>>;
