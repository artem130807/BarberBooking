using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoMessages;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Messages.Queries
{
    public record GetMessagesQuery():IRequest<Result<List<DtoMessagesShortInfo>>>;
}