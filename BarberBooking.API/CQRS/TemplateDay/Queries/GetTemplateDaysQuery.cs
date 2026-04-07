using System;
using System.Collections.Generic;
using BarberBooking.API.Dto.DtoTemplateDay;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.TemplateDay.Queries
{
    public record GetTemplateDaysQuery(Guid WeeklyTemplateId) : IRequest<Result<List<DtoTemplateDayInfo>>>;
}
