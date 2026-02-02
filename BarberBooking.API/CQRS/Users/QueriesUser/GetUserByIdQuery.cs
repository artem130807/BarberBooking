using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto;
using MediatR;

namespace BarberBooking.API.CQRS.Queries
{
    public record GetUserByIdQuery(Guid Id):IRequest<UserInfoDto>;
   
}