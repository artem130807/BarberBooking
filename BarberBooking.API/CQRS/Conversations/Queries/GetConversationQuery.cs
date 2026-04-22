using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoConversation;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Conversations.Queries
{
    public record GetConversationQuery(Guid Id):IRequest<Result<DtoConversationInfo>>;
}