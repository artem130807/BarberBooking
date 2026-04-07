using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.WeeklyTemplate.Commands
{
    public record DeleteWeeklyTemplateCommand(Guid Id):IRequest<Result<string>>;
}