using System;
using BarberBooking.API.Dto.DtoConversationMessages;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.ConversationMessages.Commands
{
    public record UpdateConversationMessageCommand(Guid Id, string content) : IRequest<Result<DtoConversationMessageInfo>>;
}
