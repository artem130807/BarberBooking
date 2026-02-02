using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using IdentityService.Contracts;
using IdentityService.DtoModels;
using IdentityService.Events;
using IdentityService.KafkaServices;
using IdentityService.Provider;
using MediatR;
using Microsoft.Extensions.Caching.Memory;

namespace IdentityService.CQRS.Queries.Handlers
{
    public class LoginUserQueryCommandHandler:IRequestHandler<LoginUserQuery, AuthDto>
    {
        private readonly IUserRepository _usersRepository;
        private readonly IPasswordHasher _passwordHasher;
        private readonly IJwtProvider _jwtProvider;
        private readonly IKafkaProducerService<EventUserLogin> _kafkaProducerService;
        private readonly IRolesRepository _rolesRepository;
        public LoginUserQueryCommandHandler(
            IUserRepository usersRepository,
            IPasswordHasher passwordHasher,
            IJwtProvider jwtProvider, IKafkaProducerService<EventUserLogin> kafkaProducerService, IRolesRepository rolesRepository
            )
        {
            _usersRepository = usersRepository;
            _passwordHasher = passwordHasher;
            _jwtProvider = jwtProvider;
            _kafkaProducerService = kafkaProducerService;
            _rolesRepository = rolesRepository;
        }

        public async Task<AuthDto> Handle(LoginUserQuery query, CancellationToken cancellationToken)
        {
            var user = await _usersRepository.GetUserByEmail(query.Email);
            var result = _passwordHasher.Verify(query.PasswordHash, user.PasswordHash);
            if (result == false || user == null)
            {
                throw new InvalidOperationException("Пользователя не существует");
            }
            var token = _jwtProvider.GenerateToken(user);
            var rolesUser = await _rolesRepository.GetRolesIdByUserId(user.Id);
            List<int> rolesIdUser = rolesUser.Select(x => x.RoleId).ToList();
            var eventLogin = new EventUserLogin(Guid.NewGuid(), user.Id, rolesIdUser, user.Name, user.Email.Value);
            await _kafkaProducerService.ProduceAsync(eventLogin, cancellationToken);
            return new AuthDto { Token = token, Message = "Вы успешно зашли в аккаунт" };
        }
    }
}