using CSharpFunctionalExtensions;
using IdentityService.Application.Dto.Users;
using MediatR;

namespace IdentityService.Application.CQRS.Users.Commands;

public record UpdateCityCommand(string City, string devices) : IRequest<Result<DtoUpdateCityResponse>>;
