using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoWeeklyTemplate;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.WeeklyTemplate.Queries
{
    public record GetWeeklyTemplatesQuery():IRequest<Result<List<DtoWeeklyTemplateShortInfo>>>;
}