using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoSalonAdmin;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.SalonsAdmins.Queries
{
    public record GetSalonAdminQuery(Guid Id):IRequest<Result<DtoGetSalonAdmin>>;
}