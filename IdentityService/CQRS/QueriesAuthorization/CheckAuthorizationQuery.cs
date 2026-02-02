using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using IdentityService.DtoModels;
using IdentityService.DtoModels.AuthorizationDto;
using MediatR;

namespace IdentityService.CQRS.QueriesAuthorization
{
    public record CheckAuthorizationQuery(AuthorizationRequest authorizationRequest):IRequest<AuthorizationAudit>;

}