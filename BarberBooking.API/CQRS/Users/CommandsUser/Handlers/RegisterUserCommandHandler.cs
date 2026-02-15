using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using Azure;
using BarberBooking.API.Contracts;
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
        public RegisterUserCommandHandler(
            IUserRepository usersRepository,
            IPasswordHasher passwordHasher,
            IJwtProvider jwtProvider,
            IUserRolesRepository rolesRepository, 
            IPasswordValidatorService passwordValidatorService,
            IUserRolesRepository roleRepository, IMemoryCache memoryCache
        )
        {
            _usersRepository = usersRepository;
            _passwordHasher = passwordHasher;
            _jwtProvider = jwtProvider;
            _rolesRepository = rolesRepository;
            _passwordValidatorService = passwordValidatorService;
            _rolesRepository = roleRepository;
            _memoryCache = memoryCache;
        }
        public async Task<Result<AuthDto>> Handle(RegisterUserCommand command, CancellationToken cancellationToken)
        {

            var user = await _usersRepository.GetUserByPhone(command.PhoneNumber);
            if (user != null)       
                return Result.Failure<AuthDto>("Пользователь с таким номером телефона уже существует");
                
            var passwordValid = await _passwordValidatorService.ValidatePasswordAsync(command.PasswordHash);
            if (!passwordValid.IsValid)
                return Result.Failure<AuthDto>(passwordValid.Message);

            var cacheKey = $"email_verified_{command.Email}"; 
            if (!_memoryCache.TryGetValue(cacheKey, out bool isVerified) || !isVerified)
                return Result.Failure<AuthDto>("Email не подтвержден. Сначала подтвердите email.");

            var password = _passwordHasher.Generate(command.PasswordHash);
            var role = await _rolesRepository.GetUserRolesAsync((int)RolesEnum.User);
            if(role == null)
                return Result.Failure<AuthDto>("Нету роли");
            
            var PhoneValueObject = PhoneNumber.Create(command.PhoneNumber).Value;
            
            var newuser = new Users
            {
                Id = Guid.NewGuid(),
                Name = command.Name,
                Phone = PhoneValueObject,
                Email = command.Email,
                PasswordHash = password,
                City = command.City,
                Roles = role
            };
            await _usersRepository.Register(newuser);
            var token = await _jwtProvider.GenerateToken(newuser);
            _memoryCache.Remove(cacheKey);
            return Result.Success(new AuthDto { Token = token, Message = "Вы успешно зарегистрировались" });
        }
        
    }

}