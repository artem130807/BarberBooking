using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using IdentityService.Contracts;
using IdentityService.Provider;
using MediatR;
using Microsoft.Extensions.Caching.Memory;

namespace IdentityService.CQRS.Commands.Handlers
{
    public class UpdateCityUserCommandHandler : IRequestHandler<UpdateCityCommand, string>
    {
        private readonly IUserRepository _usersRepository;
        private readonly ICityValidationService _cityValidate;

        public UpdateCityUserCommandHandler(
            IUserRepository usersRepository,
            ICityValidationService cityValidate
        )
        {
            _usersRepository = usersRepository;
            _cityValidate = cityValidate;
        }

        public async Task<string> Handle(UpdateCityCommand command, CancellationToken cancellationToken)
        {
            var valid = await _cityValidate.ValidCityAsync(command.City);
            if (!valid.IsValid)
            {
                throw new InvalidOperationException(valid.Message);
            }
            var updateCity = await _usersRepository.UpdateCity(command.Id, command.City);       
            if(updateCity == null)
            {
                throw new InvalidOperationException("Ошибка");
            }
            return updateCity;
        }
    }
}