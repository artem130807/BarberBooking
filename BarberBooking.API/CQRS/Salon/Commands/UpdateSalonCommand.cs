using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoSalons;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Salons.Commands
{
    public record UpdateSalonCommand(Guid Id ,DtoUpdateSalon dtoUpdateSalon):IRequest<Result<Unit>>;
}