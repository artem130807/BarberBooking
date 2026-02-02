using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using IdentityService.DtoModels;
using MediatR;

namespace IdentityService.CQRS.Queries
{
    public record GetUserByIdQuery(Guid Id):IRequest<UserInfoDto>;
   
}