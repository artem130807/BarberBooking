using System;
using BarberBooking.API.Dto.DtoTemplateDay;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.TemplateDay.Commands
{
    public record UpdateTemplateDayCommand(Guid Id, DtoUpdateTemplateDay Dto) : IRequest<Result<string>>;
}
