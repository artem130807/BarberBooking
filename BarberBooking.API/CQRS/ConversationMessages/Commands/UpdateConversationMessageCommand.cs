using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoConversation;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.ConversationMessages.Commands
{
    public record UpdateConversationMessageCommand(Guid Id, string content):IRequest<Result<DtoConversationInfo>>;
}