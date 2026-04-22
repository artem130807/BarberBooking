using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoConversation;
using BarberBooking.API.Dto.DtoConversationMessages;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.ConversationMessages.Commands
{
    public record CreateConversationMessageCommand(DtoCreateConversationMessage dtoCreateConversationMessage):IRequest<Result<DtoConversationMessageInfo>>;
}