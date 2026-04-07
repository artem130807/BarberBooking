using System;
using BarberBooking.API.Dto.DtoTemplateDay;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.TemplateDay.Queries
{
    public record GetTemplateDayQuery(Guid Id) : IRequest<Result<DtoTemplateDayInfo>>;
}
