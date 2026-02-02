using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using IdentityService.Contracts;
using IdentityService.Domain.ValueObjects;
using IdentityService.DtoModels;
using IdentityService.Enums;
using IdentityService.Events;
using IdentityService.KafkaServices;
using IdentityService.Models;
using IdentityService.Provider;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;

namespace IdentityService.CQRS.Commands.Handlers
{
    public class RegisterUserCommandHandler:IRequestHandler<RegisterUserCommand, AuthDto>
    {
        private readonly IdentityDbContext _identityDbContext;
        private readonly IUserRepository _usersRepository;
        private readonly IPasswordHasher _passwordHasher;
        private readonly IJwtProvider _jwtProvider;
        private readonly IDnsEmailValidator _emailValidator;
        private readonly IMemoryCache _cache;
        private readonly IPasswordValidatorService _passwordValidator;
        private readonly ICityValidationService _cityValidate;
        private readonly IKafkaProducerService<EventUserRegister> _kafkaProducerService;
        private readonly IRolesRepository _rolesRepository;

        public RegisterUserCommandHandler(
            IUserRepository usersRepository,
            IPasswordHasher passwordHasher,
            IJwtProvider jwtProvider,
            IdentityDbContext identityDbContext,
            IDnsEmailValidator emailValidator,
            IMemoryCache cache,
            IPasswordValidatorService passwordValidator,
            ICityValidationService cityValidate, IKafkaProducerService<EventUserRegister> kafkaProducerService,
            IRolesRepository rolesRepository
            )
        {
            _usersRepository = usersRepository;
            _passwordHasher = passwordHasher;
            _jwtProvider = jwtProvider;
            _identityDbContext = identityDbContext;
            _emailValidator = emailValidator;
            _cache = cache;
            _passwordValidator = passwordValidator;
            _cityValidate = cityValidate;
            _kafkaProducerService = kafkaProducerService;
            _rolesRepository = rolesRepository;
        }
        public async Task<AuthDto> Handle(RegisterUserCommand command, CancellationToken cancellationToken)
        {
             var valid = await _cityValidate.ValidCityAsync(command.City);
             if (!valid.IsValid)
               throw new InvalidOperationException(valid.Message);

            var user = await _usersRepository.GetUserByEmail(command.Email);
            if (user != null)
                throw new InvalidOperationException("Пользователь с таким email уже существует");
                
            var passwordValid = await _passwordValidator.ValidatePasswordAsync(command.PasswordHash);
            if (!passwordValid.IsValid)
                throw new InvalidOperationException(passwordValid.Message);

            var email = await _emailValidator.ValidateEmailAsync(command.Email);
            if (!email.IsValid)
                throw new InvalidOperationException(email.Message);
           
            var cacheKey = $"email_verified_{command.Email}"; 
            if (!_cache.TryGetValue(cacheKey, out bool isVerified) || !isVerified)
                throw new InvalidOperationException("Email не подтвержден. Сначала подтвердите email.");

            var password = _passwordHasher.Generate(command.PasswordHash);
            var role = await _identityDbContext.Roles.SingleOrDefaultAsync(x => x.Id == (int)RolesEnum.User) ?? throw new InvalidOperationException();
            var EmailValueObject = Email.CreateEmail(command.Email).Value;
            var newuser = new Users
            {
                Id = Guid.NewGuid(),
                Name = command.Name,
                Email = EmailValueObject,
                PasswordHash = password,
                City = command.City,
                Roles = [role]
            };
            await _usersRepository.Register(newuser);
            var token = _jwtProvider.GenerateToken(newuser);
            var rolesUser = await _rolesRepository.GetRolesIdByUserId(newuser.Id);
            List<int> rolesIdUser = rolesUser.Select(x => x.RoleId).ToList();
            var eventLogin = new EventUserRegister(Guid.NewGuid(), newuser.Id, rolesIdUser, newuser.Name, newuser.Email.Value);
            await _kafkaProducerService.ProduceAsync(eventLogin, cancellationToken);
            _cache.Remove(cacheKey);
            return new AuthDto { Token = token, Message = "Вы успешно зарегистрировались" };
        }
        
    }

}