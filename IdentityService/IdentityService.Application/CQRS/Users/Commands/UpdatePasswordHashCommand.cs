using CSharpFunctionalExtensions;
using IdentityService.Application.Dto.Users;
using MediatR;

namespace IdentityService.Application.CQRS.Users.Commands;

public record UpdatePasswordHashCommand(DtoUpdatePassword dtoUpdatePassword) : IRequest<Result<DtoUpdatePasswordResult>>;
