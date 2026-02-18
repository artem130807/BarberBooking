using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.UserContratcts;
using BarberBooking.API.Dto.DtoUsers;
using CSharpFunctionalExtensions;

namespace BarberBooking.API.Validator
{
    public class UserValidatorService : IUserValidatorService
    {
        private readonly IUserRepository _userRepository;
        public UserValidatorService(IUserRepository userRepository)
        {
            _userRepository = userRepository;
        }
        public async Task<Result> ValidUser(DtoCreateUser dtoCreateUser)
        {
            var userByEmail = await _userRepository.GetUserByEmail(dtoCreateUser.Email);
            if(userByEmail != null)
                return Result.Failure("Пользователь с таким email уже существует");
            var userByPhone = await _userRepository.GetUserByPhone(dtoCreateUser.Phone.Number);
            if (userByPhone != null)       
                return Result.Failure("Пользователь с таким номером телефона уже существует");

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