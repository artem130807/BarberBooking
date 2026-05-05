using CSharpFunctionalExtensions;
using IdentityService.Application.Dto.Users;
using MediatR;

namespace IdentityService.Application.CQRS.Users.Queries;

public record GetUserProfileByIdQuery(Guid Id) : IRequest<Result<DtoUserProfile>>;
