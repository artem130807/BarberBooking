using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.DtoModels;
using BarberBooking.DtoModels.AuthorizationDto;
using MediatR;

namespace BarberBooking.CQRS.QueriesAuthorization
{
    public record CheckAuthorizationQuery(AuthorizationRequest authorizationRequest):IRequest<AuthorizationAudit>;

}