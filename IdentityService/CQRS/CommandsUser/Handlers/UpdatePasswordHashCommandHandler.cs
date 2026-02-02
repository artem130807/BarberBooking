using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using IdentityService.Contracts;
using IdentityService.DtoModels;
using IdentityService.Provider;
using MediatR;
using Microsoft.Extensions.Caching.Memory;

namespace IdentityService.CQRS.Commands.Handlers
{
    public class UpdatePasswordHashCommandHandler:IRequestHandler<UpdatePasswordHashCommand, Unit>
    {
        private readonly IUserRepository _usersRepository;
        private readonly IPasswordHasher _passwordHasher;
        private readonly IDnsEmailValidator _emailValidator;
        private readonly IMemoryCache _cache;
        private readonly IPasswordValidatorService _passwordValidator;
         public UpdatePasswordHashCommandHandler(
            IUserRepository usersRepository,
            IPasswordHasher passwordHasher,
            IDnsEmailValidator emailValidator,
            IMemoryCache cache,
            IPasswordValidatorService passwordValidator
            )
        {
            _usersRepository = usersRepository;
            _passwordHasher = passwordHasher;
            _emailValidator = emailValidator;
            _cache = cache;
            _passwordValidator = passwordValidator;
        }

        public async Task<Unit> Handle(UpdatePasswordHashCommand command, CancellationToken cancellationToken)
        {
            var user = await _usersRepository.GetUserByEmail(command.Email);
            if (user == null)
            {
                throw new InvalidOperationException("Пользователя с таким email не существует");
            }
            var passwordValid = await _passwordValidator.ValidatePasswordAsync(command.PasswordHash);
            if (!passwordValid.IsValid)
                throw new InvalidOperationException(passwordValid.Message);
            var emailValid = await _emailValidator.ValidateEmailAsync(command.Email);
            if (!emailValid.IsValid)
                throw new InvalidOperationException(emailValid.Message); 

            var cacheKey = $"email_verified_{command.Email}";
            if (!_cache.TryGetValue(cacheKey, out bool isVerified) || !isVerified)
                throw new InvalidOperationException("Email не подтвержден. Сначала подтвердите email для смены пароля.");
                
            string passwordHash = _passwordHasher.Generate(command.PasswordHash);
            await _usersRepository.UpdatePasswordHash(command.Email, passwordHash);
            return Unit.Value;
        }
    }
}