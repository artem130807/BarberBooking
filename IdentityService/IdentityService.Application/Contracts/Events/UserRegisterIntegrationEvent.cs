using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CSharpFunctionalExtensions;
using IdentityService.Application.Contracts.Base;
using IdentityService.Application.Contracts.Enums;

namespace IdentityService.Application.Contracts.Events
{
    public class UserRegisterIntegrationEvent:IntegrationEvent
    {
        public Guid Id {get; private set;}
        public string Email {get; private set;}
        public Guid UserId {get; private set;}

        public static Result<UserRegisterIntegrationEvent> Create(string email, Guid userId)
        {
            var @event = new UserRegisterIntegrationEvent
            {
                Id = Guid.NewGuid(),
                Email = email,
                UserId = userId,
                EventType = IntegrationType.RegisterUser.ToString()
            };
            return @event;
        }
    }
}