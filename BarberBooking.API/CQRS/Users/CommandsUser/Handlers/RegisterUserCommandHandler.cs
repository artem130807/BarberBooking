using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using Azure;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.UserContratcts;
using BarberBooking.API.Domain.ValueObjects;
using BarberBooking.API.Dto;
using BarberBooking.API.Enums;
using BarberBooking.API.Models;
using BarberBooking.API.Provider;
using CSharpFunctionalExtensions;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;

namespace BarberBooking.API.CQRS.Commands.Handlers
{
    public class RegisterUserCommandHandler:IRequestHandler<RegisterUserCommand, Result<AuthDto>>
    {
        private readonly IUserRepository _usersRepository;
        private readonly IPasswordHasher _passwordHasher;
        private readonly IJwtProvider _jwtProvider;
        private readonly IUserRolesRepository _rolesRepository;
        private readonly IPasswordValidatorService _passwordValidatorService;
        private readonly IMemoryCache _memoryCache;
        private readonly IDnsEmailValidator _emailValidator;
        private readonly IUserValidatorService _userValidator;
        private readonly IUserRolesRepository _userRolesRepository;
        private readonly IRefreshTokenService _refreshTokenService;
        public RegisterUserCommandHandler(
            IUserRepository usersRepository,
            IPasswordHasher passwordHasher,
            IJwtProvider jwtProvider,
            IUserRolesRepository rolesRepository, 
            IPasswordValidatorService passwordValidatorService,
            IUserRolesRepository roleRepository, IMemoryCache memoryCache,
            IDnsEmailValidator emailValidator,
            IUserValidatorService userValidator,
            IUserRolesRepository userRolesRepository,
            IRefreshTokenService refreshTokenService
        )
        {
            _emailValidator = emailValidator;
            _usersRepository = usersRepository;
            _passwordHasher = passwordHasher;
            _jwtProvider = jwtProvider;
            _rolesRepository = rolesRepository;
            _passwordValidatorService = passwordValidatorService;
            _rolesRepository = roleRepository;
            _memoryCache = memoryCache;
            _userValidator = userValidator;
            _userRolesRepository = userRolesRepository;
            _refreshTokenService = refreshTokenService;
        }
        public async Task<Result<AuthDto>> Handle(RegisterUserCommand command, CancellationToken cancellationToken)
        {
            var userValid = await _userValidator.ValidUser(command.dtoCreateUser);
            if(userValid.IsFailure)
                return Result.Failure<AuthDto>(userValid.Error);

            var passwordValid = await _passwordValidatorService.ValidatePasswordAsync(command.dtoCreateUser.PasswordHash);
            if (!passwordValid.IsValid)
                return Result.Failure<AuthDto>(passwordValid.Message);

            var emailValid = await _emailValidator.ValidateEmailAsync(command.dtoCreateUser.Email);
            if(emailValid.IsFailure)
                    return Result.Failure<AuthDto>(emailValid.Error);

            var user = await _usersRepository.GetUserByPhone(command.dtoCreateUser.Phone.Number);
            if (user != null)       
                return Result.Failure<AuthDto>("Пользователь с таким номером телефона уже существует");
                
            var cacheKey = $"email_verified_{command.dtoCreateUser.Email}"; 
            if (!_memoryCache.TryGetValue(cacheKey, out bool isVerified) || !isVerified)
                return Result.Failure<AuthDto>("Email не подтвержден. Сначала подтвердите email.");

            var password = _passwordHasher.Generate(command.dtoCreateUser.PasswordHash);
            var role = await _rolesRepository.GetUserRolesAsync((int)RolesEnum.User);
            if(role == null)
                return Result.Failure<AuthDto>("Нету роли");
            
            var PhoneValueObject = PhoneNumber.Create(command.dtoCreateUser.Phone.Number).Value;
            
            var newuser = new Models.Users
            {
                Id = Guid.NewGuid(),
                Name = command.dtoCreateUser.Name,
                Phone = PhoneValueObject,
                Email = command.dtoCreateUser.Email,
                PasswordHash = password,
                City = command.dtoCreateUser.City,
                Roles = role
            };
            await _usersRepository.Register(newuser);
            
            var refreshToken = await _refreshTokenService.CreateToken(newuser.Id, command.dtoCreateUser.Devices);
            var token = await _jwtProvider.GenerateToken(newuser, command.dtoCreateUser.Devices);
            var roleInterface = await _userRolesRepository.GetMaxRole(newuser.Id);
            _memoryCache.Remove(cacheKey);
            return Result.Success(new AuthDto { AccessToken = token, RefreshToken = refreshToken ,Message = "Вы успешно зарегистрировались", RoleInterface = roleInterface });
        }
        
    }

}