using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoConversation;
using BarberBooking.API.Filters;
using BarberBooking.API.Filters.ConversationFilter;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Conversations.Queries
{
    public record GetConversationsBySearchQuery(SearchConversationFilter filter, PageParams pageParams):IRequest<Result<PagedResult<DtoConversationShortInfo>>>;
}