using CSharpFunctionalExtensions;
using IdentityService.Application.Dto.Users;

namespace IdentityService.Application.Contracts;

public interface IUserValidatorService
{
    Task<Result> ValidUser(DtoCreateUser dtoCreateUser);
}
