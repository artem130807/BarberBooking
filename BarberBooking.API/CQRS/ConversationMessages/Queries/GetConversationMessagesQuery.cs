using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoConversationMessages;
using BarberBooking.API.Filters;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.ConversationMessages.Queries
{
    public record GetConversationMessagesQuery(Guid conversationId, PageParams pageParams):IRequest<Result<PagedResult<DtoConversationMessageShortInfo>>>;
}