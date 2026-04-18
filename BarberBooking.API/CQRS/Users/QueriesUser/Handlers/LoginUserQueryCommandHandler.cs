using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Dto;
using BarberBooking.API.Models;
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
        private readonly IUserRolesRepository _userRolesRepository;
        private readonly IRefreshTokenRepository _refreshTokenRepository;
        private readonly IRefreshTokenService _refreshTokenService;
        public LoginUserQueryCommandHandler(
            IUserRepository usersRepository,
            IPasswordHasher passwordHasher,
            IJwtProvider jwtProvider,
            IUserRolesRepository userRolesRepository,
            IRefreshTokenRepository refreshTokenRepository,
            IRefreshTokenService refreshTokenService
            )
        {
            _usersRepository = usersRepository;
            _passwordHasher = passwordHasher;
            _jwtProvider = jwtProvider;
            _userRolesRepository = userRolesRepository;
            _refreshTokenRepository = refreshTokenRepository;
            _refreshTokenService = refreshTokenService;
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
            var refreshToken = await _refreshTokenRepository.GetRefreshTokenByDevices(user.Id, query.devices);
            var token = await _jwtProvider.GenerateToken(user, query.devices);
            var roleInterface = await _userRolesRepository.GetMaxRole(user.Id);
            if(refreshToken == null)
            {
                var newToken = await _refreshTokenService.CreateToken(user.Id, query.devices);
                return Result.Success(new AuthDto { AccessToken = token, RefreshToken = newToken, Message = "Вы успешно зашли в аккаунт", RoleInterface = roleInterface});
            }
            return Result.Success(new AuthDto { AccessToken = token, Message = "Вы успешно зашли в аккаунт", RoleInterface = roleInterface});
        }
    }
}