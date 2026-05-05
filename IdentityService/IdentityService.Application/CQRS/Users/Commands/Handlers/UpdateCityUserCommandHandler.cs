using CSharpFunctionalExtensions;
using IdentityService.Application.Contracts;
using IdentityService.Application.Dto.Users;
using MediatR;

namespace IdentityService.Application.CQRS.Users.Commands.Handlers;

public class UpdateCityUserCommandHandler : IRequestHandler<UpdateCityCommand, Result<DtoUpdateCityResponse>>
{
    private readonly IUserRepository _usersRepository;
    private readonly IUserContext _userContext;
    private readonly ICityService _cityService;
    private readonly IJwtProvider _jwtProvider;

    public UpdateCityUserCommandHandler(
        IUserRepository usersRepository,
        IUserContext userContext,
        ICityService cityService,
        IJwtProvider jwtProvider)
    {
        _usersRepository = usersRepository;
        _userContext = userContext;
        _cityService = cityService;
        _jwtProvider = jwtProvider;
    }

    public async Task<Result<DtoUpdateCityResponse>> Handle(UpdateCityCommand command, CancellationToken cancellationToken)
    {
        var userId = _userContext.UserId;
        if (!_cityService.IsCityValid(command.City))
            return Result.Failure<DtoUpdateCityResponse>("Р’С‹ СѓРєР°Р·Р°Р»Рё РЅРµРІРµСЂРЅС‹Р№ РіРѕСЂРѕРґ");

        var updatedCity = await _usersRepository.UpdateCity(userId, command.City);
        if (string.IsNullOrWhiteSpace(updatedCity))
            return Result.Failure<DtoUpdateCityResponse>("РћС€РёР±РєР° РѕР±РЅРѕРІР»РµРЅРёСЏ РіРѕСЂРѕРґР°");

        var user = await _usersRepository.GetUserById(userId);
        if (user == null)
            return Result.Failure<DtoUpdateCityResponse>("РџРѕР»СЊР·РѕРІР°С‚РµР»СЊ РЅРµ РЅР°Р№РґРµРЅ");

        var token = await _jwtProvider.GenerateToken(user, command.devices);
        return Result.Success(new DtoUpdateCityResponse { City = updatedCity, Token = token });
    }
}
