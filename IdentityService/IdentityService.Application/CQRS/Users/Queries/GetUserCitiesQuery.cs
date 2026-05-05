using CSharpFunctionalExtensions;
using MediatR;

namespace IdentityService.Application.CQRS.Users.Queries;

public record GetUserCitiesQuery(string? city) : IRequest<Result<List<string>>>;
