using CSharpFunctionalExtensions;
using IdentityService.Application.Dto;
using IdentityService.Application.Dto.Users;
using MediatR;

namespace IdentityService.Application.CQRS.Users.Commands;

public record RegisterUserCommand(DtoCreateUser dtoCreateUser) : IRequest<Result<AuthDto>>;
