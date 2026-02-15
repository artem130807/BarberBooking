using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using CSharpFunctionalExtensions;
using MediatR;
using Microsoft.Extensions.Caching.Memory;

namespace BarberBooking.API.CQRS.Commands.Handlers
{
    public class UpdatePasswordHashCommandHandler:IRequestHandler<UpdatePasswordHashCommand, Result<string>>
    {
        private readonly IUserRepository _usersRepository;
        private readonly IPasswordHasher _passwordHasher;
        private readonly IPasswordValidatorService _passwordValidator;
        private readonly IMemoryCache _cache;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ILogger<UpdatePasswordHashCommandHandler> _logger;
         public UpdatePasswordHashCommandHandler(
            IUserRepository usersRepository,
            IPasswordHasher passwordHasher,
            IPasswordValidatorService  passwordValidator,
            IMemoryCache memoryCache,
            IUnitOfWork unitOfWork,
            ILogger<UpdatePasswordHashCommandHandler> logger
            )
        {
            _usersRepository = usersRepository;
            _passwordHasher = passwordHasher;
            _passwordValidator = passwordValidator;
            _cache = memoryCache;
            _unitOfWork = unitOfWork;
            _logger = logger;
        }

        public async Task<Result<string>> Handle(UpdatePasswordHashCommand command, CancellationToken cancellationToken)
        {
            var user = await _usersRepository.GetUserByEmail(command.Email);
            if (user == null)
            {
                return Result.Failure<string>("Пользователя с таким email не существует");
            }
            var passwordValid = await _passwordValidator.ValidatePasswordAsync(command.PasswordHash);
            if (!passwordValid.IsValid)
                return Result.Failure<string>(passwordValid.Message);
            
            var cacheKey = $"email_verified_{command.Email}";
            if (!_cache.TryGetValue(cacheKey, out bool isVerified) || !isVerified)
                return Result.Failure<string>("Email не подтвержден. Сначала подтвердите email для смены пароля.");
            string passwordHash = _passwordHasher.Generate(command.PasswordHash);
            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.userRepository.UpdatePasswordHash(command.Email ,passwordHash);
                _unitOfWork.Commit();
            }catch(Exception ex)
            {
                _unitOfWork.RollBack();
                _logger.LogError(ex.Message);
            }
            await _usersRepository.UpdatePasswordHash(command.Email, passwordHash);
            return Result.Success("Успешно");
        }
    }
}