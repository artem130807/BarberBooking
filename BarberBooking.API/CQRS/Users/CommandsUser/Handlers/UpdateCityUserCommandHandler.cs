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
    public class UpdateCityUserCommandHandler : IRequestHandler<UpdateCityCommand, string>
    {
        private readonly IUserRepository _usersRepository;
       

        public UpdateCityUserCommandHandler(
            IUserRepository usersRepository
        )
        {
            _usersRepository = usersRepository;
        }

        public async Task<string> Handle(UpdateCityCommand command, CancellationToken cancellationToken)
        {
            var updateCity = await _usersRepository.UpdateCity(command.Id, command.City);       
            if(updateCity == null)
            {
                throw new InvalidOperationException("Ошибка");
            }
            return updateCity;
        }
    }
}