using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Dto;
using BarberBooking.API.Provider;
using CSharpFunctionalExtensions;
using MediatR;
using Microsoft.Extensions.Caching.Memory;

namespace BarberBooking.API.CQRS.Queries.Handlers
{
    public class LoginUserQueryCommandHandler:IRequestHandler<LoginUserQuery, Result<AuthDto>>
    {
        private readonly IUserRepository _usersRepository;
        private readonly IPasswordHasher _passwordHasher;
        private readonly IJwtProvider _jwtProvider;
        
        public LoginUserQueryCommandHandler(
            IUserRepository usersRepository,
            IPasswordHasher passwordHasher,
            IJwtProvider jwtProvider
            )
        {
            _usersRepository = usersRepository;
            _passwordHasher = passwordHasher;
            _jwtProvider = jwtProvider;
        }

        public async Task<Result<AuthDto>> Handle(LoginUserQuery query, CancellationToken cancellationToken)
        {
            var user = await _usersRepository.GetUserByEmail(query.Email);
            if(user == null)
                return Result.Failure<AuthDto>("Пользователя не существует");
            var result = _passwordHasher.Verify(query.PasswordHash, user.PasswordHash);
            if (result == false || user == null)
            {
                return Result.Failure<AuthDto>("Неправильный пароль");
            }
            var token = await _jwtProvider.GenerateToken(user);
            return Result.Success(new AuthDto { Token = token, Message = "Вы успешно зашли в аккаунт" });
        }
    }
}