using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using MediatR;
using Microsoft.Extensions.Caching.Memory;

namespace BarberBooking.API.CQRS.Commands.Handlers
{
    public class UpdatePasswordHashCommandHandler:IRequestHandler<UpdatePasswordHashCommand, Unit>
    {
        private readonly IUserRepository _usersRepository;
        private readonly IPasswordHasher _passwordHasher;
        private readonly IPasswordValidatorService _passwordValidator;
         public UpdatePasswordHashCommandHandler(
            IUserRepository usersRepository,
            IPasswordHasher passwordHasher,
            IPasswordValidatorService passwordValidator
            )
        {
            _usersRepository = usersRepository;
            _passwordHasher = passwordHasher;
            _passwordValidator = passwordValidator;
        }

        public async Task<Unit> Handle(UpdatePasswordHashCommand command, CancellationToken cancellationToken)
        {
            var user = await _usersRepository.GetUserByPhone(command.Email);
            if (user == null)
            {
                throw new InvalidOperationException("Пользователя с таким email не существует");
            }
            var passwordValid = await _passwordValidator.ValidatePasswordAsync(command.PasswordHash);
            if (!passwordValid.IsValid)
                throw new InvalidOperationException(passwordValid.Message);
                
            string passwordHash = _passwordHasher.Generate(command.PasswordHash);
            await _usersRepository.UpdatePasswordHash(command.Email, passwordHash);
            return Unit.Value;
        }
    }
}