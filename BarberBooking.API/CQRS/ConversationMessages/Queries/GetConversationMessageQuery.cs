using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoConversationMessages;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.ConversationMessages.Queries
{
    public record GetConversationMessageQuery(Guid Id):IRequest<Result<DtoConversationMessageInfo>>;
}