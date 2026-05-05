using CSharpFunctionalExtensions;
using IdentityService.Application.Dto;
using MediatR;

namespace IdentityService.Application.CQRS.Users.Queries;

public record GetUserByTokenIdQuery() : IRequest<Result<UserInfoDto>>;
