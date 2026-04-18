using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoSalonAdmin;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.SalonsAdmins.Commands
{
    public record CreateSalonAdminCommand(DtoCreateSalonAdmin dtoCreateSalonAdmin):IRequest<Result<string>>;
}