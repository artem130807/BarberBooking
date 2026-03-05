using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.UserContratcts;
using BarberBooking.API.Dto.DtoUsers;
using CSharpFunctionalExtensions;
using Microsoft.Extensions.Caching.Memory;

namespace BarberBooking.API.Validator
{
    public class UserValidatorService : IUserValidatorService
    {
        private readonly IUserRepository _userRepository;
        private readonly IBadWordService _badWordService;
        private readonly ICityService _cityService;
        public UserValidatorService(IUserRepository userRepository, IBadWordService badWordService, ICityService cityService)
        {
            _userRepository = userRepository;
            _badWordService = badWordService;
            _cityService = cityService;
        }
        public async Task<Result> ValidUser(DtoCreateUser dtoCreateUser)
        {
            var userByEmail = await _userRepository.GetUserByEmail(dtoCreateUser.Email);
            if(userByEmail != null)
                return Result.Failure("Пользователь с таким email уже существует");
            var userByPhone = await _userRepository.GetUserByPhone(dtoCreateUser.Phone.Number);
            if (userByPhone != null)       
                return Result.Failure("Пользователь с таким номером телефона уже существует");
            if(!_cityService.IsCityValid(dtoCreateUser.City))
                return Result.Failure("Вы указали неверный город");
            if(string.IsNullOrWhiteSpace(dtoCreateUser.Name))
                return Result.Failure("Вы не указали имя");
            if(string.IsNullOrWhiteSpace(dtoCreateUser.Phone.Number))
                return Result.Failure("Вы не указали номер");
            if(string.IsNullOrWhiteSpace(dtoCreateUser.Email))
                return Result.Failure("Вы не указали почту");
            if(string.IsNullOrWhiteSpace(dtoCreateUser.PasswordHash))
                return Result.Failure("Вы не указали пароль");
            if(string.IsNullOrWhiteSpace(dtoCreateUser.City))
                return Result.Failure("Вы не указали город");
            return Result.Success("Валидные данные");
        }
    }
}