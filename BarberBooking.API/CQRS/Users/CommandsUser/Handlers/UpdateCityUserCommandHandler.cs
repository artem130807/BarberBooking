using BarberBooking.API.Contracts;
using BarberBooking.API.CQRS.Commands;
using BarberBooking.API.Dto.DtoUsers;
using BarberBooking.API.Provider;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Commands.Handlers
{
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
                return Result.Failure<DtoUpdateCityResponse>("Вы указали неверный город");

            var updatedCity = await _usersRepository.UpdateCity(userId, command.City);
            if (updatedCity == null)
                return Result.Failure<DtoUpdateCityResponse>("Ошибка обновления города");

            var user = await _usersRepository.GetUserById(userId);
            if (user == null)
                return Result.Failure<DtoUpdateCityResponse>("Пользователь не найден");

            var token = await _jwtProvider.GenerateToken(user, command.devices);
            return Result.Success(new DtoUpdateCityResponse { City = updatedCity, Token = token });
        }
    }
}